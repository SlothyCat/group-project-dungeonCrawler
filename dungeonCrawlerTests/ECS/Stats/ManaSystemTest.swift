//
//  ManaSystemTest.swift
//  dungeonCrawlerTests
//
//  Created by Jannice Suciptono on 31/3/26.
//

import Foundation
import XCTest
@testable import dungeonCrawler

final class ManaSystemTests: XCTestCase {

    var world: World!
    var system: ManaSystem!

    override func setUp() {
        super.setUp()
        world  = World()
        system = ManaSystem()
    }

    override func tearDown() {
        system = nil
        world  = nil
        super.tearDown()
    }

    // MARK: - Regen applies correctly

    func testManaIncreasesEachFrameWhenBelowMax() {
        let entity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 0, max: 100, regenRate: 10), to: entity)

        system.update(deltaTime: 1.0, world: world)

        let mana = world.getComponent(type: ManaComponent.self, for: entity)!
        XCTAssertEqual(mana.value.current, 10, accuracy: 0.001)
    }

    func testManaRegenScalesWithDeltaTime() {
        let entity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 0, max: 100, regenRate: 20), to: entity)

        system.update(deltaTime: 0.5, world: world)

        let mana = world.getComponent(type: ManaComponent.self, for: entity)!
        XCTAssertEqual(mana.value.current, 10, accuracy: 0.001)
    }

    func testManaAccumulatesOverMultipleFrames() {
        let entity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 0, max: 100, regenRate: 10), to: entity)

        system.update(deltaTime: 1.0, world: world)
        system.update(deltaTime: 1.0, world: world)
        system.update(deltaTime: 1.0, world: world)

        let mana = world.getComponent(type: ManaComponent.self, for: entity)!
        XCTAssertEqual(mana.value.current, 30, accuracy: 0.001)
    }

    // MARK: - Clamping to max

    func testManaDoesNotExceedMax() {
        let entity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 90, max: 100, regenRate: 20), to: entity)

        system.update(deltaTime: 1.0, world: world)

        let mana = world.getComponent(type: ManaComponent.self, for: entity)!
        XCTAssertEqual(mana.value.current, 100, accuracy: 0.001)
    }

    func testManaAlreadyAtMaxDoesNotChange() {
        let entity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 100, max: 100, regenRate: 10), to: entity)

        system.update(deltaTime: 1.0, world: world)

        let mana = world.getComponent(type: ManaComponent.self, for: entity)!
        XCTAssertEqual(mana.value.current, 100, accuracy: 0.001)
    }

    // MARK: - Zero regen rate

    func testZeroRegenRateDoesNotChangeMana() {
        let entity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 50, max: 100, regenRate: 0), to: entity)

        system.update(deltaTime: 1.0, world: world)

        let mana = world.getComponent(type: ManaComponent.self, for: entity)!
        XCTAssertEqual(mana.value.current, 50, accuracy: 0.001)
    }

    func testDefaultRegenRateIsZero() {
        // ManaComponent default regenRate is 0
        let entity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 40, max: 100), to: entity)

        system.update(deltaTime: 1.0, world: world)

        let mana = world.getComponent(type: ManaComponent.self, for: entity)!
        XCTAssertEqual(mana.value.current, 40, accuracy: 0.001)
    }

    // MARK: - Multiple entities handled independently

    func testMultipleEntitiesRegenIndependently() {
        let entityA = world.createEntity()
        world.addComponent(component: ManaComponent(base: 0, max: 100, regenRate: 10), to: entityA)

        let entityB = world.createEntity()
        world.addComponent(component: ManaComponent(base: 0, max: 100, regenRate: 25), to: entityB)

        system.update(deltaTime: 1.0, world: world)

        let manaA = world.getComponent(type: ManaComponent.self, for: entityA)!
        let manaB = world.getComponent(type: ManaComponent.self, for: entityB)!
        XCTAssertEqual(manaA.value.current, 10, accuracy: 0.001)
        XCTAssertEqual(manaB.value.current, 25, accuracy: 0.001)
    }

    func testEntityWithZeroRegenUnaffectedAlongsideRegenEntity() {
        let regenEntity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 0, max: 100, regenRate: 10), to: regenEntity)

        let staticEntity = world.createEntity()
        world.addComponent(component: ManaComponent(base: 50, max: 100, regenRate: 0), to: staticEntity)

        system.update(deltaTime: 1.0, world: world)

        let regenMana  = world.getComponent(type: ManaComponent.self, for: regenEntity)!
        let staticMana = world.getComponent(type: ManaComponent.self, for: staticEntity)!
        XCTAssertEqual(regenMana.value.current,  10, accuracy: 0.001)
        XCTAssertEqual(staticMana.value.current, 50, accuracy: 0.001)
    }

    // MARK: - Edge cases

    func testEntityWithoutManaComponentUnaffected() {
        let entity = world.createEntity()
        world.addComponent(component: TransformComponent(), to: entity)

        system.update(deltaTime: 1.0, world: world)

        XCTAssertNotNil(world.getComponent(type: TransformComponent.self, for: entity))
    }

    func testEmptyWorldDoesNotCrash() {
        system.update(deltaTime: 0.016, world: world)
    }
}
