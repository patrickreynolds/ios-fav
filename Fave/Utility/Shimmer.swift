import UIKit

protocol Shimmerable {}

class ShimmerableImageView: UIImageView, Shimmerable {}

extension Shimmerable where Self: UIView {
    func startShimmering() {
        let light = FaveColors.Black100.withAlphaComponent(0.3).cgColor
        let dark = FaveColors.Black100.cgColor

        let gradient = CAGradientLayer()
        gradient.colors = [dark, light, dark]
        gradient.frame = CGRect(x: -bounds.size.width, y: 0, width: 3 * bounds.size.width, height: bounds.size.height)
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
        gradient.locations = [0.4, 0.5, 0.6]
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 2.0
        animation.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        animation.isRemovedOnCompletion = false
        gradient.add(animation, forKey: "shimmer")
    }

    func stopShimmering() {
        layer.mask = nil
    }
}
