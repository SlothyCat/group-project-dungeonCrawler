import Foundation
import simd

public final class WeaponSystem: System {
    public let priority: Int = 50
    
    private var gameTime: Float

    init() {
        self.gameTime = 0
    }

    public func update(deltaTime: Foundation.TimeInterval, world: World) {
        self.gameTime += Float(deltaTime)

        for (weaponEntity, weaponComponent, ownerComponent) in world.entities(with: WeaponComponent.self, and: OwnerComponent.self) {
            let ownerEntity = ownerComponent.ownerEntity
            guard let ownerTransform = world.getComponent(type: TransformComponent.self, for: ownerEntity),
                  let ownerInput = world.getComponent(type: InputComponent.self, for: ownerEntity) else { continue }

            let ownerFacing = world.getComponent(type: FacingComponent.self, for: ownerEntity)
            let facingRight = ownerFacing?.facing != .left

            let mirroredOffset = SIMD2<Float>(
                facingRight ? ownerComponent.offset.x : -ownerComponent.offset.x,
                ownerComponent.offset.y
            )

            world.modifyComponent(type: TransformComponent.self, for: weaponEntity) { transform in
                transform.position = ownerTransform.position + mirroredOffset
            }

            // Copy owner velocity so syncNode's flipFactor logic flips the weapon sprite
            world.modifyComponent(type: VelocityComponent.self, for: weaponEntity) { vel in
                vel.linear.x = facingRight ? 1.0 : -1.0
            }
            
            if ownerInput.isShooting {
                let isReadyToFire: Bool = (gameTime - weaponComponent.lastFiredAt) >= Float(weaponComponent.coolDownInterval)
                let aimDirection = ownerInput.aimDirection
                if isReadyToFire {
                    world.modifyComponent(type: WeaponComponent.self, for: weaponEntity) { weapon in
                        weapon.lastFiredAt = gameTime
                    }
                    // Only for projectile weapon now
                    // TODO: replace speed
                    spawnProjectile(from: ownerTransform.position, aimAt: aimDirection, speed: 300, owner: ownerEntity, in: world)
                }
            }
        }
    }
    
    private func spawnProjectile(from position: SIMD2<Float>,
                                 aimAt direction: SIMD2<Float>,
                                 speed: Float,
                                 owner: Entity,
                                 in world: World) {
        let projectile = world.createEntity()
        world.addComponent(component: TransformComponent(position: position, scale: 1), to: projectile)
        world.addComponent(component: VelocityComponent(linear: direction * speed), to: projectile)
        world.addComponent(component: SpriteComponent(textureName: "normalHandgunBullet", zLayer: 3), to: projectile)
        world.addComponent(component: ProjectileComponent(
            damage: 10, owner: owner, effectiveRange: 400
        ), to: projectile)
    }
}
