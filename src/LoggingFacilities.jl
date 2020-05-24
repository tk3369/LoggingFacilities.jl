module LoggingFacilities

using Logging
using LoggingExtras
using Dates
using JSON

using Logging: Info

export TimestampLoggingFormat, OneLineLoggingFormat, JSONLoggingFormat
export logger
export SimplestLogger
export InjectByPrependingToMessage, InjectByAddingToKwargs

include("formats.jl")
include("simple.jl")

end #module
