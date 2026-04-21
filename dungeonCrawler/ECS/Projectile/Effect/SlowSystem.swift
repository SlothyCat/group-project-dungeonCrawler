//
//  SlowSystem.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 19/4/26.
//

import Foundation

/// Runs after EnemyAISystem (behaviours write full-speed velocity) and before
/// MovementSystem (integrates velocity into position).
/// Scales VelocityComponent.linear by the slow multiplier so behaviours never
/// need to know about SlowComponent. Also manages tint and timer expiry.
public final class SlowSystem: System {
    public var dependencies: [System.Type] { [EnemyAISystem.self] }

    public init() {}

    public func update(deltaTime: Double, world: World) {
        let dt = Float(deltaTime)
        for entity in world.entities(with: SlowComponent.self) {
            guard let slow = world.getComponent(type: SlowComponent.self, for: entity) else { continue }

            // Scale the velocity that EnemyAISystem just wrote this frame
            if let velocity = world.getComponent(type: VelocityComponent.self, for: entity) {
                velocity.linear *= slow.multiplier
            }


            slow.remaining -= dt
            if slow.remaining <= 0 {
                world.removeComponent(type: SlowComponent.self, from: entity)
            }
        }
    }
}
