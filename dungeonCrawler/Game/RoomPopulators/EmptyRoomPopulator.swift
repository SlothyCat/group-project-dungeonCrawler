import Foundation

/// A populator that does nothing. Used for start rooms, safe rooms, 
/// or any room that should be empty by default.
public struct EmptyRoomPopulator: RoomPopulatorStrategy {
    public init() {}

    public func populate(context: inout PopulateContext) {
        // No-op: this room is intentionally left empty (e.g., start room)
    }
}
