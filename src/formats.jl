abstract type InjectLocation end
struct InjectByPrependingToMessage <: InjectLocation end
struct InjectByAddingToKwargs <: InjectLocation end

# const date_format = "yyyy-mm-dd HH:MM:SS"
struct TimestampLoggingFormat{T <: DateFormat, S <: InjectLocation}
    date_format::T
    location::S
end

TimestampLoggingFormat(fmt::AbstractString, location) = 
    TimestampLoggingFormat(DateFormat(fmt), location)

function logger(L::AbstractLogger, fmt::TimestampLoggingFormat)
    return TransformerLogger(L) do log
        formatted_datetime = Dates.format(now(), fmt.date_format)
        inject_log(log, formatted_datetime, fmt.location)
    end
end

function inject_log(log, ts::AbstractString, location::InjectByPrependingToMessage)
    return merge(log, (; message = "$ts $(log.message)"))
end

function inject_log(log, ts::AbstractString, location::InjectByAddingToKwargs)
    updated_kwargs = (:timestamp => ts, log.kwargs...)
    return merge(log, (; kwargs = updated_kwargs))
end

struct OneLineLoggingFormat
end

function logger(L::AbstractLogger, fmt::OneLineLoggingFormat)
    return TransformerLogger(L) do log
        kw_string = join(["$(kv[1])=$(kv[2])" for kv in log.kwargs], " ")
        return merge(log, (;message = "$(log.message) $kw_string", kwargs = ()))
    end 
end

struct JSONLoggingFormat
    indent::Union{Nothing,Int}
end

function logger(L::AbstractLogger, fmt::JSONLoggingFormat)
    return TransformerLogger(L) do log
        dct = Dict{Any,Any}(log.kwargs)
        push!(dct, :message => log.message)
        push!(dct, :level => string(log.level))
        kw_string = fmt.indent === nothing ? json(dct) : json(dct, fmt.indent)
        return merge(log, (;message = "$kw_string", kwargs = ()))
    end 
end

