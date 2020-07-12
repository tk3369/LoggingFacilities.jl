module LoggingFacilities

using Logging
using LoggingExtras
using Dates
using JSON
using Pipe
using TimeZones

export  migrate, inject, remove, mutate, compose,
        KwargsProperty, MessageProperty, LevelProperty,
        LevelLocation, KwargsLocation, BeginningMessageLocation, EndingMessageLocation, WholeMessageLocation,
        OneLineTransformerLogger, TimestampTransformerLogger, JSONTransformerLogger,
        ColorMessageTransformerLogger, ColorSpec,
        FixedMessageWidthTransformerLogger,
        MessageOnlyLogger

include("types.jl")
include("transform.jl")
include("common.jl")
include("sink.jl")

end #module
