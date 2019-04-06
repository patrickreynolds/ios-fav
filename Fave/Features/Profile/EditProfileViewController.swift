import Foundation

import UIKit
import Cartography
import MBProgressHUD

enum AuthenticationState {
    case loggedIn
    case loggedOut
}

class EditProfileViewController: FaveVC {

    var authenticationState: AuthenticationState = .loggedOut {
        didSet {
            if authenticationState == .loggedIn {
                authenticationButton.setTitle("Sign out", for: .normal)
            } else {
                authenticationButton.setTitle("Log in", for: .normal)
            }
        }
    }

    private lazy var authenticationButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.Black90, for: .normal)
        button.backgroundColor = FaveColors.Black20
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.addTarget(self, action: #selector(checkToken), for: .touchUpInside)

        return button
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .editProfileScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))

        view.addSubview(authenticationButton)

        constrain(authenticationButton, view) { button, view in
            button.top == view.topMargin + 64
            button.centerX == view.centerX
        }

        authenticationState = dependencyGraph.authenticator.isLoggedIn() ? .loggedIn : .loggedOut
    }

    @objc func checkToken(sender: UIButton!) {
        if dependencyGraph.authenticator.isLoggedIn() {
            self.dependencyGraph.authenticator.logout { success in
                self.authenticationState = .loggedOut
            }
        } else {
            login()
        }
    }

    override func didSuccessfullyAuthenticate(viewController: LoggedOutViewController) {
        super.didSuccessfullyAuthenticate(viewController: viewController)

        authenticationState = .loggedIn
    }

    @objc func dismissView(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
}
