"""
    build(logger::AbstractLogger, operations...)

Build a transformer logger from the sepcified transform `operations`.
"""
function build(logger::AbstractLogger, operations...)
    first_logger = TransformerLogger(operations[end], logger)
    if length(operations) > 1
        build(first_logger, operations[1:end-1]...)
    else
        first_logger
    end
end
