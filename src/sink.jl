"""
    SimplestLogger(stream=stderr, min_level=Info)

The most simplistic logger for logging all messages with level greater than or equal to
`min_level` to `stream`.

NOTE: this logger does not output log level.
"""
struct SimplestLogger <: AbstractLogger
    stream::IO
    min_level::LogLevel
end
SimplestLogger(stream::IO=stderr, level=Logging.Info) = SimplestLogger(stream, level)

Logging.shouldlog(logger::SimplestLogger, level, _module, group, id) = true

Logging.min_enabled_level(logger::SimplestLogger) = logger.min_level

Logging.catch_exceptions(logger::SimplestLogger) = false

function Logging.handle_message(logger::SimplestLogger,
                                level, message, _module, group, id, filepath, line;
                                kwargs...)
    buf = IOBuffer()
    iob = IOContext(buf, logger.stream)
    println(iob, message)
    for kv in kwargs
        println(iob, kv[1], " = ", kv[2])
    end
    write(logger.stream, take!(buf))
    nothing
end
