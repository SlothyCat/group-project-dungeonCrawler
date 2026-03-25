---
title: "Level State Management"
description: "How global level data is stored and queried via the ECS."
---

# Level State Management

The level's state is not stored inside services like `LevelOrchestrator`. Instead, it is stored within the ECS World using the **`LevelStateComponent`**. This ensures that any system in the game can query the current level's topology and the player's active location without needing a reference to an external service.

## `LevelStateComponent` (The Ground Truth)

The `LevelStateComponent` is a singleton-like component attached to a global entity in the ECS world. It serves as the single authoritative source for the following data:

| Property | Purpose |
|---|---|
| `graph` | An optional `DungeonGraph` containing the full level layout (rooms and connections). |
| `activeNodeID` | The ID of the room where the player is currently located. |
| `transitionCooldown` | A floating-point timer used by the `LevelTransitionSystem` to prevent immediate re-triggers. |

### Lifecycle of the State
1. **Creation**: When `LevelOrchestrator.loadLevel()` is called, it initializes the `LevelStateComponent` with the newly generated `DungeonGraph`.
2. **Updates**: The `LevelTransitionSystem` and `LevelOrchestrator` both modify this component as the player navigates the world.
3. **Consumption**: Any system (e.g., Minimap, AI, Sound Manager) can query the `activeNodeID` to tailor its behavior based on the current room's context.

---

## The Benefits of ECS State
By storing the level topology in the ECS:
- **Save/Load Readiness**: The `LevelStateComponent` can be serialized as part of the ECS world's state, making it easier to implement game-saving functionality.
- **System Isolation**: Systems like `LevelTransitionSystem` don't need to know about the `LevelOrchestrator`'s internals; they only need to know how to read the `LevelStateComponent` and compare it against the player's transform.
- **Reactivity**: Adding or removing tags (like `RoomInCombatTag`) to room entities informs other systems about the room's current gameplay status without imperative function calls.
