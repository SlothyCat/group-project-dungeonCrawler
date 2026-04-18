---
title: "Enemy AI System"
description: "How the EnemyAISystem works, including strategies and behaviours."
sidebar_position: 2
---

# Enemy AI System

`EnemyAISystem` drives enemy behaviour each frame. It runs after `KnockbackSystem` and delegates to each enemy's **strategy**, which in turn selects and runs a **behaviour**.

The AI is split into two layers:

| Layer | Protocol | Responsibility |
|---|---|---|
| **Strategy** | `EnemyStrategy` | Decides *which* behaviour runs this frame (state machine) |
| **Behaviour** | `EnemyBehaviour` | Executes the chosen action (writes velocity, manages components) |

---

## Components Required

For an enemy to be processed, it **must have**:

- `EnemyStateComponent` — holds the enemy's strategy instance
- `TransformComponent` — provides the enemy's current position
- `VelocityComponent` — written each frame by the active behaviour

**Note:** Enemies that currently have a `KnockbackComponent` are skipped — knockback takes priority over AI-driven movement.

---

## EnemyStateComponent

`EnemyStateComponent` holds a single strategy instance that drives all behaviour decisions for that enemy.

```swift
public class EnemyStateComponent: Component {
    public var strategy: any EnemyStrategy

    public init(strategy: any EnemyStrategy = StandardStrategy())
}
```

To give an enemy a different AI personality, supply a different strategy at creation time or replace the component entirely after spawning.

---

## BehaviourContext

Every strategy and behaviour receives a `BehaviourContext` each frame — a lightweight snapshot of world state with convenience accessors:

| Property | Type | Description |
|---|---|---|
| `entity` | `Entity` | The enemy being updated |
| `playerPos` | `SIMD2<Float>` | Player's world position this frame |
| `transform` | `TransformComponent` | Enemy's transform (read-only snapshot) |
| `world` | `World` | Full ECS world for component queries |
| `distToPlayer` | `Float` | Euclidean distance to the player |
| `healthFraction` | `Float?` | Current HP as a 0–1 fraction; nil if no `HealthComponent` |
| `roomBounds` | `RoomBounds?` | Bounds of the room this enemy belongs to; nil if no `RoomMemberComponent` |

---

## Strategy Protocol

```swift
public protocol EnemyStrategy {
    func update(entity: Entity, context: BehaviourContext)
}
```

Strategies call `activate(_:from:for:context:)` (provided by a protocol extension on `EnemyStrategy`) instead of invoking a behaviour directly. This helper:

1. Detects when the chosen behaviour changes (comparing `ActiveBehaviourComponent.behaviourID`).
2. Calls `onDeactivate` on the outgoing behaviour.
3. Calls `onActivate` on the incoming behaviour.
4. Calls `update` on the chosen behaviour.

---

## Behaviour Protocol

```swift
public protocol EnemyBehaviour {
    var id: String { get }
    func update(entity: Entity, context: BehaviourContext)
    func onActivate(entity: Entity, context: BehaviourContext)
    func onDeactivate(entity: Entity, context: BehaviourContext)
}
```

- `id` defaults to the type name (e.g. `"WanderBehaviour"`). `CompositeBehaviour` derives its id from both children.
- `onActivate` / `onDeactivate` have empty default implementations — only override when the behaviour needs to add or remove components on transition.
- `ActiveBehaviourComponent` is added lazily to the entity by the strategy on first use and stores the currently active behaviour's id.

---

## Built-in Strategies

### `StandardStrategy`

Wanders when idle; attacks when the player enters `detectionRadius`. Keeps attacking until the player leaves `loseRadius` (hysteresis). A `nil` loseRadius means the enemy never disengages.

| Parameter | Default | Description |
|---|---|---|
| `detectionRadius` | `150` | Distance at which the enemy switches from wander to attack |
| `loseRadius` | `225` | Distance at which the enemy returns to wander; `nil` = never disengage |
| `wanderBehaviour` | `WanderBehaviour()` | Behaviour used when idle |
| `attackBehaviour` | `ChaseBehaviour()` | Behaviour used when engaging |

