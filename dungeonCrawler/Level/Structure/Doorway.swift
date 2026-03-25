//
//  Doorway.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 18/3/26.
//

import Foundation
import simd

public struct Doorway {
    /// Center position of the doorway in world coordinates.
    public let position: SIMD2<Float>
    /// Which wall face this doorway is located on.
    public let direction: Direction
    /// Width of the opening in the wall.
    public let width: Float
    
    public init(
        position: SIMD2<Float>,
        direction: Direction,
        width: Float = 64
    ) {
        self.position = position
        self.direction = direction
        self.width = width
    }
}

/// Placement intent for a doorway along its wall face.
public struct DoorwayPosition {
    /// Normalized offset (0.0 to 1.0) along the wall axis.
    /// 0.5 is the exact center.
    public let relativeOffset: Float
    
    public static var center: DoorwayPosition { DoorwayPosition(relativeOffset: 0.5) }
    
    /// Returns a randomized position within the safe middle of the wall.
    public static func jittered(using generator: inout SeededGenerator) -> DoorwayPosition {
        DoorwayPosition(relativeOffset: Float.random(in: 0.25...0.75, using: &generator))
    }
    
    public init(relativeOffset: Float) {
        self.relativeOffset = relativeOffset
    }
}
