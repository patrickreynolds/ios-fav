import UIKit
import Cartography

import FacebookCore
import FacebookLogin

import FBSDKCoreKit
import FBSDKLoginKit

protocol LoggedOutViewControllerDelegate {
    func didSkipAuthentication(viewController: LoggedOutViewController)
    func didSuccessfullyAuthenticate(viewController: LoggedOutViewController)
}

class LoggedOutViewController: FaveVC {

    enum LoginState {
        case loggedOut
        case loggingIn
    }

    var delegate: LoggedOutViewControllerDelegate?

    var loginState: LoginState = .loggedOut {
        didSet {
            if loginState == .loggingIn {
                UIView.animate(withDuration: 0.3, animations: {
                    self.logInWithFacebookButton.alpha = 0
                }) { completed in
                    self.loadingIndicatorView.startAnimating()
                }
            } else {
                loadingIndicatorView.stopAnimating()

                UIView.animate(withDuration: 0.3, animations: {
                    self.logInWithFacebookButton.alpha = 1
                }) { completed in
                    // None
                }
            }
        }
    }

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(frame: .zero)

        indicatorView.hidesWhenStopped = true
        indicatorView.style = .gray

        return indicatorView
    }()

    private lazy var logInWithFacebookButton: UIButton = {
        let button = UIButton(frame: .zero)

        let facebookBlueHexString = "#3A5997"

        button.backgroundColor = UIColor(hexString: facebookBlueHexString)
        button.layer.cornerRadius = 56 / 2
        button.setTitle("Log In With Facebook", for: .normal)
        button.addTarget(self, action: #selector(authenticateWithFacebook), for: .touchUpInside)

        return button
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.backgroundColor = FaveColors.White
        let attributedTitle = NSAttributedString(string: "Dismiss",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.Black50)

        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)

        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .loggedOutScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        let faveLogo = UIImageView(image: UIImage(named: "fave-logo"))

        let title = Label(
            text: "Join The Community!",
            font: FaveFont(style: .h2, weight: .bold),
            textColor: FaveColors.Black90,
            textAlignment: .center,
            numberOfLines: 0)

        let subtitle = Label(
            text: "Finding the best places, products, and people is great, but finding the best ones for you is even better.",
            font: FaveFont(style: .h5, weight: .regular),
            textColor: FaveColors.Black70,
            textAlignment: .center,
            numberOfLines: 0)

        view.addSubview(title)
        view.addSubview(subtitle)
        view.addSubview(logInWithFacebookButton)
        view.addSubview(loadingIndicatorView)
        view.addSubview(faveLogo)
        view.addSubview(skipButton)

        constrain(title, view) { title, view in
            title.top == view.top + (UIScreen.main.bounds.height / 2) - 80
            title.centerX == view.centerX
        }

        constrain(subtitle, title, view) { subtitle, title, view in
            subtitle.top == title.bottom + 24
            subtitle.left == view.left + 24
            subtitle.right == view.right - 24
            subtitle.centerX == view.centerX
        }

        constrain(logInWithFacebookButton, subtitle, view) { button, subtitle, view in
            button.top == subtitle.bottom + 48
            button.centerX == view.centerX
            button.width == (UIScreen.main.bounds.width / 3) * 2
            button.height == 56
        }

        constrain(loadingIndicatorView, logInWithFacebookButton, view) { indicator, button, view in
            indicator.centerX == button.centerX
            indicator.centerY == button.centerY
        }

        constrain(faveLogo, title) { faveLogo, title in
            faveLogo.bottom == title.top - 32
            faveLogo.centerX == title.centerX
            faveLogo.width == 100
            faveLogo.height == 60
        }

        constrain(skipButton, logInWithFacebookButton) { button, facebookButton in
            button.top == facebookButton.bottom + 24
            button.centerX == facebookButton.centerX
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func skipButtonTapped(sender: UIButton!) {
        self.delegate?.didSkipAuthentication(viewController: self)
    }

    @objc func authenticateWithFacebook(sender: UIButton!) {
        print("Authenticate with facebook then dismiss")

        loginState = .loggingIn

        let loginManager = LoginManager()

//        if let currentAccessToken = FBSDKAccessToken.current(), currentAccessToken.appID != FBSDKSettings.appID() {
            loginManager.logOut()
//        }

        // add .userFriends back in eventually
        loginManager.logIn(readPermissions: [ .publicProfile, .email, ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.loginState = .loggedOut

                print("Login failed: \(error)")
            case .cancelled:
                self.loginState = .loggedOut

                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):

                // POST: accessToken.authenticationToken
                self.dependencyGraph.faveService.authenticate(network: "facebook", accessToken: accessToken.authenticationToken, completion: { response, error in
                    // response: { "user": userObject, "token": jwtAuthToken }

                    var jwtAuthToken: String?

                    if let response = response {
                        if let token = response["token"] as? String {
                            print("\n\nToken: \(token)\n\n")
                            jwtAuthToken = token
                        }
                    }

                    if let response = response, let userData = response["user"] as? [String: AnyObject] {
                        if let user = User(data: userData) {
                            self.dependencyGraph.storage.saveUser(user: user)
                        }
                    }

                    if let token = jwtAuthToken {
                        // Login worked

                        print("Token: \(token)")

                        self.dependencyGraph.authenticator.login(jwtToken: token, completion: { completed in
                            if completed {
                                self.delegate?.didSuccessfullyAuthenticate(viewController: self)
                            } else {
                                self.loginState = .loggedOut
                            }
                        })
                    } else {
                        // Login didn't work
                        self.loginState = .loggedOut
                    }

                    self.loginState = .loggedOut

                })
            }
        }
    }
}
