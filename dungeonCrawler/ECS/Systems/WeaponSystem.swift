import Foundation
import simd

class WeaponSystem: System {
    var priority: Int = 50
    
    private var gameTime: Float

    init() {
        self.gameTime = 0
    }

    func update(deltaTime: TimeInterval, world: World) {
        self.gameTime += deltaTime

        for (weaponEntity, weaponComponent, ownerComponent) in world.entities(with: WeaponComponent.self, and: OwnerComponent.self) {
            let ownerEntity = ownerComponent.ownerEntity
            if let ownerTransformComponent = world.getComponent(type: TransformComponent.self, for: ownerEntity) {
                world.modifyComponent(type: TransformComponent.self, for: weaponEntity) { transform in
                    transform.position = ownerTransformComponent.position + ownerComponent.offset
                }
            }
        }


    }
}