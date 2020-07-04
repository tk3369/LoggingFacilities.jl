abstract type InjectLocation end

abstract type MessageLocation <: InjectLocation end
struct BeginningMessageLocation <: MessageLocation end
struct EndingMessageLocation <: MessageLocation end

struct KwargsLocation <: InjectLocation end

abstract type LogProperty end
struct LevelProperty <: LogProperty end
struct MessageProperty <: LogProperty end
struct KwargsProperty <: LogProperty end
