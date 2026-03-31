//
//  SpawnProjectilesEffect.swift
//  dungeonCrawler
//
//  Created by Letian on 31/3/26.
//

import Foundation
import simd

/**
 * effect of spawning projectiles
 *
 * modifiable parameters:
 *  - speed: Float
 *  - effective range: Float
 *  - damage: Float
 *  - sprite: String
 *  - collision box size: SIMD2<Float>
 */

struct SpawnProjectileEffect: WeaponEffect {
    let speed: Float
    let effectiveRange: Float
    let damage: Float
    let spriteName: String
    let collisionSize: SIMD2<Float>

    func apply(context: FireContext) -> FireEffectResult {
        ProjectileEntityFactory(
            from: context.spawnPosition,
            aimAt: context.fireDirection,
            speed: speed,
            effectiveRange: effectiveRange,
            damage: damage,
            owner: context.owner,
            spriteName: spriteName,
            collisionBoxSize: collisionSize
        ).make(in: context.world)

        return .success
    }
}
