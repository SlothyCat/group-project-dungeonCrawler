import Foundation

/// Holds the global state of the current level.
/// Attached to a single "Global Entity" in the world.
public class LevelStateComponent: Component {
    /// The graph structure of the current level.
    public var graph: DungeonGraph?
    
    /// The ID of the currently active room node.
    public var activeNodeID: UUID?
    
    /// Cooldown timer to prevent rapid-fire transitions.
    public var transitionCooldown: Float = 0

    public init(graph: DungeonGraph? = nil, activeNodeID: UUID? = nil) {
        self.graph = graph
        self.activeNodeID = activeNodeID
    }
}
