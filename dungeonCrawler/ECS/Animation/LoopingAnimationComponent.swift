import Foundation

/// Cycles through a list of texture frames indefinitely.
/// Used for idle animated entities like the soul collectible.
public final class LoopingAnimationComponent: Component {
    public let frameNames: [String]
    public let frameDuration: Double
    public var frameIndex: Int = 0
    public var elapsed: Double = 0

    public init(frameNames: [String], frameDuration: Double) {
        self.frameNames    = frameNames
        self.frameDuration = frameDuration
    }
}
