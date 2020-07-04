# Injecting stuffs

inject(loc::InjectLocation, v; kw...) = log -> inject(log, loc, v; kw...)

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

remove(prop::LogProperty) = log -> remove(log, prop)

remove(log, ::KwargsProperty) = merge(log, (kwargs = (),))
remove(log, ::MessageProperty) = merge(log, (message = "",))

# Migrating stuffs

kv_string(kwargs, sep, divider) = join(["$k$sep$v" for (k,v) in kwargs], divider)

migrate(::MessageProperty, ::KwargsProperty; label = :message) = log -> begin
    @pipe log |>
          inject(_, KwargsLocation(), (label => log.message,)) |>
          remove(_, MessageProperty())
end

migrate(::KwargsProperty, ::MessageProperty;
        sep = "=", divider = " ", prepend = " ",
        transform = (kwargs) -> kv_string(kwargs, sep, divider)) = log -> begin
    @pipe log |>
          inject(_, EndingMessageLocation(), transform(log.kwargs); sep = prepend) |>
          remove(_, KwargsProperty())
end

migrate(::LevelProperty, ::MessageProperty; loc = EndingMessageLocation(), transform = string) = log -> begin
    inject(log, loc, transform(log.level))
end

migrate(::LevelProperty, ::KwargsProperty; label = :level, transform = string) = log -> begin
    inject(log, KwargsLocation(), (label => transform(log.level),))
end

# Chaining transformers
function build(logger::AbstractLogger, transforms...)
    first_transform = TransformerLogger(transforms[end], logger)
    if length(transforms) > 1
        build(first_transform, transforms[1:end-1]...)
    else
        first_transform
    end
end
