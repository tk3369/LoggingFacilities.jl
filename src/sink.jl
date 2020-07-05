"""
    MessageOnlyLogger(stream=stderr, min_level=Info)

A simple logger for logging only the message field.
"""
struct MessageOnlyLogger <: AbstractLogger
    stream::IO
    min_level::LogLevel
end
MessageOnlyLogger(stream::IO=stderr, level=Logging.Info) = MessageOnlyLogger(stream, level)

Logging.shouldlog(logger::MessageOnlyLogger, level, _module, group, id) = true

Logging.min_enabled_level(logger::MessageOnlyLogger) = logger.min_level

Logging.catch_exceptions(logger::MessageOnlyLogger) = false

function Logging.handle_message(logger::MessageOnlyLogger,
                                level, message, _module, group, id, filepath, line;
                                kwargs...)
    println(logger.stream, message)
end
