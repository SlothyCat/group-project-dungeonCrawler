//
//  CollisionEvents.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 21/3/26.
//

import Foundation
// MARK: - Event kinds
 
/// A projectile has overlapped a solid surface (wall or obstacle) this frame.
public struct ProjectileHitSolidEvent {
    /// The projectile entity that collided.
    public let projectile: Entity
    /// The solid entity that was hit (wall, obstacle, …).
    public let solid: Entity
}
 
// MARK: - Shared event buffer
 
/// Owned by CollisionSystem; passed into any system that needs to react to collisions.
/// Systems should only *read* from this buffer — CollisionSystem is the sole writer.
public final class CollisionEventBuffer {
    public private(set) var projectileHitSolid: [ProjectileHitSolidEvent] = []
 
    /// Called once at the top of CollisionSystem.update to discard last frame's events.
    public func clear() {
        projectileHitSolid.removeAll(keepingCapacity: true)
    }
 
    /// CollisionSystem calls this whenever it detects a projectile↔solid overlap.
    public func recordProjectileHitSolid(projectile: Entity, solid: Entity) {
        projectileHitSolid.append(ProjectileHitSolidEvent(projectile: projectile, solid: solid))
    }
}
 
