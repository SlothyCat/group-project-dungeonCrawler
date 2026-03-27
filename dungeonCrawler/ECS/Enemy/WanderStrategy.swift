//
//  WanderStrategy.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 27/3/26.
//

import Foundation
import simd

/// A strategy that Enemy will wander around by choosing a random point within the wanderRadius
/// Simple AI movement when Player is not in range
public final class WanderStrategy: EnemyAIStrategy {

    // entity refers to Enemy here and the transform is the enemy's transform
    public func update(entity: Entity, transform: TransformComponent, playerPos: SIMD2<Float>, world: World) {
        guard let currentState = world.getComponent(type: EnemyStateComponent.self, for: entity) else { return }

        world.modifyComponent(type: EnemyStateComponent.self, for: entity) { s in
            let arrivalThreshold: Float = 8

            if s.wanderTarget == nil ||
                simd_length(transform.position - s.wanderTarget!) < arrivalThreshold {
                let angle = Float.random(in: 0..<(2 * .pi))
                let radius = Float.random(in: 0...s.wanderRadius)
                s.wanderTarget = transform.position +
                SIMD2(cos(angle) * radius, sin(angle) * radius)
            }
        }

        // extra verification that target has been set before calculating velocity to target
        guard let target = world.getComponent(type: EnemyStateComponent.self, for: entity)?.wanderTarget else { return }

        let wanderDelta = target - transform.position
        guard simd_length_squared(wanderDelta) > 1e-6 else { return }

        world.modifyComponent(type: VelocityComponent.self, for: entity) { vel in
            vel.linear = normalize(wanderDelta) * currentState.wanderSpeed
        }
    }
}
