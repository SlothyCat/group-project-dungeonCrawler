//
//  MovementSystemTests.swift
//  dungeonCrawlerTests
//
//  Created by Jannice Suciptono on 16/3/26.
//

import Testing
import simd
@testable import dungeonCrawler

@Suite("MovementSystem")
struct MovementSystemTests {

    // MARK: - Helpers

    private func makeWorld() -> World { World() }
    private func makeSystem() -> MovementSystem { MovementSystem() }

    /// Adds the minimum components for a player-controlled movable entity.
    private func makePlayer(
        in world: World,
        at position: SIMD2<Float> = .zero,
        direction: SIMD2<Float> = .zero,
        speed: Float = 100
    ) -> Entity {
        let entity = world.createEntity()
        world.addComponent(component: TransformComponent(position: position), to: entity)
        world.addComponent(component: VelocityComponent(), to: entity)
        world.addComponent(component: InputComponent(moveDirection: direction), to: entity)
        world.addComponent(component: MoveSpeedComponent(base: speed), to: entity)
        return entity
    }

    /// Adds the minimum components for an enemy movable entity.
    private func makeEnemy(
        in world: World,
        at position: SIMD2<Float> = .zero,
        velocity: SIMD2<Float> = .zero
    ) -> Entity {
        let entity = world.createEntity()
        world.addComponent(component: TransformComponent(position: position), to: entity)
        world.addComponent(component: VelocityComponent(linear: velocity), to: entity)
        world.addComponent(component: EnemyStateComponent(), to: entity)
        return entity
    }

    // MARK: - Basic Player Movement

