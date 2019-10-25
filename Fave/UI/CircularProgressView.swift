import UIKit

import Cartography

class IndeterminateCircularIndicatorView: UIView {
    // MARK: - Constants

    fileprivate struct Constants {
        static let height: CGFloat = 56
        static let duration: CFTimeInterval = 1
        static let rotationAnimationKey = "rotationAnimation"
        static let strokeAnimationKey = "strokeAnimation"
    }

    // MARK: - Properties

    private let circleLayer: CAShapeLayer

    private var isAnimating = false {
        didSet {
            if oldValue != isAnimating {
                if isAnimating {
                    UIView.animate(withDuration: 0.2) {
                        self.alpha = 1
                    }

                    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
                    rotationAnimation.duration = Constants.duration * 4
                    rotationAnimation.fromValue = 0
                    rotationAnimation.toValue = 2 * Double.pi
                    rotationAnimation.repeatCount = Float.infinity
                    rotationAnimation.isRemovedOnCompletion = false
                    circleLayer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)

                    let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                    let strokeStartAnimation1 = CABasicAnimation(keyPath: "strokeStart")
                    strokeStartAnimation1.duration = Constants.duration
                    strokeStartAnimation1.fromValue = 0
                    strokeStartAnimation1.toValue = 0.25
                    strokeStartAnimation1.timingFunction = timingFunction

                    let strokeEndAnimation1 = CABasicAnimation(keyPath: "strokeEnd")
                    strokeEndAnimation1.duration = Constants.duration
                    strokeEndAnimation1.fromValue = 0
                    strokeEndAnimation1.toValue = 1
                    strokeEndAnimation1.timingFunction = timingFunction

                    let strokeStartAnimation2 = CABasicAnimation(keyPath: "strokeStart")
                    strokeStartAnimation2.beginTime = Constants.duration
                    strokeStartAnimation2.duration = Constants.duration / 2
                    strokeStartAnimation2.fromValue = 0.25
                    strokeStartAnimation2.toValue = 1
                    strokeStartAnimation2.timingFunction = timingFunction

                    let strokeEndAnimation2 = CABasicAnimation(keyPath: "strokeEnd")
                    strokeEndAnimation2.beginTime = Constants.duration
                    strokeEndAnimation2.duration = Constants.duration / 2
                    strokeEndAnimation2.fromValue = 1
                    strokeEndAnimation2.toValue = 1
                    strokeEndAnimation2.timingFunction = timingFunction

                    let strokeAnimationGroup = CAAnimationGroup()
                    strokeAnimationGroup.duration = Constants.duration * 1.5
                    strokeAnimationGroup.animations = [strokeStartAnimation1, strokeEndAnimation1, strokeStartAnimation2, strokeEndAnimation2]
                    strokeAnimationGroup.repeatCount = Float.infinity
                    strokeAnimationGroup.isRemovedOnCompletion = false
                    circleLayer.add(strokeAnimationGroup, forKey: Constants.strokeAnimationKey)
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.alpha = 0
                    }

//                    circleLayer.removeAnimation(forKey: Constants.rotationAnimationKey)
//                    circleLayer.removeAnimation(forKey: Constants.strokeAnimationKey)
                }
            }
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        circleLayer = CAShapeLayer()

        super.init(frame: frame)

        circleLayer.strokeColor = FaveColors.Accent.cgColor
        circleLayer.fillColor = nil
        circleLayer.lineWidth = 2
        self.layer.addSublayer(circleLayer)

        isUserInteractionEnabled = false

        alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func startAnimating() {
        isAnimating = true
    }

    func stopAnimating() {
        isAnimating = false
    }

    // MARK: - UIView Methods

    override func layoutSubviews() {
        circleLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width / 2, bounds.height / 2) - (circleLayer.lineWidth / 2)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: (2 * CGFloat.pi), clockwise: true)
        circleLayer.path = path.cgPath
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constants.height, height: Constants.height)
    }
}

