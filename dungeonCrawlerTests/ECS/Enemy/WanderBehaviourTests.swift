//
//  WanderBehaviourTests.swift
//  dungeonCrawlerTests
//
//  Created by Wen Kang Yap on 9/4/26.
//

import XCTest
import simd
@testable import dungeonCrawler

@MainActor
final class WanderBehaviourTests: XCTestCase {

    // MARK: - Properties
    var world: World!
    var enemy: Entity!

    // Behaviours
    var behaviour: WanderBehaviour!
    var customRadiusBehaviour: WanderBehaviour!
    var customSpeedBehaviour: WanderBehaviour!

    // Components
    var transform: TransformComponent!
    var velocity: VelocityComponent!
    var wanderTargetComp: WanderTargetComponent!

    // Room (shared across room-aware tests)
    var roomMeta: RoomMetadataComponent!
    var roomMember: RoomMemberComponent!

    // Context
    var context: BehaviourContext!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()

        // 1. Core ECS
        world = World()
        enemy = world.createEntity()

        // 2. Behaviours
        behaviour = WanderBehaviour()
        customRadiusBehaviour = WanderBehaviour(wanderRadius: 200)
        customSpeedBehaviour = WanderBehaviour(wanderSpeed: 60)

        // 3. Components
        transform = TransformComponent(position: .zero)
        velocity = VelocityComponent()
        wanderTargetComp = WanderTargetComponent()

        // 4. Initial World State
        world.addComponent(component: transform, to: enemy)
        world.addComponent(component: velocity, to: enemy)

        // 5. Room entity — added to world so roomBounds lookups work in room-aware tests.
        //    Enemy is NOT joined to the room here; individual tests call joinRoom() as needed.
        roomMeta = RoomMetadataComponent(bounds: RoomBounds(center: .zero, size: SIMD2(600, 600)))
        let roomEntity = world.createEntity()
        world.addComponent(component: roomMeta, to: roomEntity)

        // 6. Default Context
        context = BehaviourContext(entity: enemy, playerPos: SIMD2(999, 999), transform: transform, world: world)
    }

    override func tearDown() {
        // Nil class instances in dependency order before world is released
        context = nil
        roomMember = nil
        roomMeta = nil
        wanderTargetComp = nil
        velocity = nil
        transform = nil

        customSpeedBehaviour = nil
        customRadiusBehaviour = nil
        behaviour = nil

        enemy = nil
        world = nil

        super.tearDown()
    }

    // MARK: - Helpers

    /// Attaches the enemy to the shared room so context.roomBounds resolves.
    private func joinRoom() {
        roomMember = RoomMemberComponent(roomID: roomMeta.roomID)
        world.addComponent(component: roomMember, to: enemy)
    }

    // MARK: - Default initialisation

    func testDefaultWanderRadius() {
        XCTAssertEqual(WanderBehaviour().wanderRadius, 100, accuracy: 0.001)
    }

    func testDefaultWanderSpeed() {
        XCTAssertEqual(WanderBehaviour().wanderSpeed, 40, accuracy: 0.001)
    }

    func testDefaultWallMargin() {
        XCTAssertEqual(WanderBehaviour().wallMargin, 40, accuracy: 0.001)
    }

    // MARK: - Lazy WanderTargetComponent

    func testWanderTargetComponentAbsentBeforeFirstUpdate() {
        XCTAssertNil(world.getComponent(type: WanderTargetComponent.self, for: enemy))
    }

    func testWanderTargetComponentAddedOnFirstUpdate() {
        behaviour.update(entity: enemy, context: context)
        XCTAssertNotNil(world.getComponent(type: WanderTargetComponent.self, for: enemy))
    }

    // MARK: - Deactivation cleanup
    // TODO: fix
