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
    let weaponType: WeaponType
    let offset: SIMD2<Float>
    let scale: Float
    let lastFiredAt: Float

    public init(
        ownedBy player: Entity,
        weaponType: WeaponType = .handgun,
        offset: SIMD2<Float> = .zero,
        scale: Float = 1,
        lastFiredAt: Float = 0
    ) {
        self.player = player
        self.weaponType = weaponType
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
            content: .texture(name: weaponType.textureName),
            layer: .weapon
        ), to: entity)
        world.addComponent(component: OwnerComponent(ownerEntity: player, offset: offset), to: entity)
        world.addComponent(component: WeaponComponent(
            type: weaponType,
            manaCost: 10,
            attackSpeed: 1,
            coolDownInterval: weaponType == .sniper ?  : ,
            lastFiredAt: lastFiredAt
        ), to: entity)
        return entity
    }
}

enum WeaponType: String {

    case handgun
//    case sword
//    case bow
    case sniper

    var textureName: String {
        switch self {
        case .handgun: return "handgun"
        case .sniper: return "Sniper"
//        case .sword: return "sword"
//        case .bow: return "bow"
        }
    }

    private func makeComponent(lastFiredAt: Float) -> WeaponComponent {
        switch self {
        case .handgun:
            return WeaponComponent(
                fireBehaviour: ,
                manaCost: 10,
                attackSpeed: 3,
                coolDownInterval: TimeInterval(0.2),
                lastFiredAt: lastFiredAt)
        case .sniper:
            return WeaponComponent(
                fireBehaviour: ,
                manaCost: 20,
                attackSpeed: 1,
                coolDownInterval: TimeInterval(0.8),
                lastFiredAt: lastFiredAt)
        }
    }
}


