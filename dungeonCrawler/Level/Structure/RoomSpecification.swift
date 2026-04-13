import Foundation

/// Pure-data description of a room, produced by `DungeonLayoutStrategy`
public struct RoomSpecification {
    public let id: UUID
    public let bounds: RoomBounds
    public let isStartRoom: Bool
    public let isBoss: Bool

    /// Strategy for populating the room with gameplay entities.
    public let populator: RoomPopulatorStrategy

    public init(
        id: UUID = UUID(),
        bounds: RoomBounds,
        isStartRoom: Bool,
        isBoss: Bool = false,
        populator: RoomPopulatorStrategy
    ) {
        self.id = id
        self.bounds = bounds
        self.isStartRoom = isStartRoom
        self.isBoss = isBoss
        self.populator = populator
    }
}
