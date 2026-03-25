import Foundation
import simd

/// Bundles all necessary information and dependencies for populating a room.
///
/// This context simplifies the `RoomPopulatorStrategy` protocol and provides
/// convenient helpers for spawning entities that are automatically tagged
/// as belonging to the current room.
public struct PopulateContext {
    public let world: World
    public let bounds: RoomBounds
    public let scale: Float
    public let roomID: UUID
    public var generator: SeededGenerator
    
    /// Tracks existing entities to prevent overlaps during a composite population session.
    public var occupiedPositions: [SIMD2<Float>] = []
    
    /// Bounding boxes of structural elements (walls, pillars) to avoid.
    public let structuralBounds: [(center: SIMD2<Float>, size: SIMD2<Float>)]

    public init(
        world: World,
        bounds: RoomBounds,
        scale: Float,
        roomID: UUID,
        generator: SeededGenerator,
        structuralBounds: [(center: SIMD2<Float>, size: SIMD2<Float>)] = []
    ) {
        self.world = world
        self.bounds = bounds
        self.scale = scale
        self.roomID = roomID
        self.generator = generator
        self.occupiedPositions = []
        self.structuralBounds = structuralBounds
    }

    /// Checks if a position is far enough from any already-occupied spots
    /// and not inside any structural bounds.
    public func isSpaceAvailable(at point: SIMD2<Float>, minDistance: Float) -> Bool {
        // 1. Check against entities in this room session
        for occupied in occupiedPositions {
            if simd_distance(point, occupied) < minDistance {
                return false
            }
        }
        
        // 2. Check against structural bounds (walls, obstacles)
        // Add a padding to the point to ensure it's not "on the line"
        let padding: Float = 4.0
        let entityBounds = RoomBounds(
            origin: point - SIMD2(padding, padding),
            size: SIMD2(padding * 2, padding * 2)
        )
        
        for structural in structuralBounds {
            // Convert structural (center, size) to RoomBounds for intersection check
            let structuralRoomBounds = RoomBounds(center: structural.center, size: structural.size)
            if structuralRoomBounds.intersects(entityBounds) {
                return false
            }
        }
        
        return true
    }

    /// Tries to find a valid spawning location within the room.
    public mutating func findEmptySpace(
        margin: Float = WorldConstants.tileSize * 2,
        minDistance: Float = WorldConstants.playerSize * 1.5,
        maxAttempts: Int = 10
    ) -> SIMD2<Float>? {
        for _ in 0..<maxAttempts {
            let pos = bounds.randomPosition(margin: margin, using: &generator)
            if isSpaceAvailable(at: pos, minDistance: minDistance) {
                return pos
            }
        }
        return nil
    }
}
