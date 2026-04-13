import Foundation
import simd

/// Written by `RoomClearSystem` when all enemies in the boss room are defeated.
/// Read by `GameScene` to spawn the soul collectible at the room centre.
/// GameScene is the sole consumer — call `consume()` immediately after handling.
public final class BossRoomClearedEvent {
    public private(set) var roomCenter: SIMD2<Float>?
    public private(set) var roomID: UUID?

    public func trigger(center: SIMD2<Float>, roomID: UUID) {
        self.roomCenter = center
        self.roomID     = roomID
    }

    public func consume() {
        roomCenter = nil
        roomID     = nil
    }
}
