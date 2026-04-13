import Foundation

/// Advances `LoopingAnimationComponent` each frame and writes the current
/// texture name to the entity's `SpriteComponent`.
public final class LoopingAnimationSystem: System {

    public var dependencies: [System.Type] { [] }

    public init() {}

    public func update(deltaTime: Double, world: World) {
        for entity in world.entities(with: LoopingAnimationComponent.self) {
            guard let anim   = world.getComponent(type: LoopingAnimationComponent.self, for: entity),
                  let sprite = world.getComponent(type: SpriteComponent.self, for: entity),
                  !anim.frameNames.isEmpty
            else { continue }

            anim.elapsed += deltaTime
            if anim.elapsed >= anim.frameDuration {
                anim.elapsed   -= anim.frameDuration
                anim.frameIndex = (anim.frameIndex + 1) % anim.frameNames.count
            }

            sprite.content = .texture(name: anim.frameNames[anim.frameIndex])
        }
    }
}
