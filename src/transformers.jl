# Logging Transformers - utilize TransformerLogger to tweak ouptut

abstract type AbstractLoggingTransformer end

"""
    logger(::AbstractLogger, transformer, [transformer2, ...])

Returns a logger that uses the specified logging transformers.  The transformers
are applied in the same order that it is specified.

See also:
- [`TimestampLoggingTransformer`](@ref)
- [`OneLineLoggingTransformer`](@ref)
- [`JSONLoggingTransformer`](@ref)
"""
logger

# chain transformers
logger(L, args...) = logger(logger(L, args[end]), args[1:end-1]...)

# --------------------------------------------------------------------------------
# TimestampLoggingTransformer

abstract type InjectLocation end
struct InjectByPrependingToMessage <: InjectLocation end
struct InjectByAddingToKwargs <: InjectLocation end

struct TimestampLoggingTransformer{T <: DateFormat, S <: InjectLocation}
    date_format::T
    location::S
end

TimestampLoggingTransformer(fmt::AbstractString, location) =
    TimestampLoggingTransformer(DateFormat(fmt), location)

function logger(L::AbstractLogger, fmt::TimestampLoggingTransformer)
    return TransformerLogger(L) do log
        formatted_datetime = Dates.format(now(), fmt.date_format)
        inject_log(log, formatted_datetime, fmt.location)
    end
end

function inject_log(log, ts::AbstractString, location::InjectByPrependingToMessage)
    # println("Applying TimestampLoggingTransformer: InjectByPrependingToMessage")
    return merge(log, (; message = "$ts $(log.message)"))
end

function inject_log(log, ts::AbstractString, location::InjectByAddingToKwargs)
    # println("Applying TimestampLoggingTransformer: InjectByAddingToKwargs")
    updated_kwargs = (:timestamp => ts, log.kwargs...)
    return merge(log, (; kwargs = updated_kwargs))
end

# --------------------------------------------------------------------------------
# OneLineLoggingTransformer

struct OneLineLoggingTransformer
end

function logger(L::AbstractLogger, fmt::OneLineLoggingTransformer)
    return TransformerLogger(L) do log
        # println("Applying OneLineLoggingTransformer")
        kw_string = join(["$(kv[1])=$(kv[2])" for kv in log.kwargs], " ")
        return merge(log, (;message = "$(log.message) $kw_string", kwargs = ()))
    end
end

# --------------------------------------------------------------------------------
# JSONLoggingTransformer

Base.@kwdef struct JSONLoggingTransformer
    indent::Union{Nothing,Int} = nothing
end

function logger(L::AbstractLogger, fmt::JSONLoggingTransformer)
    return TransformerLogger(L) do log
        # println("Applying JSONLoggingTransformer")
        dct = Dict{Any,Any}(log.kwargs)
        push!(dct, :message => log.message)
        push!(dct, :level => string(log.level))
        kw_string = fmt.indent === nothing ? json(dct) : json(dct, fmt.indent)
        return merge(log, (;message = chomp(kw_string), kwargs = ()))
    end
end

