module LoggingFacilities

using Logging
using LoggingExtras
using Dates
using JSON
using Pipe

export  build, migrate, inject, remove,
        KwargsProperty, MessageProperty, LevelProperty,
        KwargsLocation, BeginningMessageLocation, EndingMessageLocation,
        SimplestLogger

include("types.jl")
include("transformers.jl")
include("simplest_logger.jl")

end #module
