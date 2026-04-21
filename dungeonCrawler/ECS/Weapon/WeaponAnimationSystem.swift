//
//  WeaponAimingSystem.swift
//  dungeonCrawler
//
//  Created by Letian on 19/4/26.
//

import Foundation
import simd

/// Every frame, poses each primary weapon relative to its owner: position,
/// rotation, facing, and sprite layer. Fire direction resolution lives in
/// `WeaponAimResolver` so `WeaponEffectSystem` can reuse the same rule when firing.
public final class WeaponAnimationSystem: System {
    public var dependencies: [System.Type] { [InputSystem.self] }

    public init() {}

    public func update(deltaTime: Double, world: World) {
        let delta = Float(deltaTime)

        for (weaponEntity, ownerComponent, weaponTransform, weaponRenderComponent) in world.entities(
            with: OwnerComponent.self,
            and: TransformComponent.self,
            and: WeaponRenderComponent.self
        ) {
            let ownerEntity = ownerComponent.ownerEntity
            if let equipped = world.getComponent(type: EquippedWeaponComponent.self, for: ownerEntity),
               equipped.primaryWeapon != weaponEntity {
                continue
            }

            guard let ownerTransform = world.getComponent(type: TransformComponent.self, for: ownerEntity),
                  let ownerInput = world.getComponent(type: InputComponent.self, for: ownerEntity) else { continue }

            let ownerFacing: AnimationDirection
            if let anim = world.getComponent(type: AnimationComponent.self, for: ownerEntity) {
                ownerFacing = AnimationDirection(animationDirection: anim.lastDirection)
            } else {
                ownerFacing = world.getComponent(type: FacingComponent.self, for: ownerEntity)?.facing ?? .right
            }

            let resolved = WeaponAimResolver.resolve(input: ownerInput, fallbackFacing: ownerFacing)

            let weaponFacing = resolved.facing
            let isLeft = weaponFacing.isLeft
            let aimAngle = atan2(resolved.direction.y, resolved.direction.x)

            if let sprite = world.getComponent(type: SpriteComponent.self, for: weaponEntity),
               sprite.layer == .weaponBack || sprite.layer == .weaponFront {
                sprite.layer = isLeft ? .weaponBack : .weaponFront
            }

            let mirroredOffset = SIMD2<Float>(
                isLeft ? -weaponRenderComponent.offset.x : weaponRenderComponent.offset.x,
                weaponRenderComponent.offset.y
            )

            let initRotationOffset = weaponRenderComponent.initRotation
            let mirroredInitRotation = isLeft ? -initRotationOffset : initRotationOffset

            let defaultWeaponRotation = isLeft ? (aimAngle - .pi) : aimAngle
            var renderedRotation = defaultWeaponRotation + mirroredInitRotation

            if let swing = world.getComponent(type: WeaponSwingComponent.self, for: weaponEntity) {
                let progressedElapsed = swing.elapsed + delta
                if progressedElapsed >= swing.duration {
                    world.removeComponent(type: WeaponSwingComponent.self, from: weaponEntity)
                } else {
                    let progress = progressedElapsed / swing.duration
                    let offset = sin(2 * (0.25 - progress) * .pi) * swing.amplitude * swing.directionSign
                    renderedRotation = swing.baseRotation + offset
                    swing.elapsed = progressedElapsed
                }
            }

            weaponTransform.position = ownerTransform.position + mirroredOffset
            weaponTransform.rotation = renderedRotation

            world.getComponent(type: FacingComponent.self, for: weaponEntity)?.facing = weaponFacing
        }
    }
}
