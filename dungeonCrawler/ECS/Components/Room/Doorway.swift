//
//  Doorway.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 18/3/26.
//

import Foundation
import simd

public struct Doorway {
    public var position: SIMD2<Float>
    /// Direction the doorway faces (north, south, east, west)
    public var direction: Direction
    /// Width of the doorway opening
    public var width: Float
    public var connectedRoomID: UUID?
    public var isLocked: Bool
    
    public init(
        position: SIMD2<Float>,
        direction: Direction,
        width: Float = 64,
        connectedRoomID: UUID? = nil,
        isLocked: Bool = false
    ) {
        self.position = position
        self.direction = direction
        self.width = width
        self.connectedRoomID = connectedRoomID
        self.isLocked = isLocked
    }
    
    public enum Direction {
        case north, south, east, west
        
        public var vector: SIMD2<Float> {
            switch self {
            case .north: return SIMD2<Float>(0, 1)
            case .south: return SIMD2<Float>(0, -1)
            case .east:  return SIMD2<Float>(1, 0)
            case .west:  return SIMD2<Float>(-1, 0)
            }
        }
    }
}
