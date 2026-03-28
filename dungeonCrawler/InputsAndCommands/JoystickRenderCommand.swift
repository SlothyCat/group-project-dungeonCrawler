import Foundation
import CoreGraphics

struct JoystickRenderCommand: Command {
    var id: CommandId
    var leftBase: CGPoint?
    var leftHandle: CGPoint?
    var rightBase: CGPoint?
    var rightHandle: CGPoint?
}
