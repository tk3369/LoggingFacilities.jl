using LoggingFacilities
using Logging
using JSON
using Test

@testset "LoggingFacilities.jl" begin

    # The SimplestLogger should log nothing but the message itself
    let
        io = IOBuffer()
        with_logger(SimplestLogger(io)) do
            @info "hey there"
        end
        @test String(take!(io)) |> chomp == "hey there"
    end

    # Validate timestamp is printed at the beginning of line
    let
        io = IOBuffer()
        ts_fmt = TimestampLoggingTransformer("yyyy-mm-dd HH:MM:SS", InjectByPrependingToMessage())
        with_logger(logger(SimplestLogger(io), ts_fmt)) do
            @info "hey there"
        end
        logs = String(take!(io)) |> chomp
        @test match(r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}", logs) !== nothing
    end

    # Validate there's only a single line printed
    let
        io = IOBuffer()
        oneline_fmt = OneLineLoggingTransformer()
        with_logger(logger(SimplestLogger(io), oneline_fmt)) do
            x = 1
            y = "abc"
            @info "hey there" x y
        end
        logs = String(take!(io)) |> chomp
        @test findall("\n", logs) |> length == 0
    end

    # Verify valid JSON
    let
        io = IOBuffer()
        js_fmt = JSONLoggingTransformer(2)
        json_logger = logger(SimplestLogger(io), js_fmt)
        with_logger(json_logger) do
            x = 1
            y = "abc"
            z = 36.55
            @info "hey" x y z
        end
        logs = String(take!(io))
        @test JSON.Parser.parse(logs) isa Any
    end
end
