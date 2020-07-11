using LoggingFacilities
using Logging

logger = compose(
    current_logger(),
    logger -> FixedMessageWidthTransformerLogger(logger, 40),
    OneLineTransformerLogger,
)

with_logger(logger) do
    for i in 1:10
        x = round(rand(), digits = 10)
        y = round(rand(), digits = 10)
        @info "Iteration #$i" x y
    end
end

#=
[ Info: Iteration #1                             x=0.5674366266778048 y=0.9024632811266229
[ Info: Iteration #2                             x=0.7070619211896252 y=0.44200367657577777
[ Info: Iteration #3                             x=0.034904964067742794 y=0.09434400347104588
[ Info: Iteration #4                             x=0.38486209773503965 y=0.023043539047058914
[ Info: Iteration #5                             x=0.8135371107442477 y=0.9173422607084372
[ Info: Iteration #6                             x=0.9445325770356989 y=0.3864405581804362
[ Info: Iteration #7                             x=0.850683727155505 y=0.6299730919535942
[ Info: Iteration #8                             x=0.09683784334946521 y=0.9662550162409316
[ Info: Iteration #9                             x=0.7733711241925625 y=0.7778339378610857
[ Info: Iteration #10                            x=0.13435678232322879 y=0.546560581934818
=#
