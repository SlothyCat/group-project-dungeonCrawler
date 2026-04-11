import SpriteKit

/// Entry-point scene that lets the player pick a dungeon before the game starts.
/// Displays one card per entry in `DungeonLibrary.all`. Tapping a card
/// transitions to `GameScene` configured with that dungeon's layout and theme.
final class LevelSelectScene: SKScene {

    // MARK: - Lifecycle

    override func sceneDidLoad() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(white: 0.08, alpha: 1)
        buildUI()
    }

    // MARK: - UI

    private func buildUI() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "SELECT DUNGEON"
        title.fontSize = min(size.width * 0.04, 36)
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.34)
        addChild(title)

        let dungeons = DungeonLibrary.all
        let cardWidth  = size.width  * 0.26
        let cardHeight = size.height * 0.55
        let spacing    = size.width  * 0.04
        let totalWidth = CGFloat(dungeons.count) * cardWidth + CGFloat(dungeons.count - 1) * spacing
        let originX    = -totalWidth / 2 + cardWidth / 2

        for (index, dungeon) in dungeons.enumerated() {
            let x = originX + CGFloat(index) * (cardWidth + spacing)
            addCard(
                dungeon: dungeon,
                index: index,
                position: CGPoint(x: x, y: -cardHeight * 0.04),
                cardSize: CGSize(width: cardWidth, height: cardHeight)
            )
        }
    }

    private func addCard(
        dungeon: DungeonDefinition,
        index: Int,
        position: CGPoint,
        cardSize: CGSize
    ) {
        let tag = "card_\(index)"
        let accent = accentColor(for: dungeon.theme)

        // Card body
        let card = SKShapeNode(rectOf: cardSize, cornerRadius: 14)
        card.position = position
        card.fillColor = SKColor(white: 0.14, alpha: 1)
        card.strokeColor = accent
        card.lineWidth = 2
        card.name = tag
        addChild(card)

        // Accent header strip
        let stripHeight = cardSize.height * 0.09
        let strip = SKShapeNode(rectOf: CGSize(width: cardSize.width, height: stripHeight))
        strip.position = CGPoint(x: 0, y: (cardSize.height - stripHeight) / 2)
        strip.fillColor = accent
        strip.strokeColor = .clear
        strip.name = tag
        card.addChild(strip)

        // Dungeon name
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = dungeon.name
        nameLabel.fontSize = clamp(cardSize.width * 0.09, lo: 12, hi: 20)
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: 0, y: cardSize.height * 0.22)
        nameLabel.name = tag
        card.addChild(nameLabel)

        // Description
        let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        descLabel.text = dungeon.description
        descLabel.fontSize = clamp(cardSize.width * 0.065, lo: 9, hi: 13)
        descLabel.fontColor = SKColor(white: 0.72, alpha: 1)
        descLabel.horizontalAlignmentMode = .center
        descLabel.verticalAlignmentMode = .center
        descLabel.numberOfLines = 0
        descLabel.preferredMaxLayoutWidth = cardSize.width * 0.82
        descLabel.position = CGPoint(x: 0, y: -cardSize.height * 0.06)
        descLabel.name = tag
        card.addChild(descLabel)

        // "TAP TO PLAY" hint
        let tapLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        tapLabel.text = "TAP TO PLAY"
        tapLabel.fontSize = clamp(cardSize.width * 0.07, lo: 9, hi: 13)
        tapLabel.fontColor = accent
        tapLabel.horizontalAlignmentMode = .center
        tapLabel.verticalAlignmentMode = .center
        tapLabel.position = CGPoint(x: 0, y: -cardSize.height * 0.38)
        tapLabel.name = tag
        card.addChild(tapLabel)
    }

    // MARK: - Touch handling

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in nodes(at: location) {
            guard let name = node.name,
                  name.hasPrefix("card_"),
                  let indexStr = name.split(separator: "_").last,
                  let index = Int(indexStr),
                  index < DungeonLibrary.all.count
            else { continue }

            launch(dungeon: DungeonLibrary.all[index])
            return
        }
    }

    // MARK: - Scene transition

    private func launch(dungeon: DungeonDefinition) {
        guard let view else { return }
        let gameScene = GameScene(size: size)
        gameScene.anchorPoint = anchorPoint
        gameScene.scaleMode = scaleMode
        gameScene.dungeonDefinition = dungeon
        view.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
    }

    // MARK: - Helpers

    private func accentColor(for theme: TileTheme) -> SKColor {
        switch theme {
        case .chilling: return SKColor(red: 0.30, green: 0.70, blue: 1.00, alpha: 1)
        case .burning:  return SKColor(red: 1.00, green: 0.40, blue: 0.10, alpha: 1)
        case .living:   return SKColor(red: 0.30, green: 0.85, blue: 0.40, alpha: 1)
        }
    }

    private func clamp(_ value: CGFloat, lo: CGFloat, hi: CGFloat) -> CGFloat {
        Swift.max(lo, Swift.min(hi, value))
    }
}
