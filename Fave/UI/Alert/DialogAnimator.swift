import UIKit

import Cartography
import pop

/// The dialog animator is a class that adheres to the UIViewControllerTransitioningDelegate and UIViewControllerAnimatedTransitioning
/// protocols. It is designed to be the transitioning delegate of a view controller that wants to be presented using the dialog
/// animation.
///
/// The dialog animator takes the view of the view controller that is being presented and centers it vertically while
/// spacing it a set amount from the left and right edges. The corners of the view are also rounded. When being presented
/// the view is scaled up into view while a dark overlay view is placed behind to prevent interacting with anything
/// except the view. When being dismissed the view is scaled back down.
///
/// Any view controller using the animator should setup their constraints such that the height can be computed and is not
/// ambiguous if the width of the view is constrained.
class DialogAnimator: AlertAnimator {
    // MARK: - Constants

    fileprivate struct Constants {
        static let CornerRadius: CGFloat = 6
        static let CollapsedScalePoint = CGPoint(x: 0.56, y: 0.56)
        static let ExpandedScalePoint = CGPoint(x: 1, y: 1)
    }

    // MARK: - Initializers

    init() {
        super.init(transitionDuration: 0.2)
    }

    // MARK: - AlertAnimator Methods

    override func willTransition(toView: UIView, toViewController: UIViewController, containerView: UIView) {
        toView.layer.cornerRadius = Constants.CornerRadius
        toView.clipsToBounds = true

        constrain(toView, containerView) { toView, containerView in
            toView.centerY == containerView.centerY
            toView.top >= containerView.top
            toView.bottom <= containerView.bottom

            let horizontalMargin: CGFloat = {
                if FaveDeviceSize.isIPhone5sOrLess() {
                    return 8
                }

                return 24
            }()

            toView.left == containerView.left + horizontalMargin
            toView.right == containerView.right - horizontalMargin
        }

        addBounceAnimation(toView, scaleUp: true)

        toView.alpha = 0
    }

    override func animating(toView: UIView, containerView: UIView) {
        toView.alpha = 1
    }

    override func willTransition(fromView: UIView, containerView: UIView) {
        addBounceAnimation(fromView, scaleUp: false)
    }

    override func animating(fromView: UIView, containerView: UIView) {
        fromView.alpha = 0
    }

    // MARK: - Private Methods

    private func addBounceAnimation(_ toView: UIView, scaleUp: Bool) {
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation?.springSpeed = 20

        if scaleUp {
            scaleAnimation?.fromValue = NSValue(cgPoint: Constants.CollapsedScalePoint)
            scaleAnimation?.toValue = NSValue(cgPoint: Constants.ExpandedScalePoint)
        } else {
            scaleAnimation?.fromValue = NSValue(cgPoint: Constants.ExpandedScalePoint)
            scaleAnimation?.toValue = NSValue(cgPoint: Constants.CollapsedScalePoint)
        }

        toView.layer.pop_add(scaleAnimation, forKey: "bounceAnimation")
    }
}
