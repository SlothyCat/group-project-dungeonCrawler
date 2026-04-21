//
//  HitEffectsLibrary.swift
//  dungeonCrawler
//
//  Created by Letian on 12/4/26.
//

import Foundation

public enum SpawnZoneEffectsLibrary {
    case fireZone
    case poisonZone

    public var effect: SpawnZoneEffect {
        switch self {
        case .fireZone:
            SpawnZoneEffect(
                textureName: "firearea",
                radius: 200,
                duration: 3,
                hitEffects: [
                    TintEffect(duration: 0.1, newTint: TintLibrary.fireTint.tint),
                    DamageEffect(amount: 3)
                ])
        case .poisonZone:
            SpawnZoneEffect(
                textureName: "poisonArea",
                radius: 200,
                duration: 3,
                hitEffects: [
                    TintEffect(duration: 0.1, newTint: TintLibrary.poisonTint.tint),
                    SlowEffect(multiplier: 0.4, duration: 0.5),
                    DamageEffect(amount: 1)
                ])
        }
    }
}
