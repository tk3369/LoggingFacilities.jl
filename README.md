[![Travis Build Status](https://travis-ci.org/tk3369/LoggingFacilities.jl.svg?branch=master)](https://travis-ci.org/tk3369/LoggingFacilities.jl)
[![codecov.io](http://codecov.io/github/tk3369/LoggingFacilities.jl/coverage.svg?branch=master)](http://codecov.io/github/tk3369/LoggingFacilities.jl?branch=master)

# LoggingFacilities

This package provides an easy way to build transformer loggers as defined in
[LoggingExtras.jl](https://github.com/oxinabox/LoggingExtras.jl).

A standard log record consists of the following components:
- `level`: the logging level like Error, Warn, Info, and Debug
- `messasge`: a string
- `kwargs`: key-value pairs

When designing log output, it may be desirable either enhance the log record
with additional information or move the data around within the record.  For examples:

1. Prepend current timestamp to `message` or add it to `kwargs`.
2. Log a single line by moving all `kwargs` into `message`.
3. Reformat the log record as a JSON string.
4. etc.

# How to use?

This package gives you facilities to do all of the above easily.  There are 3 main
concepts:
1. Inject - add data to the log record at either `message` or `kwargs` location.
2. Migrate - move data between `level`, `message`, and `kwargs`.
3. Remove - delete data from the log record

Examples:

```julia
# Migrate all kwargs to the message string
oneline_logger(logger) = build(logger, migrate(KwargsProperty(), MessageProperty()))

# Inject a timestamp to the kwargs location
timestamp_kwargs_logger(logger) =
    build(logger, inject(KwargsLocation(), () -> (:timestamp => now(),)))

# Inject a timestamp to the beginning of the message
timestamp_message_logger(logger) =
    build(logger, inject(BeginningMessageLocation(), () -> now()))

# JSON logging
json_logger(logger) = build(logger,
                            migrate(LevelProperty(), KwargsProperty()),
                            migrate(MessageProperty(), KwargsProperty()),
                            migrate(KwargsProperty(), MessageProperty(); transform = JSON.json))
```

## Credits

This package was originally conceived as part of [this coding live stream](https://www.youtube.com/watch?v=89xlkSUh_dA). Special credit to [Chris de Graff](https://github.com/christopher-dG) for joining
the live stream and helping out.

It has been redesigned significantly since v0.2.0.

