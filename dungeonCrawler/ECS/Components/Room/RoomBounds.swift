//
//  RoomBounds.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 18/3/26.
//

import Foundation
import simd

public struct RoomBounds {
    /// Bottom-left corner in world coordinates
    public var origin: SIMD2<Float>
    
    /// Width and height of the room
    public var size: SIMD2<Float>
    
    public init(origin: SIMD2<Float>, size: SIMD2<Float>) {
        self.origin = origin
        self.size = size
    }
    
    /// Center point of the room
    public var center: SIMD2<Float> {
        origin + size / 2
    }
    
    /// Maximum corner (top-right)
    public var max: SIMD2<Float> {
        origin + size
    }
    
    /// Check if a point is inside this room
    public func contains(_ point: SIMD2<Float>) -> Bool {
        point.x >= origin.x && point.x <= max.x &&
        point.y >= origin.y && point.y <= max.y
    }
    
    /// Get a random position within the room with margin from edges
    public func randomPosition(margin: Float = 50) -> SIMD2<Float> {
        let x = Float.random(in: (origin.x + margin)...(max.x - margin))
        let y = Float.random(in: (origin.y + margin)...(max.y - margin))
        return SIMD2<Float>(x, y)
    }
}
