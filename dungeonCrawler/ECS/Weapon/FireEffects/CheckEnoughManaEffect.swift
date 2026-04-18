//
//  CheckEnoughManaEffect.swift
//  dungeonCrawler
//
//  Created by Letian on 18/4/26.
//

import Foundation

struct CheckEnoughManaEffect: WeaponEffect {
    let amount: Float
    
    func apply(context: FireContext) -> FireEffectResult {
        guard let mana = context.world.getComponent(type: ManaComponent.self, for: context.owner) else {
            return .success
        }
        guard mana.value.current >= amount else {
            return .blocked("insufficient_mana")
        }
        return .success
    }
}
