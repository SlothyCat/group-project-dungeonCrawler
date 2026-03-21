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
    /// Logical layering order for the sprite, mapped directly to `SKSpriteNode.zPosition`.
    /// Higher values are rendered in front of lower values. Conventionally, use small
    /// integer layers (e.g. 0 = background, 1 = world, 2 = UI). Default = 1.
    public var zLayer: Float

    /// RGBA tint applied on top of the texture. Default = opaque white (no tint).
    public var tintRed: Float
    public var tintGreen: Float
    public var tintBlue: Float
    public var tintAlpha: Float

    public init(
        textureName: String,
        zLayer: Float = 1,
        tintRed: Float = 1, tintGreen: Float = 1,
        tintBlue: Float = 1, tintAlpha: Float = 1
    ) {
        self.textureName = textureName
        self.zLayer = zLayer
        self.tintRed = tintRed
        self.tintGreen = tintGreen
        self.tintBlue = tintBlue
        self.tintAlpha = tintAlpha
    }
}
