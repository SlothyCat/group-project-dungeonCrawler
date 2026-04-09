//
//  EnemyAISystem.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 17/3/26.
//

import Foundation
import simd

public final class EnemyAISystem: System {
    public var dependencies: [System.Type] { [KnockbackSystem.self] }

    public init() {}

    public func update(deltaTime: Double, world: World) {
        guard let (_, _, playerTransform) = world.entities(
            with: PlayerTagComponent.self, and: TransformComponent.self
        ).first else { return }

        let playerPos = playerTransform.position

        for (enemy, state, transform) in world.entities(with: EnemyStateComponent.self,
                                                         and: TransformComponent.self) {
            guard world.getComponent(type: KnockbackComponent.self, for: enemy) == nil else { continue }
            guard world.getComponent(type: VelocityComponent.self, for: enemy) != nil else { continue }

            let context = BehaviourContext(entity: enemy,
                                           playerPos: playerPos,
                                           transform: transform,
                                           world: world)
            state.strategy.update(entity: enemy, context: context)
        }
    }
}
