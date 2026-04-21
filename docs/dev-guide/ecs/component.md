---
title: "Components"
description: "What components exist, how they work, and how to use them."
sidebar_label: "Components"
sidebar_position: 2
---

# Components

A component is a **plain data container**: a Swift `class` that holds state but no logic. Every component conforms to the `Component` marker protocol:

```swift
public protocol Component {}
```

## Representation Invariants

To maintain world consistency, components must adhere to the following rules:
- **Reference Semantics**: A component retrieved via `getComponent` is a live reference—mutations are immediately visible to all systems.
- **Unique Ownership**: Each component instance should be owned by **exactly one** entity. Sharing a component instance between two entities (e.g., two enemies sharing one `TransformComponent`) is a misuse of the API and will lead to undefined behavior.
- **Pure Data**: Components should not contain methods that encapsulate logic or side effects. Logic belongs in **Systems**.

---

## Core Data Types: StatValue

Many components (Health, Mana, MoveSpeed) use the `StatValue` struct to manage numerical data. This structure is designed to support baseline values and temporary modifiers without losing the original state.

| Field | Purpose |
| :--- | :--- |
| **`base`** | The unmodified starting value. Never changed by temporary gameplay effects; serves as a reference for percentage-based modifiers. |
| **`current`** | The active runtime value. Modified by damage, healing, or status effects. |
| **`max`** | An optional ceiling. If non-nil, `current` is clamped to this value. |

**Invariants:**
- `current` never exceeds `max` if `max` is non-nil (after calling `clampToMax()`).
- `current` never falls below a specified floor (usually `0`) after calling `clampToMin()`.

---

## Component Storage

`ComponentStorage` acts as a 2D mapping between `EntityID` and `ComponentType`.

- **`ComponentStore<T>`**: A dictionary mapping `EntityID` to `T`.
- **`ComponentStorage Registry`**: A map from `ObjectIdentifier(T.self)` to the corresponding `ComponentStore<T>`.

This layout ensures **O(1) lookup** for any component type and allows systems to efficiently query all entities possessing a specific set of data.

---

## Working with Components

### Add a Component
```swift
world.addComponent(component: TransformComponent(position: .zero), to: entity)
```

### Read and Mutate
Since components are classes, you mutate them directly on the reference:
```swift
if let health = world.getComponent(type: HealthComponent.self, for: entity) {
    health.value.current -= 10
    health.value.clampToMin() // StatValue helper
}
```

### Remove a Component
```swift
world.removeComponent(type: VelocityComponent.self, from: entity)
```

---

## Common Component Domains

### Physics & Input
- **`TransformComponent`**: Position, rotation, and scale.
- **`VelocityComponent`**: Linear and angular velocity vectors.
- **`MoveSpeedComponent`**: A `StatValue` wrapper around movement speed.
- **`InputComponent`**: Stores move/aim vectors and shooting intent.

### Combat & Stats
- **`HealthComponent`**: Uses `StatValue` to track HP. 
- **`ManaComponent`**: Uses `StatValue` to track mana and regeneration rates.
- **`KnockbackComponent`**: A **transient** component added during knockback. Its presence serves as a state flag for movement systems.

### Weapons & Projectiles
- **`EquippedWeaponComponent`**: Stores references to primary and secondary weapon entities.
- **`WeaponAmmoComponent`**: Tracks magazine count and reload timers.
- **`ProjectileComponent`**: Stores the array of `ProjectileHitEffect` to apply on impact.

