using LoggingFacilities

using Logging: ConsoleLogger, with_logger
using Dates: now
using JSON: json

# oneline
oneline_logger(logger) = build(logger, migrate(KwargsProperty(), MessageProperty()))
with_logger(oneline_logger(ConsoleLogger())) do
    x = 1; y = 2; @info "hello world" x y
end

# timestamp (kwargs)
timestamp_kwargs_logger(logger) = build(logger, inject(KwargsLocation(), () -> (:timestamp => now(),)))
with_logger(timestamp_kwargs_logger(ConsoleLogger())) do
    x = 1; y = 2; @info "hello world" x y
end

# timestamp (message)
timestamp_message_logger(logger) = build(logger, inject(BeginningMessageLocation(), () -> now()))
with_logger(timestamp_message_logger(ConsoleLogger())) do
    x = 1; y = 2; @info "hello world" x y
end

# json
json_logger = build(SimplestLogger(),
                    migrate(LevelProperty(), KwargsProperty()),
                    migrate(MessageProperty(), KwargsProperty()),
                    migrate(KwargsProperty(), MessageProperty();
                                transform = x -> chomp(json(x, 2)), prepend = ""))

with_logger(json_logger) do
    x = 1; y = 2; current_time = now()
    @info "hello world" x y
    @info "cool" current_time
end

# kitchen sink
logger = build(ConsoleLogger(),
               inject(BeginningMessageLocation(), () -> now()),
               inject(KwargsLocation(), Dict(:a => 1, :b => 2)),
               remove(MessageProperty()),
               inject(BeginningMessageLocation(), "cool"),
               migrate(KwargsProperty(), MessageProperty()),
               migrate(LevelProperty(), KwargsProperty()),
               inject(KwargsLocation(), Dict(:c => 3)),
               migrate(MessageProperty(), KwargsProperty())
               );

with_logger(logger) do
    @info "hello world"
end
