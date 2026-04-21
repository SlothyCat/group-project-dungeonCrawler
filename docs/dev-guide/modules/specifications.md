---
title: Module Specifications
sidebar_position: 10
---

# Module Specifications

This document defines the formal contracts and representation invariants for core classes and data structures within the Soulless Knight architecture.

---

## Technical Data Primitives

### `StatValue`
A mutable value type representing a stat with a baseline, a live runtime value, and an optional cap. Used for health, mana, move speed, and projectile range.

**Fields:**
- `base`: The unmodified starting value (reference for percentage modifiers).
- `current`: The active value (modified by damage, healing, etc.).
- `max`: An optional ceiling (nil means uncapped).

**Abstract Invariants:**
- `current` is less than or equal to `max` when `max` is non-nil.
- After `clampToMin(floor:)` is called, `current` is greater than or equal to `floor`.

---

## ECS Storage & Infrastructure

### `ComponentStorage`
Type-indexed storage for all ECS components. Provides O(1) lookup by component type and entity ID.

**Fields:**
- `_stores`: A dictionary from `ObjectIdentifier` to `AnyComponentStore`, with one store per component type.

**Abstract Invariants:**
- The store at `ObjectIdentifier(T.self)` contains only values of type `T`.
- For any entity and component type `T`, at most one value of type `T` exists in the store.

---

## World & Level Logic

### `DungeonGraph`
Represents the topology of a single dungeon floor as a directed graph. Immutable after construction.

**Fields:**
- `nodes`: A dictionary from `UUID` to `RoomSpecification`.
- `edges`: An array of `DungeonEdge` values representing directed connections.
- `startNodeID`: The UUID of the room where the player spawns.

**Abstract Invariants:**
- Every edge's `fromNodeID` and `toNodeID` must be a valid key in `nodes`.
- `startNodeID` must be a valid key in `nodes`.

### `LevelStateComponent`
A global singleton component storing the full dungeon topology and the player's current active room.

**Fields:**
- `graph`: The `DungeonGraph` for the current floor.
- `activeNodeID`: The UUID of the room the player is currently in.
- `transitionCooldown`: Remaining cooldown in seconds to prevent rapid re-triggering.

**Abstract Invariants:**
- `activeNodeID` must be a valid key in `graph.nodes`.
- `transitionCooldown` must be greater than or equal to zero.

### `RoomMetadataComponent`
Attached to each room entity. Describes the room's geometry and internal layout.

**Fields:**
- `roomID`: A UUID matching the corresponding key in `DungeonGraph.nodes`.
- `bounds`: A `RoomBounds` AABB in world coordinates.
- `doorways`: An array of `Doorway` values describing openings.
- `spawnPoints`: Valid coordinates for player entry and enemy population.

---

## Strategy & Behavior

### `EnemyStrategy`
A protocol defining high-level decision making for enemies.
- **Invariant**: Must return a set of intents (move/aim/fire) each tick based on the `EnemyAIContext`.

### `WeaponEffect`
A protocol defining a single step in a weapon's firing chain.
- **Invariant**: Each effect must return either `.proceed` to continue the chain or `.blocked` to halt it (Chain of Responsibility).
