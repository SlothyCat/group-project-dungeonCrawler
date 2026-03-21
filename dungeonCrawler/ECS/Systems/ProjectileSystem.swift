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
        for (projectileEntity, _, velocityComponent, _) in world.entities(with: ProjectileComponent.self, and: VelocityComponent.self, and: TransformComponent.self) {
            world.modifyComponent(type: TransformComponent.self, for: projectileEntity) { transform in
                transform.position += velocityComponent.linear * dt
            }
            world.modifyComponent(type: ProjectileComponent.self, for: projectileEntity) { pComponent in
                pComponent.effectiveRange -= simd_length(velocityComponent.linear) * dt
            }
            if let p = world.getComponent(type: ProjectileComponent.self, for: projectileEntity), p.effectiveRange <= 0 {
                world.destroyEntity(entity: projectileEntity)
            }
        }
    }
}
