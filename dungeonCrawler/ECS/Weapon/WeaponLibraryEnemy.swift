//
//  WeaponPresets.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 18/4/26.
//

import Foundation
import simd

public extension WeaponLibraryEnemy {

    /// Basic ranged weapon used by the Ranger enemy.
    /// No ammo config — enemies have unlimited supply.
    static let enemyRangedDefault = WeaponLibraryEnemy(
        textureName: "EnemyBullet",
        offset: .zero,
        scale: 1.0,
        lastFiredAt: nil,
        cooldown: 0.5,
        attackSpeed: 150,
        effects: [
            SpawnLinearProjectileEffect(
                speed: 180,
                effectiveRange: 300,
                spriteName: "normalHandgunBullet",
                collisionSize: SIMD2<Float>(6, 6),
                hitEffects: [
                    DamageEffect(amount: 8)
                ]
            )
        ],
        anchorPoint: SIMD2<Float>(0.5, 0.5),
        initRotation: 0
    )

    /// Attack weapon used by the Tower enemy.
    static let towerAttack = WeaponLibraryEnemy(
        textureName: "EnemyBullet",
        offset: .zero,
        scale: 1.0,
        lastFiredAt: nil,
        cooldown: 0.2,
        attackSpeed: 200,
        effects: [
            SpawnLinearProjectileEffect(
                speed: 250,
                effectiveRange: 300,
                spriteName: "normalHandgunBullet",
                collisionSize: SIMD2<Float>(6, 6),
                hitEffects: [
                    DamageEffect(amount: 8)
                ]
            )
        ],
        anchorPoint: SIMD2<Float>(0.5, 0.5),
        initRotation: 0
    )
}
