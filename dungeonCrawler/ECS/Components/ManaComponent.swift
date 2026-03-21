import Foundation

struct ManaComponent: Component {
    var currentMana: Float
    var maxMana: Float
    var manaRegenRate: Float

    init(currentMana: Float, maxMana: Float, manaRegenRate: Float) {
        self.currentMana = currentMana
        self.maxMana = maxMana
        self.manaRegenRate = manaRegenRate
    }
}