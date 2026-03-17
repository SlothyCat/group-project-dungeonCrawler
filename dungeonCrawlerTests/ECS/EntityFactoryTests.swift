//
//  EntityFactoryTests.swift
//  dungeonCrawlerTests
//

import Foundation
import XCTest
import simd
@testable import dungeonCrawler

@MainActor
final class EntityFactoryTests: XCTestCase {

    var world: World!

    override func setUp() {
        super.setUp()
        world = World()
    }

    override func tearDown() {
        world = nil
        super.tearDown()
    }

    // MARK: - makePlayer

    func testMakePlayerEntityIsAlive() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        // Entity is alive if we can query a component from it
        XCTAssertNotNil(world.getComponent(type: TransformComponent.self, for: entity))
    }

    func testMakePlayerTransform() {
        let position = SIMD2<Float>(100, 200)
        let entity = EntityFactory.makePlayer(in: world, at: position)
        let transform = world.getComponent(type: TransformComponent.self, for: entity)
        XCTAssertNotNil(transform)
        XCTAssertEqual(transform!.position.x, 100, accuracy: 0.001)
        XCTAssertEqual(transform!.position.y, 200, accuracy: 0.001)
    }

    func testMakePlayerVelocity() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        let velocity = world.getComponent(type: VelocityComponent.self, for: entity)
        XCTAssertNotNil(velocity)
        XCTAssertEqual(velocity!.linear.x, 0, accuracy: 0.001)
        XCTAssertEqual(velocity!.linear.y, 0, accuracy: 0.001)
    }

    func testMakePlayerInput() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        XCTAssertNotNil(world.getComponent(type: InputComponent.self, for: entity))
    }

    func testMakePlayerSprite() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        let sprite = world.getComponent(type: SpriteComponent.self, for: entity)
        XCTAssertNotNil(sprite)
        XCTAssertEqual(sprite!.textureName, "knight")
    }

    func testMakePlayerCustomTexture() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0), textureName: "warrior")
        let sprite = world.getComponent(type: SpriteComponent.self, for: entity)
        XCTAssertNotNil(sprite)
        XCTAssertEqual(sprite!.textureName, "warrior")
    }

    func testMakePlayerTag() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        XCTAssertNotNil(world.getComponent(type: PlayerTagComponent.self, for: entity))
    }

    func testMakePlayerHealth() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        let health = world.getComponent(type: HealthComponent.self, for: entity)
        XCTAssertNotNil(health)
        XCTAssertEqual(health!.value.base, 100, accuracy: 0.001)
        XCTAssertEqual(health!.value.current, 100, accuracy: 0.001)
    }

    func testMakePlayerMoveSpeed() {
        let entity = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        let speed = world.getComponent(type: MoveSpeedComponent.self, for: entity)
        XCTAssertNotNil(speed)
        XCTAssertEqual(speed!.value.base, 90, accuracy: 0.001)
        XCTAssertEqual(speed!.value.current, 90, accuracy: 0.001)
    }

    func testMakePlayerReturnsDistinctEntities() {
        let entity1 = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(0, 0))
        let entity2 = EntityFactory.makePlayer(in: world, at: SIMD2<Float>(10, 10))
        XCTAssertNotEqual(entity1, entity2)
    }

    // MARK: - makeEnemy: entity registration

    func testMakeEnemyIsAlive() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertTrue(world.isAlive(entity: enemy))
    }

    func testMakeEnemyReturnsUniqueEntities() {
        let enemy1 = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        let enemy2 = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertNotEqual(enemy1, enemy2)
    }

    // MARK: - makeEnemy: TransformComponent

    func testMakeEnemyPositionIsSet() {
        let position = SIMD2<Float>(100, 200)
        let enemy = EntityFactory.makeEnemy(in: world, at: position, type: .charger)
        let transform = world.getComponent(type: TransformComponent.self, for: enemy)
        XCTAssertNotNil(transform)
        XCTAssertEqual(transform!.position.x, 100, accuracy: 0.001)
        XCTAssertEqual(transform!.position.y, 200, accuracy: 0.001)
    }

    func testMakeEnemyRotationIsZero() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        let transform = world.getComponent(type: TransformComponent.self, for: enemy)
        XCTAssertNotNil(transform)
        XCTAssertEqual(transform!.rotation, 0, accuracy: 0.001)
    }

    func testMakeEnemyDefaultBaseScaleUsesTypeScale() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        let transform = world.getComponent(type: TransformComponent.self, for: enemy)
        XCTAssertNotNil(transform)
        XCTAssertEqual(transform!.scale, EnemyType.charger.scale, accuracy: 0.001)
    }

    func testMakeEnemyScaleIsBaseScaleTimesTypeScale() {
        let baseScale: Float = 2.0
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .tower, baseScale: baseScale)
        let transform = world.getComponent(type: TransformComponent.self, for: enemy)
        XCTAssertNotNil(transform)
        XCTAssertEqual(transform!.scale, baseScale * EnemyType.tower.scale, accuracy: 0.001)
    }

    // MARK: - makeEnemy: SpriteComponent

    func testMakeEnemyHasSpriteComponent() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertNotNil(world.getComponent(type: SpriteComponent.self, for: enemy))
    }

    func testMakeEnemyTextureMatchesType() {
        for enemyType in [EnemyType.charger, .mummy, .ranger, .tower] {
            let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: enemyType)
            let sprite = world.getComponent(type: SpriteComponent.self, for: enemy)
            XCTAssertNotNil(sprite, "Missing sprite for \(enemyType)")
            XCTAssertEqual(sprite!.textureName, enemyType.textureName, "Texture mismatch for \(enemyType)")
        }
    }

    // MARK: - makeEnemy: EnemyTagComponent

    func testMakeEnemyHasEnemyTag() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertNotNil(world.getComponent(type: EnemyTagComponent.self, for: enemy))
    }

    func testMakeEnemyTagMatchesType() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .mummy)
        let tag = world.getComponent(type: EnemyTagComponent.self, for: enemy)
        XCTAssertNotNil(tag)
        XCTAssertTrue(tag!.enemyType == .mummy)
    }

    // MARK: - makeEnemy: VelocityComponent and EnemyStateComponent

    func testMakeEnemyHasVelocityComponent() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertNotNil(world.getComponent(type: VelocityComponent.self, for: enemy))
    }

    func testMakeEnemyVelocityStartsAtZero() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        let velocity = world.getComponent(type: VelocityComponent.self, for: enemy)
        XCTAssertNotNil(velocity)
        XCTAssertEqual(velocity!.linear.x, 0, accuracy: 0.001)
        XCTAssertEqual(velocity!.linear.y, 0, accuracy: 0.001)
    }

    func testMakeEnemyHasEnemyStateComponent() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertNotNil(world.getComponent(type: EnemyStateComponent.self, for: enemy))
    }

    func testMakeEnemyStartsInWanderMode() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        let state = world.getComponent(type: EnemyStateComponent.self, for: enemy)
        XCTAssertNotNil(state)
        XCTAssertTrue(state!.mode == .wander)
    }

    // MARK: - makeEnemy: no player components

    func testMakeEnemyHasNoInputComponent() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertNil(world.getComponent(type: InputComponent.self, for: enemy))
    }

    func testMakeEnemyHasNoPlayerTag() {
        let enemy = EntityFactory.makeEnemy(in: world, at: .zero, type: .charger)
        XCTAssertNil(world.getComponent(type: PlayerTagComponent.self, for: enemy))
    }

    // MARK: - makeEnemy: world queries

    func testEnemiesQueryableByTag() {
        EntityFactory.makeEnemy(in: world, at: SIMD2(0, 0),   type: .charger)
        EntityFactory.makeEnemy(in: world, at: SIMD2(100, 0), type: .mummy)
        let enemies = world.entities(with: EnemyTagComponent.self)
        XCTAssertEqual(enemies.count, 2)
    }

    func testPlayerAndEnemiesAreIsolated() {
        EntityFactory.makePlayer(in: world, at: .zero)
        EntityFactory.makeEnemy(in: world, at: SIMD2(100, 0), type: .charger)

        let players = world.entities(with: PlayerTagComponent.self)
        let enemies = world.entities(with: EnemyTagComponent.self)

        XCTAssertEqual(players.count, 1)
        XCTAssertEqual(enemies.count, 1)
        XCTAssertNotEqual(players.first, enemies.first)
    }
}
