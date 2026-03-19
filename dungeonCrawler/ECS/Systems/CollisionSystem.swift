//
//  CollisionSystem.swift
//  dungeonCrawler
//
//  Created by Yu Letian on 16/3/26.
//

import Foundation
import simd

public final class CollisionSystem: System {
    public let priority: Int = 30

    public func update(deltaTime: Double, world: World) {
        let dt = Float(deltaTime)
        // Need entities with BOTH Transform and CollisionBox components
        let collidables = world.entities(
            with: TransformComponent.self,
            and: CollisionBoxComponent.self
        )
        for i in 0..<collidables.count {
            let (entityA, transformA, boxA) = collidables[i]
            for j in (i + 1)..<collidables.count {
                let (entityB, transformB, boxB) = collidables[j]
                if let mtv = minimumTranslationVector(
                    transformA: transformA, boxA: boxA,
                    transformB: transformB, boxB: boxB
                ) {
                    resolveCollision(entityA: entityA, entityB: entityB, mtv: mtv,
                                     transformA: transformA, transformB: transformB, world: world)
                }
            }
        }
    }

    /// Returns true if the two OBBs overlap.
    public func checkCollision(
        transformA: TransformComponent, boxA: CollisionBoxComponent,
        transformB: TransformComponent, boxB: CollisionBoxComponent
    ) -> Bool {
        minimumTranslationVector(transformA: transformA, boxA: boxA,
                                  transformB: transformB, boxB: boxB) != nil
    }

    /// Returns the MTV that separates A from B, or nil if they do not overlap.
    /// Uses SAT (Separating Axis Theorem) on the four OBB face-normal axes.
    private func minimumTranslationVector(
        transformA: TransformComponent, boxA: CollisionBoxComponent,
        transformB: TransformComponent, boxB: CollisionBoxComponent
    ) -> SIMD2<Float>? {
        let halfA = SIMD2<Float>(boxA.width / 2, boxA.height / 2)
        let halfB = SIMD2<Float>(boxB.width / 2, boxB.height / 2)

        // Face-normal axes for each OBB (right and up vectors after rotation).
        let axesA = obbAxes(rotation: transformA.rotation)
        let axesB = obbAxes(rotation: transformB.rotation)
        let axes: [SIMD2<Float>] = [axesA.0, axesA.1, axesB.0, axesB.1]

        var minOverlap = Float.infinity
        var mtvAxis   = SIMD2<Float>.zero

        for axis in axes {
            let projA = project(center: transformA.position, halfExtents: halfA, rotation: transformA.rotation, onto: axis)
            let projB = project(center: transformB.position, halfExtents: halfB, rotation: transformB.rotation, onto: axis)
            let o = min(projA.max, projB.max) - max(projA.min, projB.min)
            guard o > 0 else { return nil }  // Separating axis found, can be separated by a line
            if o < minOverlap {
                minOverlap = o
                mtvAxis = axis
            }
        }

        // Ensure MTV points from B toward A.
        if dot(transformA.position - transformB.position, mtvAxis) < 0 {
            mtvAxis = -mtvAxis
        }
        return mtvAxis * minOverlap
    }

    /// OBB helpers

    private func obbAxes(rotation: Float) -> (SIMD2<Float>, SIMD2<Float>) {
        (SIMD2<Float>(cos(rotation), sin(rotation)),
         SIMD2<Float>(-sin(rotation), cos(rotation)))
    }

    private func project(center: SIMD2<Float>, halfExtents: SIMD2<Float>, rotation: Float,
                         onto axis: SIMD2<Float>) -> (min: Float, max: Float) {
        let (right, up) = obbAxes(rotation: rotation)
        let r = abs(dot(right, axis)) * halfExtents.x + abs(dot(up, axis)) * halfExtents.y
        let c = dot(center, axis)
        return (c - r, c + r)
    }

    private func resolveCollision(entityA: Entity, entityB: Entity, mtv: SIMD2<Float>,
                                   transformA: TransformComponent, transformB: TransformComponent,
                                   world: World) {

        let aIsStatic = world.getComponent(type: VelocityComponent.self, for: entityA) == nil
        let bIsStatic = world.getComponent(type: VelocityComponent.self, for: entityB) == nil
        let aIsPlayer = world.getComponent(type: PlayerTagComponent.self, for: entityA) != nil
        let bIsPlayer = world.getComponent(type: PlayerTagComponent.self, for: entityB) != nil
        
        if aIsStatic && bIsStatic {
            return // Two static entities — nothing moves.
        } else if aIsStatic || bIsStatic {
            resolveStaticCollision(dynamic: aIsStatic ? entityB : entityA,
                                   mtv: aIsStatic ? -mtv : mtv,
                                   world: world)
        } else if aIsPlayer || bIsPlayer {
            let (player, enemy, pushTowardPlayer) = aIsPlayer
                ? (entityA, entityB,  mtv)
                : (entityB, entityA, -mtv)
            resolvePlayerEnemyCollision(player: player, enemy: enemy,
                                        pushTowardPlayer: pushTowardPlayer, world: world)
        } else {
            resolveEnemyEnemyCollision(entityA: entityA, entityB: entityB, mtv: mtv, world: world)
        }
    }
    
    /// Dynamic entity (player or enemy) hits a static entity (wall, obstacle).
    /// Only the dynamic entity is displaced; the static one never moves.
    private func resolveStaticCollision(dynamic: Entity, mtv: SIMD2<Float>, world: World) {
        world.modifyComponent(type: TransformComponent.self, for: dynamic) {
            $0.position += mtv
        }
    }
    
    /// Player and enemy overlap — small nudge for the player, larger for the enemy,
    /// and knockback applied to both if not already in knockback.
    private func resolvePlayerEnemyCollision(player: Entity, enemy: Entity, pushTowardPlayer: SIMD2<Float>, world: World) {
        let playerBounce: Float = 0.1
        let enemyBounce: Float = 0.75
        let knockbackSpeed: Float = 150
        let knockbackDuration: Float = 0.1
        let bounceDir = normalize(pushTowardPlayer)
 
        world.modifyComponent(type: TransformComponent.self, for: player) {
            $0.position += pushTowardPlayer * playerBounce
        }
        world.modifyComponent(type: TransformComponent.self, for: enemy) {
            $0.position -= pushTowardPlayer * enemyBounce
        }
        applyKnockbackIfNeeded(to: player, velocity:  knockbackSpeed * bounceDir,
                               duration: knockbackDuration, world: world)
        applyKnockbackIfNeeded(to: enemy,  velocity: -knockbackSpeed * bounceDir,
                               duration: knockbackDuration, world: world)
    }
 
    /// Two enemies overlap — equal positional split, no knockback.
    private func resolveEnemyEnemyCollision(entityA: Entity, entityB: Entity, mtv: SIMD2<Float>, world: World) {
        world.modifyComponent(type: TransformComponent.self, for: entityA) { $0.position += mtv * 0.5 }
        world.modifyComponent(type: TransformComponent.self, for: entityB) { $0.position -= mtv * 0.5 }
    }
 
    /// Adds a KnockbackComponent only if the entity is not already being knocked back.
    private func applyKnockbackIfNeeded(to entity: Entity, velocity: SIMD2<Float>, duration: Float, world: World) {
        guard world.getComponent(type: KnockbackComponent.self, for: entity) == nil else { return }
        world.addComponent(
            component: KnockbackComponent(velocity: velocity, remainingTime: duration),
            to: entity
        )
    }
}
