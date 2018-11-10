import UIKit

extension CALayer {
    func roundCorners(radius: CGFloat) {
        cornerRadius = radius
        masksToBounds = true
    }
}
