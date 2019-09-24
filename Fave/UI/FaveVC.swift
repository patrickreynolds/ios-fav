import UIKit
import Cartography

class FaveVC: UIViewController {

    let dependencyGraph: DependencyGraphType
    let analyticsImpressionEvent: AnalyticsImpressionEvent

    var toastViewShownConstraint: NSLayoutConstraint?
    var toastViewHiddenConstraint: NSLayoutConstraint?

    private lazy var toastView: ToastView = {
        let toastView = ToastView()

        return toastView
    }()

    init(dependencyGraph: DependencyGraphType, analyticsImpressionEvent: AnalyticsImpressionEvent) {
        self.dependencyGraph = dependencyGraph
        self.analyticsImpressionEvent = analyticsImpressionEvent

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(toastView)

        constrain(toastView, view) { toastView, view in
            toastViewShownConstraint = toastView.top == view.topMargin
            toastViewHiddenConstraint = toastView.bottom == view.topMargin

            toastView.left == view.left
            toastView.right == view.right
        }

        toastView.alpha = 0
        toastViewShownConstraint?.isActive = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dependencyGraph.analytics.logEvent(dependencyGraph: dependencyGraph, title: analyticsImpressionEvent.rawValue, info: analyticsImpressionEventInfo())
    }

    func analyticsImpressionEventInfo() -> [String: AnyObject]? {
        return nil
    }

    func showToast(title: String) {
        view.bringSubviewToFront(toastView)

        toastView.title = title
        toastView.setNeedsLayout()
        toastView.layoutIfNeeded()

        toastViewShownConstraint?.isActive = true
        toastViewHiddenConstraint?.isActive = false
        toastView.alpha = 1

        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { completed in
            self.toastViewShownConstraint?.isActive = false
            self.toastViewHiddenConstraint?.isActive = true

            UIView.animate(withDuration: 0.3, delay: 2.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.toastView.alpha = 0
            })
        }
    }
}

extension FaveVC: Authenticateable {
    func login() {

        let splashScreenViewController = SplashScreenViewController(dependencyGraph: dependencyGraph)
        let spashScreenNavigationController = UINavigationController(rootViewController: splashScreenViewController)
        splashScreenViewController.navigationController?.navigationBar.isHidden = true

        splashScreenViewController.modalPresentationStyle = .overFullScreen
        spashScreenNavigationController.modalPresentationStyle = .overFullScreen

        UIApplication.shared.appDelegate.tabBarController.present(spashScreenNavigationController, animated: false, completion: nil)
    }
}

extension FaveVC: LoggedOutViewControllerDelegate {
    func didSkipAuthentication(viewController: LoggedOutViewController) {
        viewController.dismiss(animated: true, completion: {

            let tabBC: UITabBarController? = self.presentingViewController as? UITabBarController ?? nil

            if let tabBarController = tabBC {
                tabBarController.selectedIndex = 0
            }

            if let _ = self.presentingViewController as? ProfileViewController {
                if let tabBarController = tabBC {
                    tabBarController.selectedIndex = 3
                }
            }
        })
    }

    @objc func didSuccessfullyAuthenticate(viewController: LoggedOutViewController) {
        viewController.dismiss(animated: false, completion: nil)
    }
}
