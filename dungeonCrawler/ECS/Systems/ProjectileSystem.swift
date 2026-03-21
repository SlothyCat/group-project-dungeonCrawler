//
//  ProjectileSystem.swift
//  dungeonCrawler
//
//  Created by Letian on 20/3/26.
//

import Foundation
import simd

public final class ProjectileSystem: System {
    public let priority: Int = 60 // After weapon spawn new projectiles
    public func update(deltaTime: Double, world: World) {
        let dt = Float(deltaTime)
        for (projectileEntity, _, velocityComponent, _, _) in world.entities(
            with: ProjectileComponent.self,
            and: VelocityComponent.self,
            and: TransformComponent.self,
            and: EffectiveRangeComponent.self) {
            world.modifyComponent(type: TransformComponent.self, for: projectileEntity) { transform in
                transform.position += velocityComponent.linear * dt
            }
            let distanceTraveled = simd_length(velocityComponent.linear) * dt
            var remainingRange: Float = .greatestFiniteMagnitude
            world.modifyComponent(type: EffectiveRangeComponent.self, for: projectileEntity) { rangeComponent in
                rangeComponent.value.current -= distanceTraveled
                remainingRange = rangeComponent.value.current
            }
            if remainingRange <= 0 {
                world.destroyEntity(entity: projectileEntity)
            }
        }
    }
}
