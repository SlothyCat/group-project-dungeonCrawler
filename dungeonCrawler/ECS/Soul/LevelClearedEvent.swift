import Foundation

/// Written by `SoulPickupSystem` when the player collects the boss-room soul.
/// Read by `GameScene` to show the level-clear overlay and transition back
/// to the dungeon select screen.
/// GameScene is the sole consumer — call `reset()` when handling.
public final class LevelClearedEvent {
    public private(set) var triggered = false

    public func trigger() {
        triggered = true
    }

    public func reset() {
        triggered = false
    }
}
