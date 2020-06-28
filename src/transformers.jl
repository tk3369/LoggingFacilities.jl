# Logging Transformers - utilize TransformerLogger to tweak ouptut

abstract type AbstractLoggingTransformer end

"""
    logger(::AbstractLogger, transformer, [transformer2, ...])

Returns a logger that uses the specified logging transformers.  The transformers
are applied in the same order that it is specified.  After transformations are
finished, the log record is fed into the provided logger.

See also:
- [`TimestampTransform`](@ref)
- [`OneLineTransform`](@ref)
- [`LevelToVarTransform`](@ref)
- [`JSONTransform`](@ref)
"""
logger

# chain transformers
logger(L, args...) = logger(logger(L, args[end]), args[1:end-1]...)

# TimestampTransform

abstract type InjectLocation end
struct InjectByPrependingToMessage <: InjectLocation end
struct InjectByAddingToKwargs <: InjectLocation end

"""
    TimestampTransform

Add a timestamp to the log record.  The timestamp may be injected in one
of the following locations:
- Prepend to the beginning of the `message` string
- Add as a new `kwargs` variable
"""
struct TimestampTransform{T <: DateFormat, S <: InjectLocation}
    format::T
    location::S
    label::Symbol
end

function TimestampTransform(;format::AbstractString, location::InjectLocation, label = :timestamp)
    return TimestampTransform(DateFormat(format), location, label)
end

function logger(L::AbstractLogger, fmt::TimestampTransform)
    return TransformerLogger(L) do log
        formatted_datetime = Dates.format(now(), fmt.format)
        inject_log(log, formatted_datetime, fmt.location)
    end
end

function inject_log(log, ts::AbstractString, location::InjectByPrependingToMessage)
    # println("Applying TimestampTransform: InjectByPrependingToMessage")
    return merge(log, (message = "$ts $(log.message)",))
end

function inject_log(log, ts::AbstractString, location::InjectByAddingToKwargs)
    # println("Applying TimestampTransform: InjectByAddingToKwargs")
    updated_kwargs = (:timestamp => ts, log.kwargs...)
    return merge(log, (kwargs = updated_kwargs,))
end

"""
    OneLineTransform

Format the log record as a single line.  It basically convert all kwargs
variables into key=value pairs and append them to the `message` string.
"""
struct OneLineTransform
end

function logger(L::AbstractLogger, fmt::OneLineTransform)
    return TransformerLogger(L) do log
        # println("Applying OneLineTransform")
        kw_string = join(["$(kv[1])=$(kv[2])" for kv in log.kwargs], " ")
        return merge(log, (message = "$(log.message) $kw_string", kwargs = ()))
    end
end

"""
    LevelAsVarTransform

Migrate log level to the log record's variables.
"""
Base.@kwdef struct LevelAsVarTransform
    label::Symbol = :level
end

function logger(L::AbstractLogger, fmt::LevelAsVarTransform)
    return TransformerLogger(L) do log
        updated_kwargs = (fmt.label => string(log.level), log.kwargs...)
        merge(log, (kwargs = updated_kwargs,))
    end
end

"""
    JSONTransform

Format log record as a JSON string, which includes all kwargs variables.
The message string is included as well, with `message` as the key of
the entry.

# Fields
- `indent`: greater than 0 would pretty-format the message as multiple lines
- `label`: custom key for the `message` string
"""
Base.@kwdef struct JSONTransform
    indent::Union{Nothing,Int} = nothing
    label::Symbol = :message
end

function logger(L::AbstractLogger, fmt::JSONTransform)
    return TransformerLogger(L) do log
        dct = Dict{Any,Any}(log.kwargs)
        push!(dct, fmt.label => log.message)
        kw_string = fmt.indent === nothing ? json(dct) : json(dct, fmt.indent)
        return merge(log, (;message = chomp(kw_string), kwargs = ()))
    end
end

