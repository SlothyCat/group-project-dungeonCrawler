import Foundation

typealias FireBehaviour = (WeaponComponent) -> Void

struct WeaponComponent: Component {
    var fireBehaviour: FireBehaviour
    var manaCost: Float
    var attackSpeed: Float
    var coolDownInterval: TimeInterval
    var lastFiredAt: Float = 0

    // @escaping as the closure outlive init function call
    init(fireBehaviour: @escaping FireBehaviour,
         manaCost: Float,
         attackSpeed: Float,
         coolDownInterval: TimeInterval,
         lastFiredAt: Float = 0) {
        self.fireBehaviour = fireBehaviour
        self.manaCost = manaCost
        self.attackSpeed = attackSpeed
        self.coolDownInterval = coolDownInterval
        self.lastFiredAt = lastFiredAt
    }
}
