import Foundation
import simd

/// Constructs an axis-aligned room using a `RoomBuilder`.
///
/// Walls are built around the perimeter and split for `doorways`.
/// Obstacles are scattered purely via procedural logic.
public final class BoxRoomConstructor: RoomConstructor {

    public struct Config {
        /// Inset from walls where obstacles cannot spawn.
        public var wallMargin: Float = 48
        /// Clear radius at center for start/player positioning.
        public var centerClearRadius: Float = 100
        /// Density coefficient for obstacles.
        public var obstacleDensity: Float = 0.12
        /// Whether to create visual sprites (Floor/Wall) in addition to colliders.
        public var renderVisualSprites: Bool = true

        public init() {}
    }

    private let config: Config

    public init(config: Config = Config()) {
        self.config = config
    }

    public func construct(
        builder: RoomBuilder,
        specification: RoomSpecification,
        doorways: [Doorway],
        using generator: inout SeededGenerator
    ) {
        let bounds = specification.bounds
        
        // If config explicitly disables visuals, override the builder setting.
        if !config.renderVisualSprites {
            builder.renderVisualSprites = false
        }

        builder.addFloor()
        createPerimeterWalls(bounds: bounds, doorways: doorways, builder: builder)
        // createObstacles(bounds: bounds, builder: builder, using: &generator)
    }

    // MARK: - Perimeter Walls

    private func createPerimeterWalls(
        bounds: RoomBounds,
        doorways: [Doorway],
        builder: RoomBuilder
    ) {
        let t = WorldConstants.wallThickness

        createWall(
            at: bounds.minY + t / 2,
            from: bounds.minX + t, to: bounds.maxX - t,
            axis: .horizontal,
            openings: doorways.filter { $0.direction == .south },
            builder: builder
        )
        createWall(
            at: bounds.maxY - t / 2 - WorldConstants.topWallCollisionInset,
            from: bounds.minX + t, to: bounds.maxX - t,
            axis: .horizontal,
            openings: doorways.filter { $0.direction == .north },
            builder: builder
        )
        createWall(
            at: bounds.minX + t / 2,
            from: bounds.minY, to: bounds.maxY,
            axis: .vertical,
            openings: doorways.filter { $0.direction == .west },
            builder: builder
        )
        createWall(
            at: bounds.maxX - t / 2,
            from: bounds.minY, to: bounds.maxY,
            axis: .vertical,
            openings: doorways.filter { $0.direction == .east },
            builder: builder
        )
    }

    private func createWall(
        at fixedCoord: Float,
        from rangeStart: Float,
        to rangeEnd: Float,
        axis: CorridorAxis,
        openings: [Doorway],
        builder: RoomBuilder
    ) {
        let t = WorldConstants.wallThickness

        let gapCoord:    (Doorway) -> Float       = axis == .horizontal ? { $0.position.x }              : { $0.position.y }
        let makePosition: (Float)  -> SIMD2<Float> = axis == .horizontal ? { SIMD2($0, fixedCoord) }       : { SIMD2(fixedCoord, $0) }
        let makeSize:     (Float)  -> SIMD2<Float> = axis == .horizontal ? { SIMD2($0, t) }                : { SIMD2(t, $0) }

        if openings.isEmpty {
            let span = rangeEnd - rangeStart
            builder.addWall(at: makePosition(rangeStart + span / 2), size: makeSize(span))
            return
        }

        let sorted = openings.sorted { gapCoord($0) < gapCoord($1) }
        var cursor = rangeStart

        for opening in sorted {
            let gapFrom = gapCoord(opening) - opening.width / 2
            let gapTo   = gapCoord(opening) + opening.width / 2
            if gapFrom > cursor {
                let span = gapFrom - cursor
                builder.addWall(at: makePosition(cursor + span / 2), size: makeSize(span))
            }
            cursor = gapTo
        }
        if cursor < rangeEnd {
            let span = rangeEnd - cursor
            builder.addWall(at: makePosition(cursor + span / 2), size: makeSize(span))
        }
    }

    // MARK: - Obstacles

    private func createObstacles(bounds: RoomBounds, builder: RoomBuilder, using generator: inout SeededGenerator) {
        let margin = config.wallMargin
        let safeArea = bounds.inset(by: margin)

        guard safeArea.size.x > 0, safeArea.size.y > 0 else { return }

        let area = safeArea.size.x * safeArea.size.y
        let maxObstacles = Int(area / 5_000 * config.obstacleDensity)
        var placed = 0
        var attempts = 0

        while placed < maxObstacles && attempts < maxObstacles * 10 {
            attempts += 1
            let pos = safeArea.randomPosition(margin: 0, using: &generator)
            if simd_distance(pos, bounds.center) < config.centerClearRadius { continue }

            let size = SIMD2<Float>(
                Float.random(in: 24...48, using: &generator),
                Float.random(in: 24...48, using: &generator)
            )
            builder.addObstacle(at: pos, size: size)
            placed += 1
        }
    }
}
