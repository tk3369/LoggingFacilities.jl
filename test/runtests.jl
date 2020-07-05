using LoggingFacilities
using Test

using Logging
using JSON
using Dates

@testset "LoggingFacilities.jl" begin

    log1() = (level = Logging.Info, message = "hello", kwargs = ())
    log2() = (level = Logging.Info, message = "", kwargs = (:a => 1,))
    log3() = (level = Logging.Info, message = "hello", kwargs = (:a => 1, :b => 2))

    @testset "Inject" begin

        @testset "Message Location" begin
            # test all locations
            @test inject(log1(), BeginningMessageLocation(), 1).message == "1 hello"
            @test inject(log1(), EndingMessageLocation(), 1).message    == "hello 1"
            @test inject(log1(), WholeMessageLocation(), 1).message     == "1"

            # message separator for beginning/ending message location
            @test inject(log1(), BeginningMessageLocation(), 1; sep="").message == "1hello"
            @test inject(log1(), EndingMessageLocation(), 1; sep="").message    == "hello1"

            # callable
            @test inject(log1(), WholeMessageLocation(), () -> 2).message == "2"
        end

        @testset "Kwargs Location" begin
            # inject into empty kwargs (non-callable and callable)
            @test inject(log1(), KwargsLocation(), [:a => 1]).kwargs == (:a => 1,)
            @test inject(log1(), KwargsLocation(), () -> [:a => 1]).kwargs == (:a => 1,)

            # inject into non-empty kwargs
            @test inject(log2(), KwargsLocation(), [:b => 2]).kwargs |> length == 2

            # merged with same key (expectation: does not dedup)
            @test inject(log2(), KwargsLocation(), [:a => 2]).kwargs |> length == 2
        end

        @testset "Level Location" begin
            @test inject(log1(), LevelLocation(), Logging.Error).level == Logging.Error
        end
    end

    @testset "Remove" begin
        @test remove(log1(), MessageProperty()).message == ""
        @test remove(log1(), KwargsProperty()).kwargs |> length == 0
        @test_throws ErrorException remove(log1(), LevelProperty())
    end

    @testset "Migrate" begin
        # message => kwargs
        @test migrate(log1(), MessageProperty(), KwargsProperty()).kwargs[1] |> first == :message
        @test migrate(log1(), MessageProperty(), KwargsProperty()).kwargs[1] |> last  == "hello"

        # kwargs => message
        @test migrate(log2(), KwargsProperty(), MessageProperty()).message == "a=1"
        @test migrate(log2(), KwargsProperty(), MessageProperty()).message == "a=1"
        @test migrate(log3(), KwargsProperty(), MessageProperty()).message == "hello a=1 b=2"
        @test migrate(log3(), KwargsProperty(), MessageProperty(); sep=":").message == "hello a:1 b:2"
        @test migrate(log3(), KwargsProperty(), MessageProperty(); divider="_").message == "hello a=1_b=2"
        @test migrate(log3(), KwargsProperty(), MessageProperty(); prepend="|").message == "hello|a=1 b=2"
        @test migrate(log3(), KwargsProperty(), MessageProperty(); transform = string).message == "hello (:a => 1, :b => 2)"

        # level => message
        @test migrate(log1(), LevelProperty(), MessageProperty()).message == "Info hello"
        @test migrate(log1(), LevelProperty(), MessageProperty(); location = BeginningMessageLocation()).message == "Info hello"
        @test migrate(log1(), LevelProperty(), MessageProperty(); location = EndingMessageLocation()).message == "hello Info"
        @test migrate(log1(), LevelProperty(), MessageProperty(); transform = (level) -> uppercase(string(level))).message == "INFO hello"

        # level => kwargs
        @test migrate(log1(), LevelProperty(), KwargsProperty()).kwargs == (:level => Logging.Info,)
        @test migrate(log1(), LevelProperty(), KwargsProperty(); label = :_level).kwargs == (:_level => Logging.Info,)
        @test migrate(log1(), LevelProperty(), KwargsProperty(); transform = string).kwargs == (:level => "Info",)
    end

    @testset "One Line Logger" begin
        logs, value = Test.collect_test_logs() do
            with_logger(OneLineTransformerLogger(current_logger())) do
                x = 1
                y = 2
                @info "hello" x y
            end
        end
        @test logs[1].message == "hello x=1 y=2"
        @test logs[1].kwargs |> length == 0
        @test logs[1].level == Logging.Info
    end

    @testset "Timestamp Logger" begin
        logs, value = Test.collect_test_logs() do
            with_logger(TimestampTransformerLogger(current_logger(), BeginningMessageLocation();
                                                   format = "yyyy-mm-dd")) do
                @info "hello"
            end
            with_logger(TimestampTransformerLogger(current_logger(), EndingMessageLocation();
                                                   format = "yyyy-mm-dd")) do
                @info "hello"
            end
        end
        is_date_format(s) = match(r"\d\d\d\d-\d\d-\d\d", s) !== nothing
        @test logs[1].message[1:10]      |> is_date_format == true
        @test logs[2].message[end-9:end] |> is_date_format == true
    end

    @testset "JSON Logger" begin
        logs, value = Test.collect_test_logs() do
            with_logger(() -> @info("hello"), JSONTransformerLogger(current_logger()))
            with_logger(() -> @info("hello"), JSONTransformerLogger(current_logger(); level_label = :LEVEL))
            with_logger(() -> @info("hello"), JSONTransformerLogger(current_logger(); message_label = :MSG))
            with_logger(() -> @info("hello"), JSONTransformerLogger(current_logger(); indent = 2))
        end
        # parsable
        foreach(log -> @test_nowarn(JSON.Parser.parse(log.message)), logs)

        let d = JSON.Parser.parse(logs[1].message)
            @test d["message"] == "hello"
            @test d["level"] == "Info"
        end

        let d = JSON.Parser.parse(logs[2].message)
            @test d["message"] == "hello"
            @test d["LEVEL"] == "Info"
        end

        let d = JSON.Parser.parse(logs[3].message)
            @test d["MSG"] == "hello"
            @test d["level"] == "Info"
        end

        @test split(logs[4].message, "\n") |> length == 4
    end

end
