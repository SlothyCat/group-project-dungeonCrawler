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
        
        let baseColor: SIMD4<Float>
        let isColourContent: Bool
        switch sprite.content {
        case .solidColor(let color):
            baseColor = color
            isColourContent = true
        case .texture:
            baseColor = SIMD4<Float>(1, 1, 1, 1)
            isColourContent = false
        }
        
        let finalColor = baseColor * sprite.tint
        
        node.color = SKColor(
            red:   CGFloat(finalColor.x),
            green: CGFloat(finalColor.y),
            blue:  CGFloat(finalColor.z),
            alpha: CGFloat(finalColor.w)
        )
        
        // Color blend should be absolute for solids, or conditional for textures based on tint
        let isWhiteTint = sprite.tint.x == 1 && sprite.tint.y == 1 && sprite.tint.z == 1
        node.colorBlendFactor = isColourContent ? 1.0 : (isWhiteTint ? 0.0 : 1.0)
    }

    public func removeNode(for entity: Entity) {
        nodeRegistry[entity]?.removeFromParent()
        nodeRegistry[entity] = nil
    }

    // MARK: - Node lifecycle

    private func node(for entity: Entity, sprite: SpriteComponent, in parent: SKNode) -> SKSpriteNode {
        if let existing = nodeRegistry[entity] { return existing }
        let node: SKSpriteNode

        switch sprite.content {
        case .solidColor(let colorVal):
            let size = sprite.renderSize.map { CGSize(width: CGFloat($0.x), height: CGFloat($0.y)) }
                       ?? CGSize(width: 1, height: 1)
            node = SKSpriteNode(color: SKColor(
                red: CGFloat(colorVal.x),
                green: CGFloat(colorVal.y),
                blue: CGFloat(colorVal.z),
                alpha: CGFloat(colorVal.w)
            ), size: size)
        case .texture(let name):
            let texture = SKTexture(imageNamed: name)
            node = SKSpriteNode(texture: texture)
        }
        
        node.name = "entity_\(entity.id)"
        node.zPosition = sprite.layer.rawValue
        node.anchorPoint = CGPoint(x: CGFloat(sprite.anchorPoint.x), y: CGFloat(sprite.anchorPoint.y))
        parent.addChild(node)
        nodeRegistry[entity] = node
        return node
    }
}
