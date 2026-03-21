//
//  ProjectileSystemTests.swift
//  dungeonCrawlerTests
//
//  Created by Letian on 20/3/26.
//

import Foundation
import XCTest
import simd
@testable import dungeonCrawler

@MainActor
final class ProjectileSystemTests: XCTestCase {
    
    var world: World!
    var system: ProjectileSystem!
    
    override func setUp() {
        super.setUp()
        world = World()
        system = ProjectileSystem()
    }
    
    override func tearDown() {
        world = nil
        system = nil
        super.tearDown()
    }
    
    static let defalutVelocity: Float = 300
    static let defaultEffectiveRange: Float = 300
    
    /// default velocity is 300
    /// defalut projectile effective range is 300
    @discardableResult
    private func makeProjectile(from position: SIMD2<Float> = SIMD2(0, 0),
                                aimAt direction: SIMD2<Float> = SIMD2(1, 0)) -> Entity {
        let speed: Float = ProjectileSystemTests.defalutVelocity
        let owner = world.createEntity()
        let projectile = world.createEntity()
        world.addComponent(component: TransformComponent(position: position, scale: 1), to: projectile)
        world.addComponent(component: VelocityComponent(linear: direction * speed), to: projectile)
        world.addComponent(component: SpriteComponent(textureName: "normalHandgunBullet", zLayer: 3), to: projectile)
        world.addComponent(component: ProjectileComponent(
            damage: 10, owner: owner, effectiveRange: ProjectileSystemTests.defaultEffectiveRange
        ), to: projectile)
        return projectile
    }
    
    func testProjectileEffectiveRangeDecreaseByTime() {
        let projectile = makeProjectile()
        system.update(deltaTime: 0.1, world: world)
        let effectiveRangeAfter = world.getComponent(type: ProjectileComponent.self, for: projectile)!.effectiveRange
        XCTAssertEqual(effectiveRangeAfter, ProjectileSystemTests.defaultEffectiveRange - ProjectileSystemTests.defalutVelocity * 0.1, accuracy: 0.001)
    }
    
    func testProjectileDestroyedAfterEffectiveRangeBecomeZero() {
        let projectile = makeProjectile()
        system.update(deltaTime: 1, world: world)
        let projectileAfter = world.getComponent(type: ProjectileComponent.self, for: projectile) ?? nil
        XCTAssertNil(projectileAfter)
    }
    
    func testProjectileDestroyedAfterEffectiveRangeBecomeZeroAndAfter() {
        let projectile = makeProjectile()
        system.update(deltaTime: 1.1, world: world)
        let projectileAfter = world.getComponent(type: ProjectileComponent.self, for: projectile) ?? nil
        XCTAssertNil(projectileAfter)
    }
    
    func testProjectileNotDestroyedWhenEffectiveRangeLargerThanZero() {
        let projectile = makeProjectile()
        system.update(deltaTime: 0.9, world: world)
        let projectileAfter = world.getComponent(type: ProjectileComponent.self, for: projectile) ?? nil
        XCTAssertNotNil(projectileAfter)
    }
}
