import Foundation

/// Bundles everything that defines a playable dungeon: its display info,
/// visual theme, and procedural layout strategy.
public struct DungeonDefinition {
    public let name: String
    public let description: String
    public let theme: TileTheme
    public let layoutStrategy: any DungeonLayoutStrategy

    public init(
        name: String,
        description: String,
        theme: TileTheme,
        layoutStrategy: any DungeonLayoutStrategy
    ) {
        self.name = name
        self.description = description
        self.theme = theme
        self.layoutStrategy = layoutStrategy
    }
}
