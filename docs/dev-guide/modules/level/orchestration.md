---
title: "Level Orchestration"
description: "How levels are loaded, managed, and navigated."
---

# Level Orchestration

Level Orchestration handles the lifecycle of the game world—from building the initial layout to detecting player transitions between rooms.

## The Orchestrator (`LevelOrchestrator`)

The `LevelOrchestrator` is a central service (not an ECS System) responsible for imperative world changes. It manages the loading and teardown of levels.

### Key Responsibilities
- **`loadLevel(_:world:)`**: Builds the entire level geometry (rooms and corridors) based on a layout strategy and stores the resulting `DungeonGraph` in the ECS `LevelStateComponent`.
- **`transition(to:world:)`**: Handles the logic for moving the player between rooms, updating the active room ID, and triggering state-based events (like locking doors).
- **`tearDownAll()`**: Clears all level-related entities and resets the global state.

---

## Navigation & Transitions (`LevelTransitionSystem`)

While the orchestrator handles the *process* of a transition, the `LevelTransitionSystem` is responsible for *detecting* it.

### The AABB Check
The system runs every frame and performs an Axis-Aligned Bounding Box (AABB) intersection check:
1. It queries the `LevelStateComponent` for the current `activeNodeID` and the `DungeonGraph`.
2. It retrieves the neighboring room specifications from the graph.
3. If the Player's `TransformComponent.position` is contained within a neighbor's `RoomBounds`, it invokes `orchestrator.transition(to:world:)`.

### Transition Cooldown
A fixed cooldown (defined in `WorldConstants.transitionCooldown`) prevents "flickering" between two adjacent rooms. When a transition occurs, the player is typically spawned with a slight inset (`WorldConstants.roomEntryInset`) to ensure they are safely inside the new room's detection zone.

---

## Room Cleanup
The orchestrator leverages the ECS `World` for cleanup. Every entity associated with the level state (walls, floors, etc.) is tagged with a `RoomMemberComponent(roomID:)`. When a level is reset or torn down, the orchestrator queries all entities with this component and destroys them globally during `tearDownAll()`.

> [!TIP]
> This approach ensures that the ECS remains the single source of truth—if an enemy is killed mid-combat, its entity is automatically removed from the world, and the orchestrator doesn't need to maintain a separate list of objects to clean up.
