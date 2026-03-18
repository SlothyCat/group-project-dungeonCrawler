//
//  SpriteComponent.swift
//  dungeonCrawler
//
//  Created by Jannice Suciptono on 11/3/26.
//

import Foundation

public struct SpriteComponent: Component {
    /// Asset catalog name for the entity's texture.
    public var textureName: String

    /// RGBA tint applied on top of the texture. Default = opaque white (no tint).
    public var tintRed: Float
    public var tintGreen: Float
    public var tintBlue: Float
    public var tintAlpha: Float
    public var renderSize: SIMD2<Float>?
    public var zPosition: CGFloat

    public init(
        textureName: String,
        tintRed: Float = 1, tintGreen: Float = 1,
        tintBlue: Float = 1, tintAlpha: Float = 1,
        renderSize: SIMD2<Float>? = nil, zPosition: CGFloat = 1
    ) {
        self.textureName = textureName
        self.tintRed = tintRed
        self.tintGreen = tintGreen
        self.tintBlue = tintBlue
        self.tintAlpha = tintAlpha
        self.renderSize = renderSize
        self.zPosition = zPosition
    }
}

// MARK: - Convenience presets for map geometry
 
public extension SpriteComponent {
    /// Solid black rectangle — used for perimeter walls.
    static func wall(size: SIMD2<Float>) -> SpriteComponent {
        SpriteComponent(
            textureName: "",
            tintRed: 0, tintGreen: 0, tintBlue: 0, tintAlpha: 1,
            renderSize: size
        )
    }
 
    /// Solid dark-green rectangle — used for the floor fill.
    static func floor(size: SIMD2<Float>) -> SpriteComponent {
        SpriteComponent(
            textureName: "",
            tintRed: 0.13, tintGreen: 0.25, tintBlue: 0.13, tintAlpha: 1,
            renderSize: size,
            zPosition: 0
        )
    }
}
