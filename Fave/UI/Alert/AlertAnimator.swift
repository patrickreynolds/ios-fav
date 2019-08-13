import UIKit

import Cartography

class AlertAnimator: NSObject {

    // MARK: - Properties

    fileprivate var isPresenting: Bool
    fileprivate let transitionDuration: TimeInterval

    // MARK: - Initializers

    init(transitionDuration: TimeInterval) {
        self.isPresenting = false
        self.transitionDuration = transitionDuration

        super.init()
    }

    // MARK: - Abstract Methods

    func willTransition(toView: UIView, toViewController: UIViewController, containerView: UIView) {
    }

    func animating(toView: UIView, containerView: UIView) {
    }

    func willTransition(fromView: UIView, containerView: UIView) {
    }

    func animating(fromView: UIView, containerView: UIView) {
    }

    // Override and return true if you want to enable presenting view controller's dismissal from tapping on background dimming view.
    func canDismissWithDimmingView() -> Bool {
        return false
    }
}

// MARK: - UIViewControllerTransitioningDelegate Extension

extension AlertAnimator: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AlertPresentationController(presentedViewController: presented,
                                           presenting: presenting,
                                           canDismissWithDimmingView: canDismissWithDimmingView())
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true

        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false

        return self
    }
}

// MARK: - UIViewControllerAnimatedTransitioning Extension

extension AlertAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                fatalError("No to view for \(#file).")
            }

            guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                fatalError("No to view controller for \(#file).")
            }

            let containerView = transitionContext.containerView

            containerView.addSubview(toView)

            willTransition(toView: toView, toViewController: toViewController, containerView: containerView)

            UIView.animate(withDuration: transitionDuration,
                           delay: 0.0,
                           usingSpringWithDamping: 0.70,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseOut,
                           animations: {
                            self.animating(toView: toView, containerView: containerView)
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
                fatalError("No from view for \(#file).")
            }

            let containerView = transitionContext.containerView

            willTransition(fromView: fromView, containerView: containerView)

            UIView.animate(withDuration: transitionDuration / 2,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: {
                            self.animating(fromView: fromView, containerView: containerView)
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
}
