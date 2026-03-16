//
//  CollisionSystem.swift
//  dungeonCrawler
//
//  Created by Yu Letian on 16/3/26.
//

public final class CollisionSystem: System {
    public let priority: Int = 10

    public func update(deltaTime: Double, world: World) {
        // OBB collision detection and resolution using SAT (Separating Axis Theorem).
        
    }
    
    public func minimumTranslationVector(
        transformA: TransformComponent, boxA: CollisionBoxComponent,
        transformB: TransformComponent, boxB: CollisionBoxComponent) {
        
    }
}
