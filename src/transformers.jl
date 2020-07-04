"""
    inject(::T, v; kwargs...) where {T <: InjectLocation}

Inject the value `v` to the specific location in the log record.  If `v` is callable
(e.g. function) then it will be evalated at runtime before injecting into the log.
"""
inject(loc::T, v; kw...) where {T <: InjectLocation} = log -> inject(log, loc, v; kw...)

function inject(log, loc::MessageLocation, v; sep = " ")
    value = v isa Base.Callable ? v() : v
    msg = loc isa BeginningMessageLocation ? "$value$sep$(log.message)" : "$(log.message)$sep$value"
    # println("injected msg=$msg")
    merge(log, (message = msg,))
end

function inject(log, ::KwargsLocation, v)
    value = v isa Base.Callable ? v() : v
    updated_kwargs = (value..., log.kwargs...)
    merge(log, (kwargs = updated_kwargs,))
end

# Removing stuffs

"""
    remove(prop::T) where {T <: LogProperty}

Remove either `message` or `kwargs` data from the log record.  The `prop`
argument can be either `MessageProperty()` or `KwargsProperty`.
"""
remove(prop::T) where {T <: LogProperty} = log -> remove(log, prop)

remove(log, ::KwargsProperty) = merge(log, (kwargs = (),))
remove(log, ::MessageProperty) = merge(log, (message = "",))
remove(log, ::LevelProperty) = error("Level property cannot be removed")

# Migrating stuffs

kv_string(kwargs, sep, divider) = join(["$k$sep$v" for (k,v) in kwargs], divider)

"""
    migrate(::MessageProperty, ::KwargsProperty; label = :message)

Migrate the message string to kwargs location with key `label`.
"""
migrate(::MessageProperty, ::KwargsProperty; label = :message) = log -> begin
    @pipe log |>
          inject(_, KwargsLocation(), (label => log.message,)) |>
          remove(_, MessageProperty())
end

"""
    migrate(::KwargsProperty, ::MessageProperty; sep = "=", divider = " ", prepend = " ", transform::Function)

Migrate all kwargs to the end of message string.  By default kwargs will be formatted as key=value
pairs separated by a space (specified as `divider`). However, a custom `transform` function may be
passed for custom formatting.
"""
migrate(::KwargsProperty, ::MessageProperty;
        sep = "=", divider = " ", prepend = " ",
        transform = (kwargs) -> kv_string(kwargs, sep, divider)) = log -> begin
    @pipe log |>
          inject(_, EndingMessageLocation(), transform(log.kwargs); sep = prepend) |>
          remove(_, KwargsProperty())
end

"""
    migrate(::LevelProperty, ::MessageProperty; loc = EndingMessageLocation(), transform::Function = string)

Migrate the log level to the message field at the `loc` location.  A custom transform function
may be specified should a different format is desired.
"""
migrate(::LevelProperty, ::MessageProperty;
        loc = EndingMessageLocation(),
        transform::Function = string) = log -> begin
    inject(log, loc, transform(log.level))
end

"""
    migrate(::LevelProperty, ::KwargsProperty; label = :level, transform::Function = string)

Migrate the log level to the kwargs field with key `label`.  A custom transform function
may be specified should a different format is desired.
"""
migrate(::LevelProperty, ::KwargsProperty;
        label = :level,
        transform::Function = string) = log -> begin
    inject(log, KwargsLocation(), (label => transform(log.level),))
end

# Chaining transformers

"""
    build(logger::AbstractLogger, transforms...)
"""
function build(logger::AbstractLogger, operations...)
    # composed_logger = nothing
    # for op in reverse(operations)
    #     if composed_logger === nothing
    #         composed_logger = TransformerLogger(logger, op)
    #     else
    #         composed_logger = TransformerLogger(composed_logger, op)
    #     end
    # end
    # return composed_logger
    first_logger = TransformerLogger(operations[end], logger)
    if length(operations) > 1
        build(first_logger, operations[1:end-1]...)
    else
        first_logger
    end
end
