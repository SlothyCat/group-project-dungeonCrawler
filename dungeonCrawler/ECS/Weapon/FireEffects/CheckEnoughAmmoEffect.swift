//
//  CheckEnoughAmmoEffect.swift
//  dungeonCrawler
//
//  Created by Letian on 18/4/26.
//

import Foundation

struct CheckEnoughAmmoEffect: WeaponEffect {
    func apply(context: FireContext) -> FireEffectResult {
        guard let ammo = context.world.getComponent(type: WeaponAmmoComponent.self, for: context.weapon) else {
            // No ammo component means unlimited — let it through.
            return .success
        }

        guard !ammo.isReloading else {
            return .blocked("reloading")
        }

        guard ammo.currentAmmo > 0 else {
            // Trigger auto-reload and block this shot.
            ammo.isReloading = true
            ammo.reloadElapsed = 0
            return .blocked("empty_magazine")
        }

        // Auto-reload the moment the last bullet leaves the chamber.
        if ammo.currentAmmo == 0 {
            ammo.isReloading = true
            ammo.reloadElapsed = 0
        }

        return .success
    }
}
