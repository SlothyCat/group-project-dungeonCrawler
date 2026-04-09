//
//  EnemyBehaviour.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 9/4/26.
//

import Foundation

/// Strategies compose behaviours and decide which one runs each frame.
///
/// - `id` uniquely identifies the behaviour type for switch detection.
/// - `onActivate` and `onDeactivate` are lifecycle hooks called once on transition.
public protocol EnemyBehaviour {
    var id: String { get }
    func update(entity: Entity, context: BehaviourContext)
    func onActivate(entity: Entity, context: BehaviourContext)
    func onDeactivate(entity: Entity, context: BehaviourContext)
}

/// This is a default implementation so that behaviours only need to implement update, if no other changes required
public extension EnemyBehaviour {
    /// Defaults to the type name, e.g. "WanderBehaviour".
    var id: String { String(describing: type(of: self)) }
    func onActivate(entity: Entity, context: BehaviourContext) {}
    func onDeactivate(entity: Entity, context: BehaviourContext) {}
}
