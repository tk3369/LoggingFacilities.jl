# LoggingFacilities

This package contains some general logging facilities.  It uses the [LoggingExtras.jl](https://github.com/oxinabox/LoggingExtras.jl) framework for building composable loggers.

Sink
- `SimplestLogger`, which is simpler than the SimpleLogger from Base :-)

Logging Formats
- `TimestampLoggingFormat`: either prepend to `message` string or added as a variables
- `OneLineLoggingFormat`: append `variable=value` pairs to the `message` string
- `JSONLoggingFormat`: format log as JSON string

## Usage

Use the `logger` function to create new Transformer logger with the desired format.

### Logging with timestamp

```julia
julia> ts_fmt = TimestampLoggingFormat("yyyy-mm-dd HH:MM:SS", InjectByPrependingToMessage());

julia> with_logger(logger(ConsoleLogger(), ts_fmt)) do
           @info "hey there"
       end
[ Info: 2020-06-13 21:39:13 hey there
```

### Logging everything in a single line

```julia
julia> oneline_fmt = OneLineLoggingFormat();

julia> with_logger(logger(ConsoleLogger(), oneline_fmt)) do
           x = 1
           y = "abc"
           @info "hey there" x y
       end
[ Info: hey there x=1 y=abc
```

### Logging JSON string

```julia
js_fmt = JSONLoggingFormat(2)
ts_fmt = TimestampLoggingFormat("yyyy-mm-dd HH:MM:SS", InjectByAddingToKwargs())
json_logger = logger(logger(SimplestLogger(), js_fmt), ts_fmt)
```

_Voila!_

```julia
julia> with_logger(json_logger) do
           x = 1
           y = "abc"
           z = 36.55
           @info "hey" x y z
           @warn "blah"
           @error "cool"
       end
julia> with_logger(json_logger) do
           x = 1
           y = "abc"
           z = 36.55
           @info "hey" x y z
           @warn "blah"
           @error "cool"
       end
{
  "timestamp": "2020-06-13 21:40:30",
  "level": "Info",
  "y": "abc",
  "message": "hey",
  "z": 36.55,
  "x": 1
}

{
  "timestamp": "2020-06-13 21:40:30",
  "level": "Warn",
  "message": "blah"
}

{
  "timestamp": "2020-06-13 21:40:30",
  "level": "Error",
  "message": "cool"
}
```

## Credits

This package was conceived part of [this coding live stream](https://www.youtube.com/watch?v=89xlkSUh_dA).

Special credit to [Chris de Graff](https://github.com/christopher-dG) for joining
the stream and helping out.
