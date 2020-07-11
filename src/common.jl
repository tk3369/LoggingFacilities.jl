# Common transformers

"""
    OneLineTransformerLogger(logger::AbstractLogger)

Return a logger that rolls all kwargs into the message field, resulting
in a single-line log.
"""
function OneLineTransformerLogger(logger::AbstractLogger)
    return TransformerLogger(logger) do log
        migrate(log, KwargsProperty(), MessageProperty())
    end
end

"""
    TimestampTransformerLogger([logger::AbstractLogger], location::AbstractInjectLocation; kwargs...)

Return a logger that includes a timestamp in the log.  If `logger` is not specified,
then it returns a closure that takes a single logger argument. The timestamp can be injected
in any of the following `location`:
- [`KwargsLocation`](@ref)
- [`BeginningMessageLocation`](@ref)
- [`EndingMessageLocation`](@ref)

# Keyword arguments
- `format`: a DateTime format string, see
[Dates.format](https://docs.julialang.org/en/v1/stdlib/Dates/#Dates.format-Tuple{TimeType,AbstractString}) and
[TimeZones documentation](https://juliatime.github.io/TimeZones.jl/stable/conversions/#Formatting-strings-1)
- `label`: a symbol that is used as the key of the timestamp for `KwargsLocation` injection location
"""
function TimestampTransformerLogger end

function TimestampTransformerLogger(location::T; kwargs...) where {T <: AbstractInjectLocation}
    return logger -> TimestampTransformerLogger(logger, location; kwargs...)
end

function TimestampTransformerLogger(logger::AbstractLogger, location::KwargsLocation;
                                    format = "yyyy-mm-ddTHH:MM:SSz",
                                    label = :timestamp) where {T <: AbstractInjectLocation}
    return TransformerLogger(logger) do log
        inject(log, location, () -> (label => current_time_string(format),))
    end
end

function TimestampTransformerLogger(logger::AbstractLogger, location::MessageLocation;
                                    format = "yyyy-mm-ddTHH:MM:SSz")
    return TransformerLogger(logger) do log
        inject(log, location, () -> current_time_string(format))
    end
end

"""
    current_time_string(format)

Return the current time as a formatted string.
"""
function current_time_string end

current_time_string(format::AbstractString) = current_time_string(DateFormat(format))

function current_time_string(format::DateFormat)
    ts = now(localzone())
    return Dates.format(ts, format)
end

"""
    JSONTransformerLogger(logger::AbstractLogger)

Return a logger that formats all information (level, message, and kwargs)
as a JSON string.  The result is stored in the message field of the log record.
The existing kwargs data is emptied automatically.
"""
function JSONTransformerLogger(logger::AbstractLogger;
                               level_label::Symbol = :level,
                               message_label::Symbol = :message,
                               indent::Integer = 0)
    return TransformerLogger(logger) do log
            @pipe log |>
                 migrate(_, LevelProperty(), KwargsProperty(); label = level_label, transform = string) |>
                 migrate(_, MessageProperty(), KwargsProperty(); label = message_label) |>
                 migrate(_, KwargsProperty(), MessageProperty();
                         transform = x -> chomp(json(namedtuple(x), indent)),
                         prepend = "")
    end
end

"""
    ColorMessageTransformerLogger([logger], colors::Dict{Logging.LogLevel,ColorSpec})

Apply `colors` to message string based upon log level. If `logger` is not specified,
then it returns a closure that takes a single logger argument.
"""
function ColorMessageTransformerLogger(colors::Dict{Logging.LogLevel,ColorSpec})
    return logger -> ColorMessageTransformerLogger(logger, colors)
end

function ColorMessageTransformerLogger(logger::AbstractLogger,
                              colors::Dict{Logging.LogLevel,ColorSpec})
    return TransformerLogger(logger) do log
                mutate(log, MessageProperty();
                       transform = (log) -> styled_string(log.message, colors[log.level]))
    end
end

function FixedMessageWidthTransformerLogger(logger::AbstractLogger, width::Integer)
    return TransformerLogger(logger) do log
                mutate(log, MessageProperty();
                    transform = (log) -> first(rpad(log.message, width), width))
    end
end

function FixedKwargWidthTransformerLogger(logger::AbstractLogger, width::Integer)
    return TransformerLogger(logger) do log
                mutate(log, KwargsProperty(); transform = (log) -> show(log.kwarg))
    end
end

"""
    styled_string(xs...; spec::ColorSpec)

Return a styled string.
"""
function styled_string(x, spec::ColorSpec)
    io = IOBuffer()
    printstyled(IOContext(io, :color => true), x; bold = spec.bold, color = spec.color)
    return String(take!(io))
end

"""
    namedtuple(pairs)

Convert an iterable of pairs into a named tuple. If there's any duplicate in the key,
then the first one wins (silently).
"""
function namedtuple(pairs)
    d = Dict()
    for p in pairs
        get!(d, Symbol(first(p)), last(p))
    end
    names = (keys(d)...,)
    nt = NamedTuple{names}(values(d))
    return nt
end

"""
    compose(logger::AbstractLogger, transformers::Function...)

Compose a transformer logger by chaining the specified transformer loggers
in the same order as they are specified.

Note: this function should probably be upstreamed to LoggingExtras.jl
"""
function compose(logger::AbstractLogger, transformers::Function...)
    ∘(transformers...)(logger)
end

