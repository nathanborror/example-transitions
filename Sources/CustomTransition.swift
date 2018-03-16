import UIKit

struct CustomTransition {

    enum Axis {
        case horizontal
        case vertical
    }

    struct Options {
        var frame: CGRect
        var transform: CGAffineTransform
        var duration: TimeInterval
        var dampingRatio: CGFloat
        var axis: Axis
    }
}
