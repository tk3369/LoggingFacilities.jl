"""
    SimplestLogger(stream=stderr, min_level=Info)

The most simplistic logger for logging all messages with level greater than or equal to
`min_level` to `stream`.
"""
struct SimplestLogger <: AbstractLogger
    stream::IO
    min_level::LogLevel
    message_limits::Dict{Any,Int}
end
SimplestLogger(stream::IO=stderr, level=Info) = SimplestLogger(stream, level, Dict{Any,Int}())

Logging.shouldlog(logger::SimplestLogger, level, _module, group, id) =
    get(logger.message_limits, id, 1) > 0

Logging.min_enabled_level(logger::SimplestLogger) = logger.min_level

Logging.catch_exceptions(logger::SimplestLogger) = false

function Logging.handle_message(logger::SimplestLogger, level, message, _module, group, id,
                        filepath, line; maxlog=nothing, kwargs...)
    if maxlog !== nothing && maxlog isa Integer
        remaining = get!(logger.message_limits, id, maxlog)
        logger.message_limits[id] = remaining - 1
        remaining > 0 || return
    end
    buf = IOBuffer()
    iob = IOContext(buf, logger.stream)
    println(iob, message)
    write(logger.stream, take!(buf))
    nothing
end
