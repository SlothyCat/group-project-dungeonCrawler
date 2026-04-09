//
//  EnemyStrategy.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 9/4/26.
//

import Foundation

/// The top-level decision-maker for an enemy.
/// A strategy receives a BehaviourContext each frame, decides which
/// EnemyBehaviour should run, handles the transition lifecycle
/// (onActivate / onDeactivate), and delegates execution to that behaviour.
public protocol EnemyStrategy {
    func update(entity: Entity, context: BehaviourContext)
}
