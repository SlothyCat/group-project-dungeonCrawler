//
//  RoomStateTagComponent.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 18/3/26.
//

import Foundation

/// Tag: Room entrance is locked, preventing player from leaving
public struct RoomLockedTag: Component {}
 
/// Tag: Room is currently in combat (enemies active)
public struct RoomInCombatTag: Component {}
 
///// Tag: Room has been cleared of all enemies
//public struct RoomClearedTag: Component {}
// 
///// Tag: Room has been visited by the player
//public struct RoomVisitedTag: Component {}
// 
///// Tag: Room is currently active (player is inside)
//public struct RoomActiveTag: Component {}
 
// MARK: - Additional Tags for Map Elements
 
/// Tag: Marks an entity as a wall
public struct WallTag: Component {}
 
/// Tag: Marks an entity as a floor tile
public struct FloorTag: Component {}
 
/// Tag: Marks an entity as an obstacle
public struct ObstacleTag: Component {}
 
/// Tag: Marks an entity as a door
public struct DoorTag: Component {
    public var direction: Doorway.Direction
    
    public init(direction: Doorway.Direction) {
        self.direction = direction
    }
}
 
/// Tag: Marks a door as locked
public struct LockedDoorTag: Component {}
