---
title: Design Overview
sidebar_position: 0
---

# Design Overview

**Soulless Knight** is built on a strict **Entity-Component-System (ECS)** architecture. This page provides a high-level view of how the system is organized, the modules that comprise it, and the design patterns that keep the codebase clean and testable.

---

## Technical Overview

The application follows a decoupled model where game logic is entirely independent of the rendering backend (SpriteKit). 


### ECS In a Nutshell
- **Entities**: Lightweight identifiers (UUIDs) acting as containers.
- **Components**: Plain Swift classes storing pure data (state).
- **Systems**: Decoupled modules containing logic that operates on entities with specific component combinations.

---

## Runtime Structure

### System Ordering (DAG)
The game utilizes a **Directed Acyclic Graph (DAG)** to determine the execution order of systems. Systems declare their dependencies explicitly (e.g., `MovementSystem` depends on `InputSystem`), and the `SystemManager` uses **Kahn’s Algorithm** to generate a valid topological sort every frame.

### Component Semantics
Components are **reference types (classes)**. This allows systems to retrieve a direct reference to data via `getComponent` and mutate it in place. These mutations propagate immediately through the world without needing closure-based wrappers or manual "write-back" steps.

---

## Module Structure

The project is decomposed into logical modules to support parallel development and maintainability.

## Design Patterns Applied

| Pattern | Application in Soulless Knight |
| :--- | :--- |
| **Adapter** | Decouples ECS logic from SpriteKit. `RenderingBackend` and `HUDBackend` are protocols; SpriteKit implementations are injected at runtime. |
| **Factory** | Centralizes entity construction (e.g., `EnemyEntityFactory`). No manual component attachment in systems. |
| **Command** | Input (Touch/Joysticks) generates `Command` objects. These are queued and consumed by `InputSystem` to update the world. |
| **Strategy** | Used for Dungeon Layout algorithms and Enemy AI decision-making (e.g., `StandardStrategy` vs `TimidStrategy`). |
| **Chain of Responsibility** | Weapon effects (e.g., `ConsumeAmmo` -> `SpawnProjectile`) are executed in a chain. Any effect can block the subsequent ones. |
| **Facade** | `LevelOrchestrator` provides a single entry point for complex generation and lockdown logic. |

---

## Software Engineering Goals

- **Simplicity**: No inheritance hierarchies for game objects. Behavior is added by simply attaching a component.
- **Extensibility**: Adding a new weapon or enemy requires creating new conforming types (e.g., `WeaponEffect`) without modifying existing system code.
- **Partitionability**: Modules are separated by stable protocols. UI engineers can work on `Adapters` while logic engineers work on `Systems` without conflicts.
