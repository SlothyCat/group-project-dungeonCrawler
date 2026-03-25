---
title: "Level Components"
description: "ECS components used for level and room metadata."
---

# Level Components

The dungeon's structure and state are mapped to the ECS using several key components.

## `LevelStateComponent`
A global component that acts as the "Ground Truth" for the entire level.
- **`graph`**: The `DungeonGraph` structure.
- **`activeNodeID`**: The current room where the player is located.
- **`transitionCooldown`**: Prevents rapid room re-triggers.

## `RoomMetadataComponent`
Attached to each room entity to describe its specific geometry and spawn logic.
- **`roomID`**: Unique identifier (matches the graph's node ID).
- **`bounds`**: The `RoomBounds` defining the room's rectangle in world space.
- **`doorways`**: A collection of `Doorway` connections.
- **`spawnPoints`**: A list of `SpawnPoint` data for player and enemy spawning.

## `RoomMemberComponent`
Tag used to associate entities (walls, floors, enemies, etc.) with a specific room.
- **Purpose**: Allows the `LevelOrchestrator` to perform global cleanup and lifecycle management.
- **Data**: Stores the `roomID` (UUID) matching the room's metadata.

---

## Supporting Data Types

### `RoomBounds`
Describes a rectangular area in world coordinates.
- **`origin`**: Bottom-left corner.
- **`size`**: Width and height.
- **`contains(_ point:)`**: Robust spatial check for navigation.

### `Doorway`
Describes an exit or entry point.
- **`direction`**: Cardinal direction (North, South, East, West).
- **`position`**: World position for alignment.
- **`isLocked`**: UI and navigation constraint.

### `SpawnPoint`
Marks a specific location for entity generation.
- **`type`**: `playerEntry` or `enemy`.
- **`isUsed`**: Tracking for one-time spawns.
