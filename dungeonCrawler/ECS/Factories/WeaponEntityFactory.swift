//
//  WeaponEntityFactory.swift
//  dungeonCrawler
//
//  Created by Wen Kang Yap on 24/3/26.
//

import Foundation
import simd

public struct WeaponEntityFactory: EntityFactory {
    let player: Entity
    let textureName: String
    let offset: SIMD2<Float>
    let scale: Float
    let lastFiredAt: Float

    public init(
        ownedBy player: Entity,
        textureName: String = "handgun",
        offset: SIMD2<Float> = .zero,
        scale: Float = 1,
        lastFiredAt: Float = 0
    ) {
        self.player = player
        self.textureName = textureName
        self.offset = offset
        self.scale = scale
        self.lastFiredAt = lastFiredAt
    }

    @discardableResult
    public func make(in world: World) -> Entity {
        let entity = world.createEntity()
        let startPos = world.getComponent(type: TransformComponent.self, for: player)?.position ?? .zero
        world.addComponent(component: TransformComponent(position: startPos + offset, rotation: 0, scale: scale), to: entity)
        let facingOfOwner = world.getComponent(type: FacingComponent.self, for: player)?.facing ?? .right
        world.addComponent(component: FacingComponent(facing: facingOfOwner), to: entity)
        world.addComponent(component: SpriteComponent(
            content: .texture(name: textureName),
            layer: .weapon
        ), to: entity)
        world.addComponent(component: OwnerComponent(ownerEntity: player, offset: offset), to: entity)
        world.addComponent(component: WeaponComponent(
            type: .handgun,
            manaCost: 10,
            attackSpeed: 1,
            coolDownInterval: TimeInterval(0.2),
            lastFiredAt: lastFiredAt
        ), to: entity)
        return entity
    }
}
