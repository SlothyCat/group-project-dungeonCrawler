//
//  WeaponDefinition.swift
//  dungeonCrawler
//
//  Created by Letian on 31/3/26.
//

import Foundation

struct WeaponDefinition {
    var visual: WeaponVisual
    var timing: WeaponTiming
    var effects: [any WeaponEffect]
}
