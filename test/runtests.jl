using LoggingFacilities
using Logging
using Test

# TODO needs work here

@testset "LoggingFacilities.jl" begin

    ts_fmt = TimestampLoggingFormat("Y-m-d H:M:S", InjectByPrependingToMessage());
    with_logger(logger(ConsoleLogger(), ts_fmt)) do
        @info "hey there"
    end

    oneline_fmt = OneLineLoggingFormat();
    with_logger(logger(ConsoleLogger(), oneline_fmt)) do
        x = 1
        y = "abc"
        @info "hey there" x y
    end

    js_fmt = JSONLoggingFormat(2)
    ts_fmt = TimestampLoggingFormat("Y-m-d H:M:S", InjectByAddingToKwargs())
    json_logger = logger(logger(SimplestLogger(), js_fmt), ts_fmt)
    with_logger(json_logger) do
        x = 1
        y = "abc"
        z = 36.55
        @info "hey" x y z
        @warn "blah"
        @error "cool"
    end

    @test 1 == 1

end
