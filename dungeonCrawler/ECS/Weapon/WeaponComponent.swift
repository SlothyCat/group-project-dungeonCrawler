import Foundation

struct WeaponComponent: Component {
    var type: WeaponType
    var damage: Float
    var manaCost: Float
    var attackSpeed: Float
    var coolDownInterval: TimeInterval
    var lastFiredAt: Float = 0

    init(type: WeaponType,
         damage: Float,
         manaCost: Float,
         attackSpeed: Float,
         coolDownInterval: TimeInterval,
         lastFiredAt: Float) {
        self.type = type
        self.damage = damage
        self.manaCost = manaCost
        self.attackSpeed = attackSpeed
        self.coolDownInterval = coolDownInterval
        self.lastFiredAt = lastFiredAt
    }
}

public enum WeaponType: String {
    case handgun
    case sword
    case bow
    case sniper

    var textureName: String {
        switch self {
        case .handgun: return "handgun"
        case .sniper: return "Sniper"
        case .sword: return "sword"
        case .bow: return "bow"
        }
    }
    
    var damage: Float {
        switch self {
        case .handgun: return 15.0
        case .bow:     return 20.0
        case .sniper:  return 50.0
        case .sword:   return 25.0
        }
    }
 
    /// Mana consumed per shot.
    var manaCost: Float {
        switch self {
        case .handgun: return 5.0
        case .bow:     return 8.0
        case .sniper:  return 20.0
        case .sword:   return 0.0
        }
    }
}
