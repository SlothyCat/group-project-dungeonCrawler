import Foundation

// Boundary between game logic and level generation

/// Defines a strategy for populating a room with gameplay entities (enemies, items, etc.).
public protocol RoomPopulatorStrategy {

    /// Populates the given world with entities for the specified room.
    func populate(context: inout PopulateContext)
}
