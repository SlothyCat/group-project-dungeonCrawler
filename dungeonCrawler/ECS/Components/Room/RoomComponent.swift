//
//  RoomComponent.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 18/3/26.
//

import Foundation
import simd

public struct RoomComponent: Component {
    public let roomID: UUID
    public var bounds: RoomBounds
    public var doorways: [Doorway]
    public var spawnPoints: [SpawnPoint]
    
    /// Grid layout for interior generation (optional, for tile-based rooms)
    public var gridLayout: GridLayout?
    
    public init(
        roomID: UUID = UUID(),
        bounds: RoomBounds,
        doorways: [Doorway] = [],
        spawnPoints: [SpawnPoint] = [],
        gridLayout: GridLayout? = nil
    ) {
        self.roomID = roomID
        self.bounds = bounds
        self.doorways = doorways
        self.spawnPoints = spawnPoints
        self.gridLayout = gridLayout
    }
}

// MARK: - Supporting Types

public struct GridLayout {
    /// Number of cells in X and Y
    public var gridSize: SIMD2<Int>
    
    /// Size of each cell in world units
    public var cellSize: Float
    
    /// 2D array representing tile types (0 = floor, 1 = wall, 2 = obstacle, etc.)
    public var tiles: [[TileType]]
    
    public init(gridSize: SIMD2<Int>, cellSize: Float) {
        self.gridSize = gridSize
        self.cellSize = cellSize
        self.tiles = Array(repeating: Array(repeating: .floor, count: gridSize.x),
                          count: gridSize.y)
    }
    
    /// Convert grid coordinates to world position
    public func worldPosition(gridX: Int, gridY: Int, roomOrigin: SIMD2<Float>) -> SIMD2<Float> {
        let x = roomOrigin.x + Float(gridX) * cellSize + cellSize / 2
        let y = roomOrigin.y + Float(gridY) * cellSize + cellSize / 2
        return SIMD2<Float>(x, y)
    }
    
    public enum TileType: Int {
        case floor = 0
        case wall = 1
        case obstacle = 2
        case pit = 3
    }
}
