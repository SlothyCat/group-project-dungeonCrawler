//
//  PlayerDeathEvent.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 29/3/26.
//

import Foundation

/// Written by HealthSystem when the player's HP reaches zero.
/// Read by GameScene after each system update to trigger game over.
/// GameScene is the sole consumer — reset this when restarting.
public final class PlayerDeathEvent {
    public private(set) var playerDied: Bool = false
 
    public func record() {
        playerDied = true
    }
 
    public func reset() {
        playerDied = false
    }
}