```swift
// Default — chases the player
StandardStrategy()

// Shooter that orbits while firing; never disengages
StandardStrategy(
    detectionRadius: 200,
    loseRadius: nil,
    attackBehaviour: CompositeBehaviour(OrbitBehaviour(), ShooterBehaviour())
)
```

---

### `TimidStrategy`

Like `StandardStrategy` but adds a flee response. Priority order: **flee > attack > wander**.

| Parameter | Default | Description |
|---|---|---|
| `detectionRadius` | `150` | Distance at which the enemy switches from wander to attack |
| `loseRadius` | `225` | Distance at which the enemy returns to wander; `nil` = never disengage |
| `fleeThreshold` | `0.2` | HP fraction below which the enemy flees regardless of distance |
| `wanderBehaviour` | `WanderBehaviour()` | Behaviour used when idle |
| `attackBehaviour` | `ChaseBehaviour()` | Behaviour used when engaging |
| `fleeBehaviour` | `FleeBehaviour()` | Behaviour used when HP is low |

```swift
// Default — flees below 20% HP
TimidStrategy()

// More aggressive flee trigger
TimidStrategy(fleeThreshold: 0.5)
```

---

## Built-in Behaviours

### `WanderBehaviour`

Moves the enemy to random points within `wanderRadius`, constrained to the room the enemy belongs to. On arrival (within 8 pt of the target) a new candidate is picked. Candidates are validated against the room's safe area (`RoomBounds` inset by `wallMargin`) — preventing the enemy from wandering into walls. If all directed candidates fall outside the safe area the behaviour falls back to a random point anywhere inside it. If the enemy has no `RoomMemberComponent` the room constraint is skipped.

| Parameter | Default | Description |
|---|---|---|
| `wanderRadius` | `100` | Max distance from current position for a new target |
| `wanderSpeed` | `40` | Movement speed while wandering |
| `wallMargin` | `40` | Inset from room boundary when validating candidates |

```swift
WanderBehaviour(wanderRadius: 100, wanderSpeed: 40, wallMargin: 40)
```

**Associated component:** `WanderTargetComponent` — stores the current target as `SIMD2<Float>?`. Added lazily on first `update`; removed in `onDeactivate`.

---

### `ChaseBehaviour`

Moves the enemy directly toward the player at a fixed speed.

| Parameter | Default | Description |
|---|---|---|
| `speed` | `70` | Movement speed while chasing |

```swift
ChaseBehaviour(speed: 70)
```

---

### `FleeBehaviour`

Moves the enemy directly away from the player at a fixed speed.

| Parameter | Default | Description |
|---|---|---|
| `speed` | `90` | Movement speed while fleeing |

```swift
FleeBehaviour(speed: 90)
```

---

### `OrbitBehaviour`

Moves the enemy in an arc around the player by hopping between polar-coordinate targets in an annular zone. Each hop picks a new angle offset (±`arcRange`) from the current bearing and a random radius, forming a zigzag orbit. The enemy briefly stops between hops.

Pair with `ShooterBehaviour` (via `CompositeBehaviour`) to get a shooter that moves and fires simultaneously.

| Parameter | Default | Description |
|---|---|---|
| `innerRadius` | `100` | Closest distance from the player |
| `outerRadius` | `200` | Furthest distance from the player |
| `moveSpeed` | `60` | Movement speed between hop targets |
| `arcRange` | `π/3` | Max angular deviation per hop (radians) |

```swift
OrbitBehaviour(innerRadius: 100, outerRadius: 200, moveSpeed: 60, arcRange: .pi / 3)
```

**Associated component:** `ShooterBasicComponent` — stores the current hop target as polar coordinates (`targetAngle`, `targetRadius`) relative to the player. Added lazily; removed in `onDeactivate`.

---

### `ShooterBehaviour`

Aims at the player and signals intent to fire each frame. Does not write to `VelocityComponent` — pair with a movement behaviour via `CompositeBehaviour`.

