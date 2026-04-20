//
//  DamageSystem.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 29/3/26.
//

import Foundation

public final class DamageSystem: System {
    public let priority: Int = 40

    private let events: CollisionEventBuffer
    private let destructionQueue: DestructionQueue

    public init(events: CollisionEventBuffer, destructionQueue: DestructionQueue) {
        self.events = events
        self.destructionQueue = destructionQueue
    }

    public func update(deltaTime: Double, world: World) {
        applyContactDamage(world: world)
    }

    // MARK: - Enemy contact → Player

    private func applyContactDamage(world: World) {
        for event in events.playerHitByEnemy {
            guard world.isAlive(entity: event.player) else { continue }

            // Skip if entity is currently in invincibility frames
            guard world.getComponent(type: InvincibilityComponent.self, for: event.player) == nil else { continue }

            if let contactDamage = world.getComponent(type: ContactDamageComponent.self, for: event.enemy),
               let health = world.getComponent(type: HealthComponent.self, for: event.player) {
                health.value.current -= contactDamage.damage
                health.value.clampToMin()
            }

            // Grant invincibility frames so the next collision hit doesn't immediately deal damage again
            world.addComponent(component: InvincibilityComponent(remainingTime: 0.5), to: event.player)
        }
    }
}
