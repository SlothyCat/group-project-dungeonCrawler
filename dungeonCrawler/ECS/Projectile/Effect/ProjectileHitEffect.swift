//
//  ProjectileHitEffect.swift
//  dungeonCrawler
//
//  Created by Letian on 12/4/26.
//

import Foundation
import simd

public protocol ProjectileHitEffect {
    func apply(context: HitContext)
}
