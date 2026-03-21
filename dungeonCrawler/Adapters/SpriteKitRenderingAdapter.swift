//
//  SpriteKitRenderingAdapter.swift
//  dungeonCrawler
//

import SpriteKit

// MARK: - SpriteKit implementation

/// Manages SKSpriteNodes inside `worldLayer`. Sprites are positioned in world space;
/// the adapter shifts `worldLayer` each frame to implement camera movement.
public final class SpriteKitRenderingAdapter: RenderingBackend {

    private weak var worldLayer: SKNode?
    private var nodeRegistry: [Entity: SKSpriteNode] = [:]

    public init(worldLayer: SKNode) {
        self.worldLayer = worldLayer
    }

    public func syncNode(
        for entity: Entity,
        transform: TransformComponent,
        sprite: SpriteComponent,
        facing: FacingComponent?,
        velocity: VelocityComponent?
    ) {
        guard let worldLayer else { return }
        let node = node(for: entity, sprite: sprite, in: worldLayer)

        node.position = transform.cgPoint
        node.zRotation = CGFloat(transform.rotation)

        // We need to keep velocity here as some entity don't have facing component (eg. enemy, projectile)
        var flipFactor: CGFloat = node.xScale < 0 ? -1.0 : 1.0
        if let facing {
            flipFactor = facing.facing == .right ? 1.0 : -1.0
        } else if let velocity, velocity.linear.x != 0 {
            flipFactor = velocity.linear.x > 0 ? 1.0 : -1.0
        }

        node.xScale = CGFloat(transform.scale) * flipFactor
        node.yScale = CGFloat(transform.scale)
        
        let isColourSprite = sprite.textureName.isEmpty
        node.color = SKColor(
            red:   CGFloat(sprite.tintRed),
            green: CGFloat(sprite.tintGreen),
            blue:  CGFloat(sprite.tintBlue),
            alpha: CGFloat(sprite.tintAlpha)
        )
        node.colorBlendFactor = isColourSprite ? 1.0
            : (sprite.tintRed == 1 && sprite.tintGreen == 1 && sprite.tintBlue == 1) ? 0.0 : 1.0
    }

    public func removeNode(for entity: Entity) {
        nodeRegistry[entity]?.removeFromParent()
        nodeRegistry[entity] = nil
    }

    // MARK: - Node lifecycle

    private func node(for entity: Entity, sprite: SpriteComponent, in parent: SKNode) -> SKSpriteNode {
        if let existing = nodeRegistry[entity] { return existing }
        let node: SKSpriteNode

        if sprite.textureName.isEmpty {
            // Colour-only sprite: create a white 1×1 pixel and tint it.
            let size = sprite.renderSize.map { CGSize(width: CGFloat($0.x), height: CGFloat($0.y)) }
                       ?? CGSize(width: 1, height: 1)
            node = SKSpriteNode(color: .white, size: size)
        } else {
            let texture = SKTexture(imageNamed: sprite.textureName)
            node = SKSpriteNode(texture: texture)
        }
        
        node.name = "entity_\(entity.id)"
        node.zPosition = sprite.zPosition
        parent.addChild(node)
        nodeRegistry[entity] = node
        return node
    }
}
