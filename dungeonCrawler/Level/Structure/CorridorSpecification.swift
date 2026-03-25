import Foundation

public struct CorridorSpecification {
    public let length: Float
    public let width: Float
    public let populator: RoomPopulatorStrategy

    public init(
        length: Float,
        width: Float = 64,
        populator: RoomPopulatorStrategy = EmptyRoomPopulator()
    ) {
        self.length = length
        self.width = width
        self.populator = populator
    }
}
