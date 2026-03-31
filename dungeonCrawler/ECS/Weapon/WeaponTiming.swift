//
//  WeaponTiming.swift
//  dungeonCrawler
//
//  Created by Letian on 31/3/26.
//

import Foundation

class WeaponTiming {
    var coolDownInterval: TimeInterval
    var attackSpeed: Float?
    init(coolDownInterval: TimeInterval, attackSpeed: Float? = nil) {
        self.coolDownInterval = coolDownInterval
        self.attackSpeed = attackSpeed
    }
}
