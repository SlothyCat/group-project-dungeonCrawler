---
title: "Enemies"
description: "How enemies are structured, spawned, and how to add a new enemy type."
sidebar_position: 1
---

# Enemies

An enemy is an ECS entity created by `EnemyEntityFactory`. Its behaviour is driven by `EnemyAISystem` each frame via a **strategy** that composes one or more **behaviours**.

## Components

Every enemy entity is created with the following components:

| Component | Role |
|---|---|
| `TransformComponent` | Position, rotation, and scale |
| `SpriteComponent` | Texture, derived from `EnemyType` at spawn time |
| `EnemyTagComponent` | Marks the entity as an enemy; holds `textureName` and `scale` |
| `VelocityComponent` | Movement vector, written each frame by the active behaviour |
| `EnemyStateComponent` | Holds the enemy's strategy instance |
| `CollisionBoxComponent` | Axis-aligned bounding box |
| `RoomMemberComponent` | Binds the enemy to its room (used for bounds-aware wandering and cleanup) |

## Enemy Types

Enemy types are defined as static constants on `EnemyType` in `ECS/Enemy/EnemyType.swift`. Each constant bundles all properties of that enemy: texture, scale, mass, contact damage, and AI strategy.

**Current Enemy Types**:

| Type | Texture | Scale | Mass | Contact Damage | Strategy |
|---|---|---|---|---|---|
| `.charger` | "Charger" | 1.0 | 15 | 20.0 | `StandardStrategy()` — chases |
| `.mummy` | "Mummy" | 1.0 | 10 | 10.0 | `StandardStrategy()` — chases |
| `.ranger` | "Ranger" | 0.75 | 5 | 5.0 | `StandardStrategy` with orbit + shoot attack |
| `.tower` | "Tower" | 1.5 | 20 | 15.0 | `StandardStrategy` — stationary, shoots on detection |

The final in-world scale is `baseScale × type.scale`, where `baseScale` is passed in at spawn time.

## Spawning an Enemy

Use `EnemyEntityFactory` to create an enemy entity:

```swift
EnemyEntityFactory(at: position, type: .mummy, baseScale: scale).make(in: world)

// baseScale defaults to 1 if omitted
EnemyEntityFactory(at: position, type: .tower).make(in: world)
```

In normal gameplay, enemies are spawned by `MapSystem` at the enemy spawn points generated for a room.

## Adding a New Enemy Type

Add a single `static let` block to `EnemyType.swift` — no other files need to change:

```swift
public static let goblin = EnemyType(
    textureName: "Goblin",
    scale: 0.85,
    mass: 8,
    contactDamage: 12.0,
    strategy: StandardStrategy()
)
```

Also add the corresponding texture asset to the asset catalog.

All properties are required by the compiler, so a new definition cannot be accidentally left incomplete.

## Customising AI After Spawn

To override a spawned enemy's strategy, replace `EnemyStateComponent` after creation — `addComponent` overwrites any existing component of the same type:

```swift
let enemy = EnemyEntityFactory(at: position, type: .goblin).make(in: world)
world.addComponent(
    component: EnemyStateComponent(
        strategy: TimidStrategy(detectionRadius: 200, fleeThreshold: 0.4)
    ),
    to: enemy
)
```

`EnemyStateComponent` defaults to `StandardStrategy()`, so you only supply what you want to override.

See [Enemy AI System](./enemyAISystem.md) for all available strategies, behaviours, and their configurable parameters.
