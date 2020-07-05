# Common transformers

"""
    OneLineTransformerLogger(logger::AbstractLogger)

Return a logger that rolls all kwargs into the message field, resulting
in a single-line log.
"""
function OneLineTransformerLogger(logger::AbstractLogger)
    return build(logger, migrate(KwargsProperty(), MessageProperty()))
end

"""
    TimestampTransformerLogger(logger::AbstractLogger, location::AbstractInjectLocation; kwargs...)

Return a logger that includes a timestamp in the log. The timestamp can be
injected in the specified `locations`:
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

function TimestampTransformerLogger(logger::AbstractLogger, location::KwargsLocation;
                                    format = "yyyy-mm-ddTHH:MM:SSz",
                                    label = :timestamp) where {T <: AbstractInjectLocation}
    return build(logger, inject(location, () -> (label => current_time_string(format),)))
end

function TimestampTransformerLogger(logger::AbstractLogger, location::MessageLocation;
                                    format = "yyyy-mm-ddTHH:MM:SSz")
    return build(logger, inject(location, () -> current_time_string(format)))
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
    jfunc = indent == 0 ? json : x -> json(x, indent)
    return build(logger,
                 migrate(LevelProperty(), KwargsProperty(); label = level_label, transform = string),
                 migrate(MessageProperty(), KwargsProperty(); label = message_label),
                 migrate(KwargsProperty(), MessageProperty();
                         transform = x -> chomp(jfunc(x)),
                         prepend = ""))
end
