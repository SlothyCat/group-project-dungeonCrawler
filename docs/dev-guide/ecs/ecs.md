---
title: "What is ECS?"
sidebar_position: 1
---

# Entity-Component-System (ECS)

The game is built on a custom **Entity-Component-System (ECS)** architecture that prioritizes composition over inheritance. This approach avoids deep class hierarchies and allows for high modularity and testability.

---

## Core Concepts

### Entity
An entity is a lightweight **unique identifier (UUID)**. It does not contain any data or behavior of its own; it serves as a container for components.
- **Representation**: A wrapper around a Swift `UUID`.
- **Invariant**: Two entities are equal if and only if they have the same UUID.
- **Lifecycle**: An entity is "alive" only if it exists in the `World._entities` registry.

### Component
A component is a **plain data container**: a Swift `class` that holds state but no logic.
- **Reference Semantics**: Unlike structs, components are classes. This means systems can mutate properties directly on a retrieved reference without needing to re-add the component to the world.
- **Marker Protocol**: Every component conforms to the `Component` marker protocol.
- **Domain Categories**: Components are grouped into logical domains (Physics, Combat Stats, Input, World Logic, Weapons, Enemies).

### System
A system contains the **logic**. Systems iterate over specific combinations of components and process them each frame.
- **Independence**: Systems are decoupled from each other and communicate only through changes in component data.
- **Protocol**: Every system conforms to the `System` protocol, declaring its own dependencies.

---

## System Orchestration

Execution order is managed by the `SystemManager` using a **Directed Acyclic Graph (DAG)**.

1. **Dependency Declaration**: Each system declares which other systems must run before it via the `dependencies` property.
2. **Topological Sort**: At startup (or when systems change), the `SystemManager` uses **Kahn’s Algorithm** to sort systems into a valid execution sequence.
3. **Loop**: Each frame, the sorted pipeline is updated sequentially. This removes the need for manual "priority numbers" and prevents race conditions.

---

## Why ECS?

| Approach | Problem | ECS Solution |
| :--- | :--- | :--- |
| **Deep Inheritance** | Fragile, hard to mix behaviors ("Diamond Problem"). | **Composition**: Mix and match behaviors by attaching components. |
| **Large God-Classes** | Hard to test and maintain. | **Decoupling**: Logic is split into small, focused systems. |
| **State Management** | Hard to track cross-object side effects. | **Centralized Storage**: All data lives in `ComponentStorage`. |

ECS allows us to add new features—like a "Knockback" effect—by simply creating a `KnockbackComponent` and a `KnockbackSystem`. Existing systems (like `MovementSystem`) can then check for the presence of this component to adjust their logic (e.g., stopping player-controlled movement while being knocked back).
