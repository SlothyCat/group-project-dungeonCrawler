---
title: "Dungeon Generation"
description: "Architecture and design rationale for procedural dungeon generation."
---

# Dungeon Generation

## Design Overview

The dungeon generation system produces a procedurally-connected set of rooms for each level. It is organized into three independent layers:

```
Layer 1 — DungeonLayoutStrategy    Whole Dungeon: topology (which rooms exist, how they connect)
Layer 2 — RoomConstructor          Room Specific: geometry (walls, floor, obstacles per room)
Layer 3 — LevelOrchestrator        Orchestration: ECS lifecycle (load, build, transition, cleanup)
```

Each layer is an extension point. Swapping the layout algorithm or construction style means providing a new conforming type—the orchestration layer (`LevelOrchestrator`) requires no changes.

### Top-Level Organization

| File | Layer | Role |
|---|---|---|
| `Level/Layout/DungeonLayoutStrategy.swift` | Framework | Protocol: produces a `DungeonGraph` |
| `Level/Construction/RoomConstructor.swift` | Framework | Protocol: fills one room with ECS geometry |
| `Level/Construction/RoomBuilder.swift` | Framework | Helper: emits standard floor/wall entities |
| `Level/Structure/DungeonGraph.swift` | Framework | ADT: `DungeonNode`, `DungeonEdge`, `DungeonGraph` |
| `Level/Structure/RoomPopulatorStrategy.swift` | Framework | Protocol: strategy for spawning gameplay entities |
| `Level/Structure/RoomSpecification.swift` | Framework | Pure-data room description with `RoomPopulatorStrategy` |
| `Level/Orchestration/LevelOrchestrator.swift` | Framework | Service: level load, room transition, cleanup |
| `Level/Layout/LinearDungeonLayout.swift` | Game | Concrete layout: horizontal room chain |
| `Level/Construction/BoxRoomConstructor.swift` | Game | Concrete constructor: perimeter walls + obstacles |
| `ECS/Components/Room/RoomMemberComponent.swift` | Framework | Tags every entity that belongs to a specific room |

---

## The Dungeon Graph

The dungeon topology is an explicit directed graph. Nodes are rooms, and edges are doorway connections.

### Why an Explicit Graph?
Instead of scattering connections across ECS `RoomComponent`s, an explicit `DungeonGraph` provides a single authoritative topology. ECS metadata is derived from the graph at build time. This allows algorithms like minimap rendering or AI pathfinding to query the map structure without touching the ECS World.

### Invariants
1. **Connectivity**: Every `edge.fromNodeID` and `edge.toNodeID` must exist in the graph's node set.
2. **Start Node**: A valid level must define a `startNodeID`.

---

## Generation Strategies

### `DungeonLayoutStrategy`
Responsible for the "Big Picture." It decides how many rooms exist, where they are in world space, and which ones are connected by corridors. 
- **LinearDungeonLayout**: A simple horizontal chain of rooms separated by corridors of a fixed length.

### `RoomConstructor`
Responsible for the "Details." It receives a `RoomSpecification` and populates the ECS World with the structural geometry (walls, floors) using a `RoomBuilder`.
- **BoxRoomConstructor**: Uses fixed wall thickness to emit perimeter segments while leaving gaps for doorways.

### `RoomPopulatorStrategy`
The **"Seam"** between the generation framework and specific game content. 
1. **Framework**: Defines the `populate` contract.
2. **Game Layer**: Implements logic for spawning specific enemies or loot (e.g., `EnemyRoomPopulator`).
3. **Execution**: `LevelOrchestrator` invokes the populator after the geometry is built.

---

## Generation Pipeline

When a level is loaded, the following pipeline executes in order:

1. **Context Setup** — A `GenerationContext` is created with the current floor index, difficulty multiplier, and a random seed. The seed enables deterministic reproduction of any dungeon for debugging.
2. **Topology** — `layoutStrategy.generate(context:)` runs and returns a `DungeonGraph` describing which rooms exist and how they connect (pure data, no ECS).
3. **Geometry** — For each node in the graph, `roomConstructor.construct(...)` creates the wall and floor ECS entities. Corridor edges are similarly built into narrow rooms with matching walls.
4. **Population** — Each room's assigned `RoomPopulatorStrategy` runs after geometry is built, spawning enemies, weapons, or leaving the room empty.
5. **State Storage** — The completed graph is stored in `LevelStateComponent` in the ECS World. The starting node is set as `activeNodeID`.

