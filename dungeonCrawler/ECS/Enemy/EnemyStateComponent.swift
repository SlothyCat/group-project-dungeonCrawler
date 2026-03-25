//
//  EnemyStateComponent.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 17/3/26.
//

import Foundation
import simd

public enum EnemyMode {
    case wander
    case chase
}

public struct EnemyStateComponent: Component {
    public var mode: EnemyMode = .wander
    public var detectionRadius: Float
    public var loseRadius: Float
    public var wanderTarget: SIMD2<Float>?
    public var wanderRadius: Float
    public var wanderSpeed: Float
    public var chaseSpeed: Float

    public init(
        detectionRadius: Float = 150,
        loseRadius: Float = 225,
        wanderRadius: Float = 100,
        wanderSpeed: Float = 40,
        chaseSpeed: Float = 70
    ) {
        self.detectionRadius = detectionRadius
        self.loseRadius = loseRadius
        self.wanderRadius = wanderRadius
        self.wanderSpeed = wanderSpeed
        self.chaseSpeed = chaseSpeed
    }
}
