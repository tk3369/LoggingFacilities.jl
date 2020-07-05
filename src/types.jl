"""
    AbstractInjectLocation

An abstract type that represents all inject locations. The type hierarchy
is as follows:

```
AbstractInjectLocation
   |_ LevelLocation
   |_ KwargsLocation
   |_ MessageLocation
         |_ BeginningMessageLocation
         |_ EndingMessageLocation
         |_ WholeMessageLocation
```
"""
abstract type AbstractInjectLocation end

struct LevelLocation <: AbstractInjectLocation end

abstract type MessageLocation <: AbstractInjectLocation end
struct BeginningMessageLocation <: MessageLocation end
struct EndingMessageLocation <: MessageLocation end
struct WholeMessageLocation <: MessageLocation end

struct KwargsLocation <: AbstractInjectLocation end

"""
    AbstractLogProperty

An abstract type that represents all log properties.

```
AbstractLogProperty
   |_ LevelProperty
   |_ MessageProperty
   |_ KwargsProperty
```
"""
abstract type AbstractLogProperty end
struct LevelProperty <: AbstractLogProperty end
struct MessageProperty <: AbstractLogProperty end
struct KwargsProperty <: AbstractLogProperty end
