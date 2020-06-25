module LoggingFacilities

using Logging
using LoggingExtras
using Dates
using JSON

using Logging: Info

export TimestampLoggingTransformer, OneLineLoggingTransformer, JSONLoggingTransformer
export logger
export SimplestLogger
export InjectByPrependingToMessage, InjectByAddingToKwargs

include("transformers.jl")
include("simplest_logger.jl")

end #module
