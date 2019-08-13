import UIKit

class AlertPresentationController: UIPresentationController {

    // MARK: - Constants

    struct Constants {
        static let DimmingViewAccessibilityIdentifier = "Dimming View"
    }

    private let dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = FaveColors.Black90.withAlphaComponent(0.56)
        view.accessibilityIdentifier = Constants.DimmingViewAccessibilityIdentifier
        view.alpha = 0.0

        return view
    }()

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         canDismissWithDimmingView: Bool) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        if canDismissWithDimmingView {
            _ = dimmingView.tapped { [weak self] _ in
                self?.presentingViewController.dismiss(animated: true)
            }
        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let presentedView = presentedView else {
            return
        }
        let presentedViewFrame = frameOfPresentedViewInContainerView
        presentedView.frame = CGRect(x: presentedView.frame.minX,
                                     y: presentedViewFrame.minY,
                                     width: presentedViewFrame.width,
                                     height: presentedViewFrame.height)
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else {
            return
        }

        containerView.insertSubview(dimmingView, at: 0)
        constrainToSuperview(dimmingView)

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        dimmingView.removeFromSuperview()
    }
}
