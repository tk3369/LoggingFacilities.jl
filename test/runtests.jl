using LoggingFacilities
using Test

using Logging
using JSON
using Dates

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
        logger = build(SimpleLogger(io), inject(BeginningMessageLocation(),
                                              () -> Dates.format(now(), "yyyy-mm-dd HH:MM:SS")))
        with_logger(logger) do
            @info "hey there"
        end
        logs = String(take!(io)) |> chomp
        @test match(r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}", logs) !== nothing
    end

    # Validate there's only a single line
    let
        io = IOBuffer()
        logger = build(SimplestLogger(io), migrate(KwargsProperty(), MessageProperty()))
        with_logger(logger) do
            x = 1
            y = "abc"
            @info "hey there" x y
        end
        logs = String(take!(io)) |> chomp
        @test findall(x -> x == '\n', logs) |> length == 0
    end

    # Verify valid JSON
    let
        io = IOBuffer()
        json_logger = build(SimplestLogger(io),
                            migrate(LevelProperty(), KwargsProperty()),
                            migrate(MessageProperty(), KwargsProperty()),
                            migrate(KwargsProperty(), MessageProperty();
                                    transform = x -> chomp(json(x, 2)), prepend = ""))
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
