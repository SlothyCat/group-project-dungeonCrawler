//
//  FacingComponentTests.swift
//  dungeonCrawlerTests
//
//  Created by Letian on 21/3/26.
//

import Foundation
import XCTest
import simd
@testable import dungeonCrawler

/**
 * Now only player entity has facing component composed
 *
 * Only 9 cases can happen
 * Move: left, right, no-op
 * Fire: left, right, no-op
 */
@MainActor
class FacingComponentTests: XCTestCase {
    var world: World!
    var mockProvider: MockInputProvider!
    var system: InputSystem!

    override func setUp() {
        super.setUp()
        world = World()
        mockProvider = MockInputProvider()
        system = InputSystem(inputProvider: mockProvider)
    }

    override func tearDown() {
        system = nil
        mockProvider = nil
        world = nil
        super.tearDown()
    }
    
    private func initEntity() -> Entity {
        let entity = world.createEntity()
        world.addComponent(component: InputComponent(), to: entity)
        return entity
    }
    
//    func testMoveLeftAimLeft() {
//        let player = initEntity()
//        mockProvider.rawMoveVector = SIMD2<Float>(-1, 0)
//        mockProvider.rawAimVector = SIMD2<Float>(-1, 0)
//    }
}
