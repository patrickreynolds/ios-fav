import UIKit

import Cartography

/// The action sheet animator is a class that adheres to the UIViewControllerTransitioningDelegate and
/// UIViewControllerAnimatedTransitioning protocols. It is designed to be the transitioning delegate of a view controller
/// that wants to be presented using the action sheet animation.
///
/// The action sheet animator takes the view of the view controller that is being presented and scrolls it in from the
/// bottom of the container view. It is also pinned to the left and right side of the containing view.
///
/// Any view controller using the animator should setup their constraints such that the height can be computed and is not
/// ambiguous if the width of the view is constrained.
class ActionSheetAnimator: AlertAnimator {
    // MARK: - Properties

    fileprivate var hiddenConstraint: NSLayoutConstraint?
    fileprivate var visibleConstraint: NSLayoutConstraint?
    fileprivate weak var toViewController: UIViewController?
    private let fullScreen: Bool

    // MARK: - Initializers

    init(fullScreen: Bool = false) {
        self.fullScreen = fullScreen
        let duration = fullScreen ? 0.5 : 0.3
        super.init(transitionDuration: duration)
    }

    // MARK: - AlertAnimator Methods

    override func willTransition(toView: UIView, toViewController: UIViewController, containerView: UIView) {

        self.toViewController = toViewController

        constrain(toView, containerView) { toView, containerView in
            hiddenConstraint = (toView.top == containerView.bottom)
            toView.left == containerView.left
            toView.right == containerView.right
        }

        if fullScreen {
            constrain(toView, containerView) { toView, containerView in
                toView.height == containerView.height - UIApplication.shared.statusBarFrame.height
            }
        }

        containerView.layoutIfNeeded()

        hiddenConstraint?.isActive = false

        let bottomConstraintBuffer: CGFloat = 0

        constrain(toView, containerView) { toView, containerView in
            visibleConstraint = (toView.bottom == containerView.bottom + bottomConstraintBuffer)
        }

        let maskPath = UIBezierPath(roundedRect: toView.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 8.0, height: 8.0))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = toView.bounds
        maskLayer.path = maskPath.cgPath

        toView.layer.mask = maskLayer

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissActionSheet))
        swipeGestureRecognizer.direction = .down
        toView.addGestureRecognizer(swipeGestureRecognizer)
    }

    override func animating(toView: UIView, containerView: UIView) {
        containerView.layoutIfNeeded()
    }

    override func willTransition(fromView: UIView, containerView: UIView) {
        visibleConstraint?.isActive = false
        hiddenConstraint?.isActive = true
    }

    override func animating(fromView: UIView, containerView: UIView) {
        containerView.layoutIfNeeded()
    }

    override func canDismissWithDimmingView() -> Bool {
        return true
    }

    @objc func dismissActionSheet() {
        toViewController?.dismiss(animated: true, completion: nil)
    }
}
