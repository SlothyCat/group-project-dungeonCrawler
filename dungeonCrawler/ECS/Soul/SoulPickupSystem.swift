import Foundation
import simd

/// Detects when the player walks over the boss-room soul collectible.
///
/// On pickup:
///   1. Enqueues the soul entity for destruction.
///   2. Spawns a one-shot particle effect at the player's position.
///   3. Signals `LevelClearedEvent` so `GameScene` can show the level-clear overlay.
public final class SoulPickupSystem: System {

    public var dependencies: [System.Type] { [MovementSystem.self] }

    /// Radius (in world units) within which the soul is automatically collected.
    private static let pickupRadius: Float = 60

    private let destructionQueue: DestructionQueue
    private let levelClearedEvent: LevelClearedEvent
    private let particleFrameNames: [String]
    private let particleFrameDuration: Double

    public init(
        destructionQueue: DestructionQueue,
        levelClearedEvent: LevelClearedEvent,
        particleFrameNames: [String],
        particleFrameDuration: Double
    ) {
        self.destructionQueue      = destructionQueue
        self.levelClearedEvent     = levelClearedEvent
        self.particleFrameNames    = particleFrameNames
        self.particleFrameDuration = particleFrameDuration
    }

    public func update(deltaTime: Double, world: World) {
        // Only fire once — guard against double-triggering
        guard !levelClearedEvent.triggered else { return }

        guard let playerEntity = world.entities(with: PlayerTagComponent.self).first,
              let playerTransform = world.getComponent(type: TransformComponent.self, for: playerEntity)
        else { return }

        let playerPosition = playerTransform.position

        for entity in world.entities(with: SoulComponent.self) {
            guard let transform = world.getComponent(type: TransformComponent.self, for: entity) else { continue }

            let distance = simd_length(transform.position - playerPosition)
            guard distance < Self.pickupRadius else { continue }

            // 1. Destroy the soul
            destructionQueue.enqueue(entity)

            // 2. Spawn particle effect at player position
            if !particleFrameNames.isEmpty {
                let roomID = world.getComponent(type: RoomMemberComponent.self, for: entity)?.roomID ?? UUID()
                ParticleEffectEntityFactory(
                    position:      playerPosition,
                    frameNames:    particleFrameNames,
                    frameDuration: particleFrameDuration,
                    roomID:        roomID
                ).make(in: world)
            }

            // 3. Signal level clear
            levelClearedEvent.trigger()
            return
        }
    }
}
