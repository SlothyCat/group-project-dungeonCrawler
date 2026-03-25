import Foundation
import simd

/// Defines the physical structure of a single room.
public protocol RoomConstructor {
    /// Constructs the physical room.
    /// - Parameters:
    ///   - builder: The builder for placing physical objects into the `World`.
    ///   - specification: Geometric description and rules for the room.
    ///   - doorways: Openings the constructor must leave in its perimeter.
    ///   - generator: The deterministic RNG for procedural choices.
    func construct(
        builder: RoomBuilder,
        specification: RoomSpecification,
        doorways: [Doorway],
        using generator: inout SeededGenerator
    )
}
