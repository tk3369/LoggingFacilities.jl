using LoggingFacilities
using Logging

# Add some colors to the log

preferred_colors = Dict(
    Logging.Debug => ColorSpec(:grey, false),
    Logging.Info  => ColorSpec(:cyan, true),
    Logging.Warn  => ColorSpec(:yellow, true),
    Logging.Error => ColorSpec(:red, true),
)

clogger = ColorMessageTransformerLogger(current_logger(), preferred_colors);

with_logger(clogger) do
    x = 1; y = rand(); z = "Ryan"
    @info "hello world" x y
    @warn "pay attention!" y z
    @error "what!" x z
end

# Compose existing transformer loggers

normal_colors = Dict(
    Logging.Debug => ColorSpec(:light_black, false),
    Logging.Info  => ColorSpec(:cyan, false),
    Logging.Warn  => ColorSpec(:yellow, false),
    Logging.Error => ColorSpec(:red, false),
)

combo_logger = compose(
    MessageOnlyLogger(stderr, Logging.Debug),
    TimestampTransformerLogger(BeginningMessageLocation()),
    OneLineTransformerLogger,
    ColorMessageTransformerLogger(normal_colors)
)

with_logger(combo_logger) do
    x = 1; y = rand(); z = "Ryan"
    @debug "hey there"
    @info "hello world" x y
    @warn "pay attention!" y z
    @error "what!" x z
end
