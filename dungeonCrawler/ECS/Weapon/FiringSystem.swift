//
//  FiringSystem.swift
//  dungeonCrawler
//
//  Created by Letian on 27/3/26.
//

import Foundation

public final class FiringSystem: System {
    public var priority: Int = 70
    
    // World is the single owner of command queues
    // Firing System should not be responsible for queue
    private weak var commandQueues: CommandQueues?
    
    public func update(deltaTime: Double, world: World) {
        <#code#>
    }
}
