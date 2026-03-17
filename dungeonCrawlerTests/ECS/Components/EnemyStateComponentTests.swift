//
//  EnemyStateComponentTests.swift
//  dungeonCrawlerTests
//
//  Created by Wen Kang Yap on 17/3/26.
//

import Foundation
import XCTest
import simd
@testable import dungeonCrawler

@MainActor
final class EnemyStateComponentTests: XCTestCase {

    // MARK: - Default initialisation

    func testDefaultModeIsWander() {
        let state = EnemyStateComponent()
        XCTAssertTrue(state.mode == .wander)
    }

    func testDefaultWanderTargetIsNil() {
        let state = EnemyStateComponent()
        XCTAssertNil(state.wanderTarget)
    }

    func testDefaultDetectionRadius() {
        let state = EnemyStateComponent()
        XCTAssertEqual(state.detectionRadius, 150, accuracy: 0.001)
    }

    func testDefaultLoseRadius() {
        let state = EnemyStateComponent()
        XCTAssertEqual(state.loseRadius, 225, accuracy: 0.001)
    }

    func testDefaultWanderRadius() {
        let state = EnemyStateComponent()
        XCTAssertEqual(state.wanderRadius, 100, accuracy: 0.001)
    }

    func testDefaultWanderSpeed() {
        let state = EnemyStateComponent()
        XCTAssertEqual(state.wanderSpeed, 40, accuracy: 0.001)
    }

    func testDefaultChaseSpeed() {
        let state = EnemyStateComponent()
        XCTAssertEqual(state.chaseSpeed, 70, accuracy: 0.001)
    }

    // MARK: - Logical invariants

    func testLoseRadiusIsGreaterThanDetectionRadius() {
        let state = EnemyStateComponent()
        XCTAssertGreaterThan(state.loseRadius, state.detectionRadius)
    }

    func testChaseSpeedIsGreaterThanWanderSpeed() {
        let state = EnemyStateComponent()
        XCTAssertGreaterThan(state.chaseSpeed, state.wanderSpeed)
    }

    // MARK: - Custom initialisation

    func testCustomDetectionRadius() {
        let state = EnemyStateComponent(detectionRadius: 200)
        XCTAssertEqual(state.detectionRadius, 200, accuracy: 0.001)
    }

    func testCustomLoseRadius() {
        let state = EnemyStateComponent(loseRadius: 300)
        XCTAssertEqual(state.loseRadius, 300, accuracy: 0.001)
    }

    func testCustomWanderRadius() {
        let state = EnemyStateComponent(wanderRadius: 50)
        XCTAssertEqual(state.wanderRadius, 50, accuracy: 0.001)
    }

    func testCustomWanderSpeed() {
        let state = EnemyStateComponent(wanderSpeed: 25)
        XCTAssertEqual(state.wanderSpeed, 25, accuracy: 0.001)
    }

    func testCustomChaseSpeed() {
        let state = EnemyStateComponent(chaseSpeed: 120)
        XCTAssertEqual(state.chaseSpeed, 120, accuracy: 0.001)
    }

    // MARK: - Mutation

    func testModeCanBeChangedToChase() {
        var state = EnemyStateComponent()
        state.mode = .chase
        XCTAssertTrue(state.mode == .chase)
    }

    func testModeCanRevertToWander() {
        var state = EnemyStateComponent()
        state.mode = .chase
        state.mode = .wander
        XCTAssertTrue(state.mode == .wander)
    }

    func testWanderTargetCanBeSet() {
        var state = EnemyStateComponent()
        let target = SIMD2<Float>(100, 200)
        state.wanderTarget = target
        XCTAssertNotNil(state.wanderTarget)
        XCTAssertEqual(state.wanderTarget!.x, 100, accuracy: 0.001)
        XCTAssertEqual(state.wanderTarget!.y, 200, accuracy: 0.001)
    }

    func testWanderTargetCanBeCleared() {
        var state = EnemyStateComponent()
        state.wanderTarget = SIMD2<Float>(100, 200)
        state.wanderTarget = nil
        XCTAssertNil(state.wanderTarget)
    }
}
