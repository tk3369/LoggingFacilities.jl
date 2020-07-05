"""
    inject(::T, v; kwargs...) where {T <: AbstractInjectLocation}

Inject the value `v` to the specific location in the log record.  If `v` is callable
(e.g. function) then it will be evalated at runtime before injecting into the log.
"""
inject(loc::T, v; kw...) where {T <: AbstractInjectLocation} = log -> inject(log, loc, v; kw...)

function inject(log, loc::T, v; sep = " ") where {T <: MessageLocation}
    value = v isa Base.Callable ? v() : v
    msg = if T <: BeginningMessageLocation && length(log.message) > 0
              "$value$sep$(log.message)"
          elseif T <: EndingMessageLocation && length(log.message) > 0
              "$(log.message)$sep$value"
          else
              "$value"
          end
    merge(log, (message = msg,))
end

function inject(log, ::KwargsLocation, v)
    value = v isa Base.Callable ? v() : v
    updated_kwargs = (value..., log.kwargs...)
    merge(log, (kwargs = updated_kwargs,))
end

function inject(log, ::LevelLocation, v)
    value = v isa Base.Callable ? v() : v
    merge(log, (level = value,))
end

# Removing stuffs

"""
    remove(prop::T) where {T <: AbstractLogProperty}

Remove either `message` or `kwargs` data from the log record.  The `prop`
argument can be either `MessageProperty()` or `KwargsProperty`.
"""
remove(prop::T) where {T <: AbstractLogProperty} = log -> remove(log, prop)

remove(log, ::KwargsProperty) = merge(log, (kwargs = (),))
remove(log, ::MessageProperty) = merge(log, (message = "",))
remove(log, ::LevelProperty) = error("Level property cannot be removed")

# Migrating stuffs

kv_string(kwargs, sep, divider) = join(["$k$sep$v" for (k,v) in kwargs], divider)

# dispatcher
migrate(from::AbstractLogProperty, to::AbstractLogProperty; kwargs...) = log -> begin
    migrate(log, from, to; kwargs...)
end

"""
    migrate(::MessageProperty, ::KwargsProperty; label = :message)

Migrate the message string to kwargs location with key `label`.
"""
function migrate(log, ::MessageProperty, ::KwargsProperty; label = :message)
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
function migrate(log, ::KwargsProperty, ::MessageProperty;
        sep = "=", divider = " ", prepend = " ",
        transform = (kwargs) -> kv_string(kwargs, sep, divider))
    @pipe log |>
          inject(_, EndingMessageLocation(), transform(log.kwargs); sep = prepend) |>
          remove(_, KwargsProperty())
end

"""
    migrate(::LevelProperty, ::MessageProperty; loc = EndingMessageLocation(), transform::Function = string)

Migrate the log level to the message field at the `loc` location.  A custom transform function
may be specified should a different format is desired.
"""
function migrate(log, ::LevelProperty, ::MessageProperty;
        location = BeginningMessageLocation(),
        transform::Function = string)
    inject(log, location, transform(log.level))
end

"""
    migrate(::LevelProperty, ::KwargsProperty; label = :level, transform::Function = string)

Migrate the log level to the kwargs field with key `label`.  A custom transform function
may be specified should a different format is desired.
"""
function migrate(log, ::LevelProperty, ::KwargsProperty;
        label = :level,
        transform::Function = identity)
    inject(log, KwargsLocation(), (label => transform(log.level),))
end
