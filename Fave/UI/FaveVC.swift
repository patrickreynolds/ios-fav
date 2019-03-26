import UIKit

class FaveVC: UIViewController {

    let dependencyGraph: DependencyGraphType
    let analyticsImpressionEvent: AnalyticsImpressionEvent

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

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dependencyGraph.analytics.logEvent(dependencyGraph: dependencyGraph, title: analyticsImpressionEvent.rawValue, info: analyticsImpressionEventInfo())
    }

    func analyticsImpressionEventInfo() -> [String: AnyObject]? {
        return nil
    }
}

extension FaveVC: Authenticateable {
    func login() {
        let authenticationViewController = LoggedOutViewController(dependencyGraph: dependencyGraph)
        authenticationViewController.delegate = self

        present(authenticationViewController, animated: true, completion: nil)
    }
}

extension FaveVC: LoggedOutViewControllerDelegate {
    func didSkipAuthentication(viewController: LoggedOutViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func didSuccessfullyAuthenticate(viewController: LoggedOutViewController) {
        viewController.dismiss(animated: false, completion: nil)
    }
}
