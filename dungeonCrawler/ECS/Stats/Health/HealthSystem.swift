//
//  HealthSystem.swift
//  dungeonCrawler
//
//  Created by Ger Teck on 16/3/26.
//

import Foundation

public final class HealthSystem: System {

    public var dependencies: [System.Type] { [EnemyAISystem.self] }
    
    private let destructionQueue: DestructionQueue
    private let playerDeathEvent: PlayerDeathEvent

    public init(destructionQueue: DestructionQueue, playerDeathEvent: PlayerDeathEvent) {
        self.destructionQueue = destructionQueue
        self.playerDeathEvent = playerDeathEvent
    }

    public func update(deltaTime: Double, world: World) {
        for entity in world.entities(with: HealthComponent.self) {
            guard let health = world.getComponent(type: HealthComponent.self, for: entity)
            else { continue }
            
            guard health.value.current <= 0 else { continue }

            let isPlayer = world.getComponent(type: PlayerTagComponent.self, for: entity) != nil
            if isPlayer {
                // Signal GameScene to handle game over
                // Do not destroy the player entity here, as other systems still reference it this frame.
                playerDeathEvent.record()
            } else {
                destructionQueue.enqueue(entity)
            }
        }
    }
}
