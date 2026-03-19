---
title: "Render System"
description: "How the RenderSystem works."
sidebar_position: 3
---

# Rendering System

The `RenderSystem` is how the entities in the **ECS World** (Logic) are rendered.

We use **SpriteKit** to render the entities, but the system itself has **no SpriteKit dependency** — it delegates all engine-specific work to a `RenderingBackend`. The SpriteKit implementation of that backend is `SpriteKitRenderingAdapter`.


**Components Required**:

For an entity to be rendered, it needs to have both a `TransformComponent` (position, scale, rotation) and a `SpriteComponent` (texture name, tint color).

**The Synchronization Loop**: 

Every frame, `RenderSystem.update()` performs a sync:

1. **Query** all entities with both `TransformComponent` and `SpriteComponent`.
2. **Create or update** each entity's node via `backend.syncNode(...)`.
3. **Remove** nodes for entities that are no longer renderable via `backend.removeNode(...)`.


### **RenderingBackend Protocol**:

`RenderSystem` depends on a protocol, not a concrete SpriteKit type. This means that we can swap out the rendering engine without changing the `RenderSystem`.

```swift
protocol RenderingBackend: AnyObject {
    func syncNode(for entity: Entity, transform: TransformComponent,
                  sprite: SpriteComponent, velocity: VelocityComponent?)
    func removeNode(for entity: Entity)
}
```

* **SpriteKitRenderingAdapter**: is the concrete SpriteKit implementation of `RenderingBackend`. It:
    - Keeps a private `nodeRegistry: [Entity: SKSpriteNode]` mapping each entity to its visual node.
    - Adds new nodes to **`worldLayer`** (not the scene root), so the `SpriteKitCameraAdapter` can shift the entire world layer to implement camera movement.
    - Handles flip direction based on `VelocityComponent`, tint color, and `zPosition`.

