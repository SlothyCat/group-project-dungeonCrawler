---
title: "Enemies"
description: "How enemies are structured, spawned, and how to add a new enemy type."
sidebar_position: 1
---

# Enemies

An enemy is an ECS entity created by `EntityFactory.makeEnemy`. Its behaviour is driven by `EnemyAISystem` in each frame.

## Components

Every enemy entity is created with the following components:

| Component | Role |
|---|---|
| `TransformComponent` | Position, rotation, and scale |
| `SpriteComponent` | Texture, derived from `EnemyType` at spawn time |
| `EnemyTagComponent` | Marks the entity as an enemy; holds the resolved `textureName` and `scale` |
| `VelocityComponent` | Movement vector, set each frame by `EnemyAISystem` |
| `EnemyStateComponent` | AI mode (wander/chase) and related configurations |
| `CollisionBoxComponent` | Axis-aligned bounding box, currently sized to `48 × 48 × scale` |

## Enemy Types

Enemy types are defined in the `EnemyType` enum inside `EnemyEntityFactory.swift`. Each type maps to a texture asset, a scale multiplier, and a mass value.

**Current Enemy Types**:

| Type | Texture | Scale | Mass |
|---|---|---|---|
| `.charger` | "Charger" | 1.0 | 15 |
| `.mummy` | "Mummy" | 1.0 | 10 |
| `.ranger` | "Ranger" | 0.75 | 5 |
| `.tower` | "Tower" | 1.5 | 20 |


The final in-world scale is `baseScale × type.scale`, where `baseScale` is passed in at spawn time (derived from screen size).

## Spawning an Enemy

Use `EnemyEntityFactory` to create an enemy entity:

```swift
EnemyEntityFactory(at: position, type: .mummy, baseScale: scale).make(in: world)

// baseScale defaults to 1 if omitted
EnemyEntityFactory(at: position, type: .tower).make(in: world)
```

In normal gameplay, enemies are spawned by `MapSystem` at the enemy spawn points generated for a room.

## Adding a New Enemy Type

1. **Add a case** to `EnemyType` in `EnemyEntityFactory.swift`.
2. **Add a `textureName`** entry — add the corresponding asset to the asset catalog.
3. **Add a `scale`** entry — `1.0` is the baseline character size.

For example:
```swift
case goblin

var textureName: String {
    // ...
    case .goblin: return "Goblin"
}

var scale: Float {
    // ...
    case .goblin: return 0.85
}

var mass: Int {
    // ...
    case .goblin: return 7.5
}
```

No changes to `EnemyTagComponent` or `EnemyAISystem` are needed. To give the new type different AI behaviour (e.g. faster chase speed), pass a custom `EnemyStateComponent` after creation:

For example:
```swift
let enemy = EnemyEntityFactory(at: position, type: .goblin, baseScale: scale).make(in: world)
world.addComponent(
    component: EnemyStateComponent(detectionRadius: 200, chaseSpeed: 100),
    to: enemy
)
```

See [Enemy AI System](./enemyAISystem.md) for all configurable fields.
