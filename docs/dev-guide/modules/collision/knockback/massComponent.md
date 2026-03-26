---
title: "MassComponent"
description: "How mass affects knockback speed and positional nudge on collision."
sidebar_position: 2
---

# MassComponent

`MassComponent` stores an entity's mass, which `CollisionSystem` uses to scale both the positional nudge and knockback speed on player–enemy contact. Heavier entities are harder to move — they receive a smaller nudge and a slower knockback impulse.

```swift
public struct MassComponent: Component {
    public var mass: Int  // Default: 10
}
```

The player defaults to mass `10`. Enemy masses are set per `EnemyType` in `EnemyEntityFactory`:

| Enemy | Mass |
|---|---|
| `.ranger` | 5 |
| `.mummy` | 10 |
| `.charger` | 15 |
| `.tower` | 20 |

---

## How Mass Is Used

On a player–enemy collision, `CollisionSystem` reads both entities' `MassComponent` values and derives:

**Positional nudge** — each entity is displaced by its share of the MTV, weighted by the *other* entity's mass:

```
player nudge = MTV × (enemyMass / totalMass)
enemy nudge  = MTV × (playerMass / totalMass)
```

A heavier enemy pushes the player further away, and vice versa.

**Knockback speed** — each entity's knockback speed is inversely proportional to its own mass:

```
knockbackSpeed = baseKnockbackSpeed (1500) / mass
```

A lighter entity (e.g. `.ranger`, mass `5`) receives a faster knockback impulse than a heavier one (e.g. `.tower`, mass `20`).

---

## Fallback

If an entity has no `MassComponent`, `CollisionSystem` falls back to a default mass of `10` to avoid division by zero.
