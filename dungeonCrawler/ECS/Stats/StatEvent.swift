//
//  StatEvent.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 29/3/26.
//

import Foundation

public struct StatChangeEvent {
    public let entity: Entity
    public let componentType: any StatProvidable.Type
    public let amount: Float
}

public final class StatEventBuffer {
    public private(set) var changes: [StatChangeEvent] = []
 
    public func clear() {
        changes.removeAll(keepingCapacity: true)
    }
 
    public func recordChange(entity: Entity, componentType: any StatProvidable.Type, amount: Float) {
        changes.append(StatChangeEvent(entity: entity, componentType: componentType, amount: amount))
    }
}
