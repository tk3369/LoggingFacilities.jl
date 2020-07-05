module LoggingFacilities

using Logging
using LoggingExtras
using Dates
using JSON
using Pipe
using TimeZones

export  build, migrate, inject, remove,
        KwargsProperty, MessageProperty, LevelProperty,
        LevelLocation, KwargsLocation, BeginningMessageLocation, EndingMessageLocation, WholeMessageLocation,
        OneLineTransformerLogger, TimestampTransformerLogger, JSONTransformerLogger,
        SimplestLogger

include("types.jl")
include("transform.jl")
include("build.jl")
include("common.jl")
include("sink.jl")

end #module
