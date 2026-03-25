//
//  RoomEntityFactory.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 24/3/26.
//

import Foundation
import simd

// Creates a room entity with all necessary components
//
// Components attached:
//   • RoomComponent       — bounds, doorways, spawn points
//   • TransformComponent  — position at room center (for spatial queries)
//
// Future additions:
//   • RoomThemeComponent  — visual style (dungeon, forest, ice cave)
//   • RoomLootComponent   — treasure chest spawn points

public struct RoomEntityFactory: EntityFactory {
    let roomID: UUID?
    let bounds: RoomBounds
    let doorways: [Doorway]
    let spawnPoints: [SpawnPoint]
    let useGrid: Bool

    public init(
        roomID: UUID? = nil,
        bounds: RoomBounds,
        doorways: [Doorway] = [],
        spawnPoints: [SpawnPoint] = [],
        useGrid: Bool = false
    ) {
        self.roomID = roomID
        self.bounds = bounds
        self.doorways = doorways
        self.spawnPoints = spawnPoints
        self.useGrid = useGrid
    }

    @discardableResult
    public func make(in world: World) -> Entity {
        let entity = world.createEntity()
        let rid = roomID ?? UUID()

        let metadata = RoomMetadataComponent(
            roomID: rid,
            bounds: bounds,
            doorways: doorways,
            spawnPoints: spawnPoints
        )
        world.addComponent(component: metadata, to: entity)
        world.addComponent(component: TransformComponent(position: bounds.center), to: entity)
        world.addComponent(component: RoomMemberComponent(roomID: rid), to: entity)
        return entity
    }
}