---

## Layout Strategies

Each strategy produces a different dungeon shape by arranging rooms and corridors. All strategies use the `LayoutBuilder` fluent API to place rooms relative to one another. The builder handles world-space offset calculations automatically.

All rooms are currently 1000 × 800 world units. Corridors default to 300 units long.

### `LinearDungeonLayout`
The simplest strategy. Rooms are chained eastward in a straight line.

```
[Start/Weapon] ── [Combat] ── [Boss]
```

- Enemy count scales with floor index and room position.
- The final room is always the boss room (higher enemy count).
- Used by **Chilling Crypts**.

### `StarDungeonLayout`
A hub-and-spokes layout. The start room sits in the centre with four branches extending in each cardinal direction.

```
        [N combat]
             |
[W boss] ── [Start] ── [E combat]
             |
        [S combat]
```

- Three regular combat branches (N, E, S) and one boss branch (W).
- All branches are the same corridor length from the hub.
- Used by **Burning Depths**.

### `LShapeDungeonLayout`
An L-shaped path. The first leg runs east, then turns south at a corner room, and the boss anchors the end of the vertical leg.

```
[Start] ── [Combat] ── [Corner]
                           |
                       [Combat] ── [Boss]
```

- Introduces a directional turn mid-dungeon.
- Used by **Living Labyrinth**.

---

## Room Construction

`BoxRoomConstructor` is the concrete implementation of `RoomConstructor`. It fills a room with:

- A **floor entity** spanning the full room bounds.
- **Perimeter wall segments** around all four sides, with gaps cut out for each doorway.

Wall splitting works by sorting all doorways on a given edge by position, then emitting wall segments between them. The result is a continuous perimeter with clean openings wherever corridors connect.

Corridors are treated as narrow rooms and constructed the same way, with openings at both ends.

---

## Population System

After geometry is built, each room's `RoomPopulatorStrategy` is invoked with a `PopulateContext` that provides helpers for placing entities safely (avoiding walls and already-occupied spots).

| Populator | Behaviour |
|---|---|
| `EmptyRoomPopulator` | No-op. Used for the start room on floors beyond the first. |
| `WeaponRoomPopulator` | Spawns a weapon pickup near the room centre. Used for the start room. |
| `EnemyRoomPopulator` | Spawns a configurable number of enemies from the layout's `enemyPool`. |
| `CompositeRoomPopulator` | Combines multiple populators; runs each in sequence. |

Enemy count per room is calculated by the layout strategy based on `floorIndex` (increases with progression) and room position (the boss room always gets more enemies).

---

## Dungeon Definitions

The `DungeonLibrary` is a static registry that maps a dungeon name and visual theme to a concrete layout strategy and enemy pool. Adding a new dungeon means adding one entry here—no other code changes are required.

```swift
DungeonDefinition(
    name: "Burning Depths",
    theme: .burning,
    layoutStrategy: StarDungeonLayout(enemyPool: [.charger, .mummy, .ranger])
)
```

Each `DungeonDefinition` bundles:
- **`name` / `description`**: Shown in the level-select screen.
- **`theme`**: Controls the visual tile set used by the tile renderer.
- **`layoutStrategy`**: The `DungeonLayoutStrategy` instance used at generation time.

---

## Adding a New Layout

1. Create a type conforming to `DungeonLayoutStrategy`.
2. Use `LayoutBuilder.placeStartRoom(...)` to place the first room, then `addRoom(extending:direction:...)` for each subsequent room.
3. Assign a `RoomPopulatorStrategy` to each room at placement time.
4. Call `builder.build()` and return the `DungeonGraph`.
5. Register a new `DungeonDefinition` in `DungeonLibrary.all`.

No changes to `LevelOrchestrator`, `LevelGenerationManager`, or `BoxRoomConstructor` are needed.

