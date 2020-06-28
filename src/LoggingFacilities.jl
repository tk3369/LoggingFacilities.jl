module LoggingFacilities

using Logging
using LoggingExtras
using Dates
using JSON

using Logging: Info

export TimestampTransform, OneLineTransform, JSONTransform, LevelAsVarTransform
export logger
export SimplestLogger
export InjectByPrependingToMessage, InjectByAddingToKwargs

include("transformers.jl")
include("simplest_logger.jl")

end #module
