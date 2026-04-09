//
//  StandardStrategy.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 9/4/26.
//

import Foundation

/// A standard enemy strategy: wanders when idle, attacks when the player is within detectionRadius.
/// Once attacking, continues until the player moves beyond loseRadius (or forever if loseRadius is nil).
///
/// Use this for enemies that engage aggressively and don't retreat.
/// Swap attackBehaviour to ChaseBehaviour or ShooterBehaviour depending on the enemy type.
public struct StandardStrategy: EnemyStrategy {

    public var detectionRadius: Float
    public var loseRadius: Float?
    public var wanderBehaviour: WanderBehaviour
    public var attackBehaviour: any EnemyBehaviour

    public init(
        detectionRadius: Float = 150,
        loseRadius: Float? = 225,
        wanderBehaviour: WanderBehaviour = WanderBehaviour(),
        attackBehaviour: any EnemyBehaviour = ChaseBehaviour()
    ) {
        self.detectionRadius = detectionRadius
        self.loseRadius = loseRadius
        self.wanderBehaviour = wanderBehaviour
        self.attackBehaviour = attackBehaviour
    }

    public func update(entity: Entity, context: BehaviourContext) {
        let currentID = context.world.getComponent(type: ActiveBehaviourComponent.self, for: entity)?.behaviourID
        let isAttacking = currentID == attackBehaviour.id

        let shouldAttack: Bool
        if isAttacking {
            // Keep attacking until player leaves loseRadius
            // nil loseRadius means never disengage, alw chase
            shouldAttack = loseRadius.map { context.distToPlayer <= $0 } ?? true
        } else {
            shouldAttack = context.distToPlayer <= detectionRadius
        }

        let chosen: any EnemyBehaviour = shouldAttack ? attackBehaviour : wanderBehaviour
        activate(chosen, from: [wanderBehaviour, attackBehaviour], for: entity, context: context)
    }
}