    @Test func basicMovement() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makePlayer(in: world, direction: SIMD2(1, 0), speed: 100)

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 10) < 0.01)
        #expect(abs(transform.position.y - 0)  < 0.01)
    }

    @Test func movementInAllDirections() throws {
        let directions: [SIMD2<Float>] = [
            SIMD2(1, 0), SIMD2(-1, 0), SIMD2(0, 1), SIMD2(0, -1), SIMD2(1, 1)
        ]
        for direction in directions {
            let world = makeWorld(); let system = makeSystem()
            let entity = makePlayer(in: world, direction: direction, speed: 100)

            system.update(deltaTime: 0.1, world: world)

            let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
            let expected = direction * 100 * 0.1
            #expect(abs(transform.position.x - expected.x) < 0.01)
            #expect(abs(transform.position.y - expected.y) < 0.01)
        }
    }

    @Test func noMovementWhenDirectionIsZero() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makePlayer(in: world, at: SIMD2(10, 20), direction: .zero)

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 10) < 0.01)
        #expect(abs(transform.position.y - 20) < 0.01)
    }

    @Test func velocityIsSetFromInput() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makePlayer(in: world, direction: SIMD2(1, 0), speed: 100)

        system.update(deltaTime: 0.1, world: world)

        let velocity = try #require(world.getComponent(type: VelocityComponent.self, for: entity))
        #expect(abs(velocity.linear.x - 100) < 0.01)
        #expect(abs(velocity.linear.y - 0)   < 0.01)
    }

    @Test func differentMoveSpeed() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makePlayer(in: world, direction: SIMD2(1, 0), speed: 200)

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 20) < 0.01)
    }

    // MARK: - Time Step Variations

    @Test func differentDeltaTimes() throws {
        for dt: Double in [0.016, 0.033, 0.1, 1.0] {
            let world = makeWorld(); let system = makeSystem()
            let entity = makePlayer(in: world, direction: SIMD2(1, 0), speed: 100)

            system.update(deltaTime: dt, world: world)

            let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
            let expected = Float(dt) * 100
            #expect(abs(transform.position.x - expected) < 0.01)
        }
    }

    @Test func accumulatedMovementOverMultipleFrames() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makePlayer(in: world, direction: SIMD2(1, 0), speed: 100)

        for _ in 0..<10 {
            system.update(deltaTime: 0.016, world: world)
        }

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        let expected = Float(0.016 * 10) * 100
        #expect(abs(transform.position.x - expected) < 0.1)
    }

    // MARK: - Missing Components

    @Test func entityWithoutTransformDoesNotCrash() {
        let world = makeWorld(); let system = makeSystem()
        let entity = world.createEntity()
        world.addComponent(component: VelocityComponent(), to: entity)
        world.addComponent(component: InputComponent(moveDirection: SIMD2(1, 0)), to: entity)
        world.addComponent(component: MoveSpeedComponent(base: 100), to: entity)

        // Must not crash
        system.update(deltaTime: 0.1, world: world)
    }

    @Test func entityWithoutVelocityNotMoved() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = world.createEntity()
        world.addComponent(component: TransformComponent(position: SIMD2(0, 0)), to: entity)
        world.addComponent(component: InputComponent(moveDirection: SIMD2(1, 0)), to: entity)
        world.addComponent(component: MoveSpeedComponent(base: 100), to: entity)

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 0) < 0.01)
    }

    @Test func entityWithoutInputNotMoved() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = world.createEntity()
        world.addComponent(component: TransformComponent(position: SIMD2(0, 0)), to: entity)
        world.addComponent(component: VelocityComponent(), to: entity)

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 0) < 0.01)
    }

    @Test func entityWithoutMoveSpeedSkipped() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = world.createEntity()
        world.addComponent(component: TransformComponent(position: SIMD2(5, 5)), to: entity)
        world.addComponent(component: VelocityComponent(), to: entity)
        world.addComponent(component: InputComponent(moveDirection: SIMD2(1, 0)), to: entity)

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 5) < 0.01)
        #expect(abs(transform.position.y - 5) < 0.01)
    }

    // MARK: - Multiple Entities

    @Test func multipleEntitiesMovingIndependently() throws {
        let world = makeWorld(); let system = makeSystem()
        let e1 = makePlayer(in: world, direction: SIMD2(1, 0), speed: 100)
        let e2 = makePlayer(in: world, direction: SIMD2(0, 1), speed: 100)

        system.update(deltaTime: 0.1, world: world)

        let t1 = try #require(world.getComponent(type: TransformComponent.self, for: e1))
        let t2 = try #require(world.getComponent(type: TransformComponent.self, for: e2))
        #expect(abs(t1.position.x - 10) < 0.01)
        #expect(abs(t1.position.y - 0)  < 0.01)
        #expect(abs(t2.position.x - 0)  < 0.01)
        #expect(abs(t2.position.y - 10) < 0.01)
    }

    @Test func noEntitiesDoesNotCrash() {
        let world = makeWorld(); let system = makeSystem()
        system.update(deltaTime: 0.1, world: world)
    }

    // MARK: - Knockback Suppression

    @Test func playerInKnockbackNotMovedByInput() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makePlayer(in: world, direction: SIMD2(1, 0), speed: 100)
        world.addComponent(
            component: KnockbackComponent(velocity: SIMD2(-100, 0), remainingTime: 0.3),
            to: entity
        )

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 0) < 0.01)
        #expect(abs(transform.position.y - 0) < 0.01)
    }

    @Test func enemyInKnockbackNotMovedByMovementSystem() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makeEnemy(in: world, velocity: SIMD2(100, 0))
        world.addComponent(
            component: KnockbackComponent(velocity: SIMD2(-100, 0), remainingTime: 0.3),
            to: entity
        )

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 0) < 0.01)
        #expect(abs(transform.position.y - 0) < 0.01)
    }

    // MARK: - Enemy Movement

    @Test func enemyWithVelocityIsMovedBySystem() throws {
        let world = makeWorld(); let system = makeSystem()
        let entity = makeEnemy(in: world, velocity: SIMD2(100, 0))

        system.update(deltaTime: 0.1, world: world)

        let transform = try #require(world.getComponent(type: TransformComponent.self, for: entity))
        #expect(abs(transform.position.x - 10) < 0.01)
        #expect(abs(transform.position.y - 0)  < 0.01)
    }
}
