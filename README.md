[![Travis Build Status](https://travis-ci.org/tk3369/LoggingFacilities.jl.svg?branch=master)](https://travis-ci.org/tk3369/LoggingFacilities.jl)
[![codecov.io](http://codecov.io/github/tk3369/LoggingFacilities.jl/coverage.svg?branch=master)](http://codecov.io/github/tk3369/LoggingFacilities.jl?branch=master)
![Project Status](https://img.shields.io/badge/status-experimental-red)

# LoggingFacilities

This package contains some general logging facilities.
It uses the [LoggingExtras.jl](https://github.com/oxinabox/LoggingExtras.jl)
framework for building composable loggers.

Sink
- `SimplestLogger`, which is simpler than the SimpleLogger from Base :-)

Transforms
- `TimestampTransform`: prepend timestamp to `message` string or add to the variables list
- `OneLineTransform`: convert variables as `variable=value` and append to the `message` string
- `LevelToVarTransform`: copy the level string to the variable list
- `JSONTransform`: reformat log message as a JSON record

## Usage

Use the `logger` function to create new Transformer logger with the desired format.

### Logging with timestamp

```julia
julia> ts_fmt = TimestampTransform(format = "yyyy-mm-dd HH:MM:SS",
                                   location = InjectByPrependingToMessage());

julia> with_logger(logger(ConsoleLogger(), ts_fmt)) do
           @info "hey there"
       end
[ Info: 2020-06-13 21:39:13 hey there
```

### Logging everything in a single line

```julia
julia> oneline_fmt = OneLineTransform();

julia> with_logger(logger(ConsoleLogger(), oneline_fmt)) do
           x = 1
           y = "abc"
           @info "hey there" x y
       end
[ Info: hey there x=1 y=abc
```

### Logging JSON string

```julia
json_logger = logger(
                SimplestLogger(),
                TimestampTransform(format = "yyyy-mm-dd HH:MM:SS",
                                   location = InjectByAddingToKwargs()),
                JSONTransform(indent = 2))
```

_Voila!_

```julia
julia> with_logger(json_logger) do
           @info "hey"
           @info "great!"
       end
{
  "timestamp": "2020-06-27 21:45:00",
  "level": "Info",
  "message": "hey"
}
{
  "timestamp": "2020-06-27 21:45:01",
  "level": "Info",
  "message": "great!"
}
```

## Credits

This package was conceived as part of [this coding live stream](https://www.youtube.com/watch?v=89xlkSUh_dA).

Special credit to [Chris de Graff](https://github.com/christopher-dG) for joining
the stream and helping out.
