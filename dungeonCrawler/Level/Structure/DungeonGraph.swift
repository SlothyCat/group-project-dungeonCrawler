import Foundation

/// The dungeon-specific metadata carried by each directed arc in a `DungeonGraph`.
private struct DungeonEdgeData {
    let exitDirection:  Direction
    let entryDirection: Direction
    let isLocked:       Bool
    let corridor:       CorridorSpecification
    let relativeOffset: Float
}

/// Directed connection between two rooms in a `DungeonGraph`.
/// Use Directed from the start to allow future one-way connections.
public struct DungeonEdge {
    public let fromNodeID: UUID
    public let toNodeID: UUID

    // Directions are for which wall the doorway is on (exit = from, entry = to)
    public let exitDirection: Direction
    public let entryDirection: Direction

    public let isLocked: Bool
    public let corridor: CorridorSpecification
    public let relativeOffset: Float

    fileprivate init(_ edge: Graph<UUID, RoomSpecification, DungeonEdgeData>.Edge) {
        fromNodeID     = edge.from
        toNodeID       = edge.to
        exitDirection  = edge.data.exitDirection
        entryDirection = edge.data.entryDirection
        isLocked       = edge.data.isLocked
        corridor       = edge.data.corridor
        relativeOffset = edge.data.relativeOffset
    }
}

// MARK: - Graph

/// A directed graph of dungeon rooms, built on top of the generic `Graph` ADT.
///
/// `DungeonGraph` owns the topology of a level: rooms and connections.
public struct DungeonGraph {

    private typealias G = Graph<UUID, RoomSpecification, DungeonEdgeData>
    private var graph: G
    public let startNodeID: UUID

    /// Creates a graph seeded with the start room.
    public init(startingRoomSpecification: RoomSpecification) {
        var g = G()
        g.setNode(startingRoomSpecification.id, data: startingRoomSpecification)
        graph       = g
        startNodeID = startingRoomSpecification.id
    }

    /// Adds a room to the graph.
    public mutating func addRoom(_ specification: RoomSpecification) {
        graph.setNode(specification.id, data: specification)
    }

    /// Adds a directed connection from one room to another.
    public mutating func addConnection(
        from:            UUID,
        to:              UUID,
        exitDirection:   Direction,
        entryDirection:  Direction,
        isLocked:        Bool  = false,
        corridor:        CorridorSpecification = .init(length: 100),
        position:        DoorwayPosition = .center
    ) {
        let data = DungeonEdgeData(
            exitDirection:   exitDirection,
            entryDirection:  entryDirection,
            isLocked:        isLocked,
            corridor:        corridor,
            relativeOffset:  position.relativeOffset
        )
        graph.addEdge(from: from, to: to, data: data)
    }

    /// Adds a bidirectional corridor between two rooms, automatically mirroring the
    /// directions and properties for both directions.
    public mutating func addBidirectionalConnection(
        from:           UUID,
        to:             UUID,
        exitDirection:  Direction,
        entryDirection: Direction,
        isLocked:       Bool  = false,
        corridor:       CorridorSpecification = .init(length: 100),
        position:       DoorwayPosition = .center
    ) {
        // Forward: A -> B
        addConnection(
            from: from, to: to,
            exitDirection: exitDirection, entryDirection: entryDirection,
            isLocked: isLocked, corridor: corridor,
            position: position
        )
        // Backward: B -> A (mirrored)
        addConnection(
            from: to, to: from,
            exitDirection: entryDirection, entryDirection: exitDirection,
            isLocked: isLocked, corridor: corridor,
            position: position
        )
    }

    // MARK: - Collection Accessors, Queries

    /// All room specifications in the graph (order not guaranteed).
    public var allSpecifications: [RoomSpecification] {
        graph.allNodeIDs.compactMap { graph.node($0) }
    }

    /// All directed edges in the graph.
    public var allEdges: [DungeonEdge] {
        graph.allEdges.map { DungeonEdge($0) }
    }

    /// Returns the room specification for `id`, or `nil` if it does not exist.
    public func specification(for id: UUID) -> RoomSpecification? {
        graph.node(id)
    }

    /// All outgoing edges from the room with `id`.
    public func edges(from id: UUID) -> [DungeonEdge] {
        graph.edges(from: id).map { DungeonEdge($0) }
    }

    /// The directed edge from `from` to `to`, if it exists.
    public func edge(from: UUID, to: UUID) -> DungeonEdge? {
        graph.edges(from: from).first { $0.to == to }.map { DungeonEdge($0) }
    }

    /// IDs of all rooms reachable in one step from `id`.
    public func neighbors(of id: UUID) -> [UUID] {
        graph.neighbors(of: id)
    }

    /// Derives `Doorway` values for a room from its outgoing edges. (Computed on demand)
    public func doorways(for nodeID: UUID) -> [Doorway] {
        guard let desc = graph.node(nodeID) else { return [] }
        return graph.edges(from: nodeID).map { edge in
            let position = wallCenter(
                direction: edge.data.exitDirection,
                bounds:    desc.bounds,
                offset:    edge.data.relativeOffset
            )
            return Doorway(
                position:        position,
                direction:       edge.data.exitDirection
            )
        }
    }

    // MARK: - Private Helpers
    private func wallCenter(direction: Direction, bounds: RoomBounds, offset: Float) -> SIMD2<Float> {
        switch direction {
        case .north:
            let x = bounds.origin.x + (bounds.size.x * offset)
            return SIMD2(x, bounds.max.y)
        case .south:
            let x = bounds.origin.x + (bounds.size.x * offset)
            return SIMD2(x, bounds.origin.y)
        case .east:
            let y = bounds.origin.y + (bounds.size.y * offset)
            return SIMD2(bounds.max.x, y)
        case .west:
            let y = bounds.origin.y + (bounds.size.y * offset)
            return SIMD2(bounds.origin.x, y)
        }
    }
}