//    func testWanderTargetComponentRemovedOnDeactivate() {
//        behaviour.update(entity: enemy, context: context)
//
//        // Capture reference to prevent deallocation crash during removal
//        let target = world.getComponent(type: WanderTargetComponent.self, for: enemy)
//        XCTAssertNotNil(target)
//
//        behaviour.onDeactivate(entity: enemy, context: context)
//        XCTAssertNil(world.getComponent(type: WanderTargetComponent.self, for: enemy))
//    }

    // MARK: - Update behaviour

    func testUpdateProducesNonZeroVelocity() {
        behaviour.update(entity: enemy, context: context)

        let vel = world.getComponent(type: VelocityComponent.self, for: enemy)!
        XCTAssertGreaterThan(simd_length(vel.linear), 0)
    }

    func testVelocityMagnitudeEqualsWanderSpeed() {
        let speed: Float = 50
        let specificBehaviour = WanderBehaviour(wanderSpeed: speed)

        specificBehaviour.update(entity: enemy, context: context)

        let vel = world.getComponent(type: VelocityComponent.self, for: enemy)!
        XCTAssertEqual(simd_length(vel.linear), speed, accuracy: 0.01)
    }

    func testWanderTargetMinRadiusFloor() {
        behaviour.update(entity: enemy, context: context)

        let target = world.getComponent(type: WanderTargetComponent.self, for: enemy)?.target
        XCTAssertNotNil(target)
        XCTAssertGreaterThan(simd_length(target! - transform.position), 0)
    }

    // MARK: - Target persistence

    func testWanderTargetPersistedBetweenUpdates() throws {
        behaviour.update(entity: enemy, context: context)
        let target1 = world.getComponent(type: WanderTargetComponent.self, for: enemy)!.target

        behaviour.update(entity: enemy, context: context)
        let target2 = world.getComponent(type: WanderTargetComponent.self, for: enemy)!.target

        XCTAssertEqual(target1!.x, target2!.x, accuracy: 0.001)
        XCTAssertEqual(target1!.y, target2!.y, accuracy: 0.001)
    }

    func testVelocityDirectionIsConsistentBeforeArrival() {
        behaviour.update(entity: enemy, context: context)
        let vel1 = world.getComponent(type: VelocityComponent.self, for: enemy)!.linear

        behaviour.update(entity: enemy, context: context)
        let vel2 = world.getComponent(type: VelocityComponent.self, for: enemy)!.linear

        XCTAssertEqual(vel1.x, vel2.x, accuracy: 0.001)
        XCTAssertEqual(vel1.y, vel2.y, accuracy: 0.001)
    }

    // MARK: - Room bounds: target stays inside safe area

    func testWanderTargetInsideRoomSafeAreaWhenRoomIsPresent() {
        joinRoom()
        let safeArea = roomMeta.bounds.inset(by: behaviour.wallMargin)

        // Spin up fresh entities so each gets exactly one update and one new candidate,
        // without calling removeComponent (which crashes in setStore).
        // All entities and their components live in the world until world = nil in tearDown.
        for _ in 0..<20 {
            let sampleEntity = world.createEntity()
            world.addComponent(component: TransformComponent(position: .zero), to: sampleEntity)
            world.addComponent(component: VelocityComponent(), to: sampleEntity)
            world.addComponent(component: RoomMemberComponent(roomID: roomMeta.roomID), to: sampleEntity)

            let sampleTransform = world.getComponent(type: TransformComponent.self, for: sampleEntity)!
            let sampleContext = BehaviourContext(entity: sampleEntity, playerPos: SIMD2(999, 999),
                                                 transform: sampleTransform, world: world)
            behaviour.update(entity: sampleEntity, context: sampleContext)

            let target = world.getComponent(type: WanderTargetComponent.self, for: sampleEntity)?.target
            if let t = target {
                XCTAssertTrue(safeArea.contains(t),
                              "Target \(t) is outside safe area \(safeArea)")
            }
        }
    }

    func testWanderTargetPicksValidPointWhenEnemyNearWall() {
        joinRoom()
        let safeArea = roomMeta.bounds.inset(by: behaviour.wallMargin)
        let wallPos = SIMD2<Float>(roomMeta.bounds.maxX - 10, roomMeta.bounds.center.y)

        // Same pattern: fresh entity per sample, no removeComponent calls.
        for _ in 0..<10 {
            let sampleEntity = world.createEntity()
            world.addComponent(component: TransformComponent(position: wallPos), to: sampleEntity)
            world.addComponent(component: VelocityComponent(), to: sampleEntity)
            world.addComponent(component: RoomMemberComponent(roomID: roomMeta.roomID), to: sampleEntity)

            let sampleTransform = world.getComponent(type: TransformComponent.self, for: sampleEntity)!
            let sampleContext = BehaviourContext(entity: sampleEntity, playerPos: SIMD2(999, 999),
                                                 transform: sampleTransform, world: world)
            behaviour.update(entity: sampleEntity, context: sampleContext)

            let target = world.getComponent(type: WanderTargetComponent.self, for: sampleEntity)?.target
            if let t = target {
                XCTAssertTrue(safeArea.contains(t),
                              "Near-wall target \(t) is outside safe area \(safeArea)")
            }
        }
    }

    func testWanderBehaviourWithoutRoomMembershipStillProducesTarget() {
        // No RoomMemberComponent on the enemy → roomBounds is nil → unconstrained fallback
        behaviour.update(entity: enemy, context: context)
        XCTAssertNotNil(world.getComponent(type: WanderTargetComponent.self, for: enemy)?.target,
                        "Should still pick a target when no room bounds are available")
    }
}
