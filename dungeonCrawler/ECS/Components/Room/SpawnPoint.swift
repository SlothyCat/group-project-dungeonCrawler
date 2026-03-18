//
//  SpawnPoint.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 18/3/26.
//

import Foundation
import simd

public struct SpawnPoint {
    public var position: SIMD2<Float>
    public var type: SpawnType
    public var isUsed: Bool
    
    public init(position: SIMD2<Float>, type: SpawnType, isUsed: Bool = false) {
        self.position = position
        self.type = type
        self.isUsed = isUsed
    }
    
    public enum SpawnType {
        case playerEntry
        case enemy
    }
}
