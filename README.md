[![Travis Build Status](https://travis-ci.org/tk3369/LoggingFacilities.jl.svg?branch=master)](https://travis-ci.org/tk3369/LoggingFacilities.jl)
[![codecov.io](http://codecov.io/github/tk3369/LoggingFacilities.jl/coverage.svg?branch=master)](http://codecov.io/github/tk3369/LoggingFacilities.jl?branch=master)

# LoggingFacilities

This package provides an easy way to build transformer loggers as defined in
[LoggingExtras.jl](https://github.com/oxinabox/LoggingExtras.jl).

A few commonly used transformer loggers are provided as part of this package.
They can be accessed as follows.

**OneLineTransformerLogger**
```julia
julia> with_logger(OneLineTransformerLogger(current_logger())) do
           name = "Pluto"
           planet = false
           @info "hello world" name planet
       end
[ Info: hello world name=Pluto planet=false
```

**TimestampTransformerLogger**
```julia
julia> with_logger(TimestampTransformerLogger(current_logger(), BeginningMessageLocation();
                                              format = "yyyy-mm-dd HH:MM:SSz")) do
           @info "hello"
       end

[ Info: 2020-07-04 21:00:58-07:00 hello
```

**JSONTransformerLogger**
```julia
julia> with_logger(JSONTransformerLogger(SimplestLogger(); indent = 2)) do
           name = "Pluto"
           planet = false
           @info "hello world" name planet
       end
{
  "message": "hello world",
  "level": "Info",
  "name": "Pluto",
  "planet": false
}
```

## How does it work?

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

## How to build new loggers?

This package gives you facilities to do all of the above easily.  There are 3 main
concepts:
1. Inject - add data to the log record at either `message` or `kwargs` location.
2. Migrate - move data between `level`, `message`, and `kwargs`.
3. Remove - delete data from anywhere in the log record

Examples:

```julia
# Inject a timestamp to the beginning of the message
logger = build(current_logger(), inject(BeginningMessageLocation(), () -> now()))

# Inject a timestamp to the kwargs location
logger = build(current_logger(), inject(KwargsLocation(), () -> (:timestamp => now(),)))

# Migrate all kwargs to the message string
logger = build(current_logger(), migrate(KwargsProperty(), MessageProperty()))
```

## Credits

This package was originally conceived as part of [this coding live stream](https://www.youtube.com/watch?v=89xlkSUh_dA). Special credit to [Chris de Graff](https://github.com/christopher-dG) for joining
the live stream and helping out.

It has been redesigned significantly since v0.2.0.