On activation: adds `FacingComponent` and `InputComponent` (if absent) and spawns + equips a weapon entity. On deactivation: destroys the weapon entity and clears `isShooting`.

| Parameter | Default | Description |
|---|---|---|
| `weaponBase` | `.enemyRangedDefault` | The weapon template to equip on activation |

```swift
ShooterBehaviour(weaponBase: .enemyRangedDefault)
```

---

### `StationaryBehaviour`

Does nothing — the enemy stays in place. Use as `wanderBehaviour` or `attackBehaviour` for tower-type enemies.

```swift
StationaryBehaviour()
```

---

### `CompositeBehaviour`

Combines two behaviours into one, delegating all lifecycle calls and `update` to both in order. Useful for pairing a movement behaviour with an attack behaviour in a single strategy slot.

Its `id` is derived from both children (`"PrimaryID+SecondaryID"`), so `ActiveBehaviourComponent` tracks the pair as a single unit and transitions fire correctly.

```swift
// Orbit while shooting
CompositeBehaviour(OrbitBehaviour(), ShooterBehaviour())

// Stand still while shooting
CompositeBehaviour(StationaryBehaviour(), ShooterBehaviour())
```

---

## Update Loop

Each frame, `EnemyAISystem.update()` does the following for every qualifying enemy:

1. **Skip** if `KnockbackComponent` is present.
2. Build a `BehaviourContext` snapshot.
3. Call `strategy.update(entity:context:)` — the strategy decides which behaviour runs and calls `activate(_:from:for:context:)`.
4. `activate` handles transition lifecycle (`onDeactivate` / `onActivate`) and then calls `behaviour.update`.

The system itself does not write velocity — that is each behaviour's responsibility.

---

## Adding a New Strategy

1. Define a `struct` or `final class` conforming to `EnemyStrategy`.
2. Implement `update(entity:context:)` — call `activate(_:from:for:context:)` with your chosen behaviour.

```swift
public struct MyStrategy: EnemyStrategy {
    public var wanderBehaviour: any EnemyBehaviour = WanderBehaviour()
    public var attackBehaviour: any EnemyBehaviour = ChaseBehaviour()

    public func update(entity: Entity, context: BehaviourContext) {
        let chosen = context.distToPlayer < 150 ? attackBehaviour : wanderBehaviour
        activate(chosen, from: [wanderBehaviour, attackBehaviour], for: entity, context: context)
    }
}
```

## Adding a New Behaviour

1. Define a `struct` conforming to `EnemyBehaviour`.
2. Implement `update` — write to `VelocityComponent` (or other components) via `context.world`.
3. Override `onActivate` / `onDeactivate` only if your behaviour needs to add or remove companion components on transition.
4. If your behaviour needs per-entity state, create a companion `Component` class and add it lazily in `update`.

```swift
public struct MyBehaviour: EnemyBehaviour {
    public var speed: Float = 50

    public func update(entity: Entity, context: BehaviourContext) {
        context.world.getComponent(type: VelocityComponent.self, for: entity)?.linear = /* ... */
    }
}
```

---

## Dependencies

| Dependency | Role |
|---|---|
| `EnemyStateComponent` | Holds the strategy instance |
| `TransformComponent` | Read for enemy and player positions |
| `VelocityComponent` | Written by the active behaviour each frame |
| `KnockbackComponent` | Presence causes the enemy to be skipped this frame |
| `PlayerTagComponent` | Used to locate the player entity |
| `ActiveBehaviourComponent` | Tracks the currently running behaviour id; managed by `EnemyStrategy` |
| `WanderTargetComponent` | Per-entity wander destination; managed by `WanderBehaviour` |
| `ShooterBasicComponent` | Per-entity orbit state; managed by `OrbitBehaviour` |
| `EquippedWeaponComponent` | Weapon slot; managed by `ShooterBehaviour` |
| `RoomMemberComponent` | Used by `BehaviourContext.roomBounds` to look up room boundaries |
| `RoomMetadataComponent` | Provides `RoomBounds` for wander target validation |
