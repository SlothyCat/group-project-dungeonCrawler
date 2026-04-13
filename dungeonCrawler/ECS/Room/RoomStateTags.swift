import Foundation

/// Tag: Room requires a lockdown action (has not yet been cleared)
public struct CombatEncounterTag: Component {}

/// Tag: Room is currently in combat (enemies active)
public struct RoomInCombatTag: Component {}

/// Tag: Room has been cleared of all enemies
public struct RoomClearedTag: Component {}

/// Tag: Room has been visited by the player at least once
public struct RoomVisitedTag: Component {}

/// Tag: This room is the boss room of the dungeon.
/// Attached by `LevelGenerationManager` when `RoomSpecification.isBoss` is true.
public struct BossRoomTag: Component {}
