import UIKit

import Cartography

import FacebookCore
import FacebookLogin

import FBSDKCoreKit
import FBSDKLoginKit

class SplashScreenViewController: FaveVC {

    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?

    enum LoginState {
        case loggedOut
        case loggingIn
        case loggedIn(user: User)
    }

    var authenticationState: LoginState = .loggedOut {
        didSet {
            switch authenticationState {
            case .loggedOut:
                authenticating = false

                return
            case .loggingIn:
                authenticating = true

                return
            case .loggedIn(let user):

                if dependencyGraph.storage.hasSeenOnboarding() || false {

//                    TODO: Uncomment before shipping
//                    dependencyGraph.storage.setHasSeenOnboarding(seen: true)

                    UIView.animate(withDuration: 0.3, delay: 1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                        self.view.alpha = 0
                    }, completion: { (completed) in
                        self.navigationController?.dismiss(animated: false, completion: nil)
                        self.authenticating = false
                    })
                } else {
                    dependencyGraph.faveService.suggestions { response, error in

                        guard let suggestions = response else {
                            self.somethingWentWrong()

                            return
                        }

                        // Sort out suggestions into users
                        // Push on onboarding

                        var uniqueUsers: [Int: User] = [:]

                        suggestions.forEach { list in
                            if let _ = uniqueUsers[list.owner.id] {
                                return
                            } else {
                                uniqueUsers[list.owner.id] = list.owner
                            }
                        }

                        let friends: [User] = uniqueUsers.map { (key, user) in
                            return user
                        }

                        let shuffledFriends = friends.shuffled()

                        let onboardingViewController = OnboardingViewController(dependencyGraph: self.dependencyGraph, user: user, suggestions: shuffledFriends)

                        self.navigationController?.pushViewController(onboardingViewController, animated: true)

                        self.authenticating = false
                    }
                }

                return
            }
        }
    }

    var showWelcomeScreen: Bool = false {
        didSet {
            if showWelcomeScreen {

                self.logInWithFacebookButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.view.bringSubviewToFront(welcomeScrollViewPageControl)

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.2, options: .curveEaseInOut, animations: {
                    self.welcomeScrollView.alpha = 1
                    self.welcomeScrollViewPageControl.alpha = 1
                    self.logInWithFacebookButton.alpha = 1
                    self.logInWithFacebookButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                }) { completed in
                    // Upon completion
                }
            } else {
                // animate out UI
            }
        }
    }

    private var isSplashScreenLoading: Bool = false {
        didSet {
            if isSplashScreenLoading {

                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.2, options: [.curveEaseIn], animations: {
                    self.faveIconImageView.alpha = 1
                }) { (completion) in

                    UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {

                        self.faveIconImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

                    }, completion: nil)

                }

            } else {
                let testing = true

                if dependencyGraph.authenticator.isLoggedIn() && self.dependencyGraph.authenticator.hasJWTToken() && !testing {

                    delay(1.0) {
                        UIView.animate(withDuration: 0.3, delay: 1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                            self.view.backgroundColor = FaveColors.White
                            self.faveIconImageView.alpha = 0
                        }, completion: { (completed) in
                            self.dismiss(animated: false, completion: nil)
                        })
                    }

                } else {

                    delay(1.0) {
                        UIView.animate(withDuration: 0.3, delay: 1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                            self.view.backgroundColor = FaveColors.White
                            self.faveIconImageView.alpha = 0
                        }, completion: { (completed) in
                            self.showWelcomeScreen = true
                        })
                    }

                }
            }
        }
    }

    private var authenticating: Bool = false {
        didSet {
            if authenticating {

                UIView.animate(withDuration: 0.15, animations: {
                    self.logInWithFacebookButton.titleLabel?.alpha = 0
                }) { completion in
                    self.facebookLoadingSpinner.startAnimating()
                }

            } else {
                facebookLoadingSpinner.stopAnimating()

                UIView.animate(withDuration: 0.15) {
                    self.logInWithFacebookButton.titleLabel?.alpha = 1
                }
            }
        }
    }

    private var onboardingPageContent: [OnboardingWelcomePageContentType] = [
        .createList,
        .shareRecommendation,
        .discoverNewPlace
    ]

    private lazy var logInWithFacebookButton: UIButton = {
        let button = UIButton(frame: .zero)

        let facebookBlueHexString = "#3B5998"
        let buttonHeight: CGFloat = 56

        button.backgroundColor = UIColor(hexString: facebookBlueHexString)
        button.layer.cornerRadius = buttonHeight / 2
        button.addTarget(self, action: #selector(authenticateWithFacebook), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Continue with Facebook".uppercased(),
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)

        button.setAttributedTitle(attributedTitle, for: .normal)

        constrain(button) { button in
            button.height == 56
        }

        button.alpha = 0

        return button
    }()

    private lazy var facebookLoadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)

        indicator.style = UIActivityIndicatorView.Style.white
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var faveIconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "icon-fave-faved")
        imageView.contentMode = UIImageView.ContentMode.scaleToFill

        constrain(imageView) { imageView in
            self.heightConstraint = imageView.height == (UIScreen.main.bounds.width * 0.25)
            self.widthConstraint = imageView.width == (UIScreen.main.bounds.width * 0.25)
        }

        return imageView
    }()

    private lazy var welcomeScrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: .zero)

        scrollView.contentSize.width = UIScreen.main.bounds.width * 3
        scrollView.contentSize.height = 100
        scrollView.backgroundColor = FaveColors.White
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.alpha = 0

        return scrollView
    }()

    private lazy var welcomeScrollViewPageControl: UIPageControl = {
        let control = UIPageControl.init(frame: .zero)

        control.currentPageIndicatorTintColor = self.onboardingPageContent[0].color
        control.pageIndicatorTintColor = FaveColors.Black30
        control.numberOfPages = 3
        control.currentPage = 0

        control.alpha = 0

        return control
    }()

    private lazy var welcomeStackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)

        let onboardingPages = onboardingPageContent.map { type in
            return OnboardingWelcomePage(type: type)
        }

        for page in onboardingPages {
            stackView.addArrangedSubview(page)
        }

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .splashScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(faveIconImageView)
        view.addSubview(welcomeScrollView)
        view.addSubview(welcomeScrollViewPageControl)
        view.addSubview(logInWithFacebookButton)

        welcomeScrollView.addSubview(welcomeStackView)

        logInWithFacebookButton.addSubview(facebookLoadingSpinner)

        constrain(welcomeStackView, welcomeScrollView) { stackView, scrollView in
            stackView.top == scrollView.top
            stackView.right == scrollView.right
            stackView.bottom == scrollView.bottom
            stackView.left == scrollView.left

            stackView.height == scrollView.height
        }

        view.backgroundColor = FaveColors.Accent

        constrain(faveIconImageView, view) { imageView, view in
            imageView.centerX == view.centerX
            imageView.centerY == view.centerY
        }

        constrain(welcomeScrollView, welcomeScrollViewPageControl, view) { scrollView, control, view in
            scrollView.top == view.topMargin
            scrollView.right == view.right
            scrollView.left == view.left

            let controlTopMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                controlTopMargin = 16
            } else {
                controlTopMargin = 32
            }

            scrollView.bottom == control.top - controlTopMargin
        }

        constrain(welcomeScrollViewPageControl, logInWithFacebookButton, view) { control, button, view in
            control.centerX == view.centerX

            let controlBottomMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                controlBottomMargin = 16
            } else {
                controlBottomMargin = 32
            }

            control.bottom == button.top - controlBottomMargin
        }

        constrain(logInWithFacebookButton, view) { button, view in
            let buttonBottomMargin: CGFloat
            let buttonHorizontalPadding: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                buttonBottomMargin = 16
                buttonHorizontalPadding = 16
            } else {
                buttonBottomMargin = 64
                buttonHorizontalPadding = 32
            }

            button.left == view.left + buttonHorizontalPadding
            button.right == view.right - buttonHorizontalPadding
            button.bottom == view.bottomMargin - buttonBottomMargin
        }

        constrain(facebookLoadingSpinner, logInWithFacebookButton) { spinner, button in
            spinner.centerX == button.centerX
            spinner.centerY == button.centerY
        }

        // TODO: Also make a call to switchgate here
        dependencyGraph.faveService.getCurrentUser { user, error in

            guard let user = user, self.dependencyGraph.authenticator.hasJWTToken() else {
                self.dependencyGraph.authenticator.logout { success in
                    print("Logged out")
                }

                self.isSplashScreenLoading = false

                return
            }

            self.dependencyGraph.storage.saveUser(user: user)

            if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
                let tabBarItemImage = UIImage(base64String: user.profilePicture)?
                    .resize(targetSize: CGSize(width: 24, height: 24))?
                    .roundedImage?
                    .withRenderingMode(.alwaysOriginal)
                tabBarItem.image = tabBarItemImage
                tabBarItem.selectedImage = tabBarItemImage
            }

            self.isSplashScreenLoading = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isSplashScreenLoading = true
    }

    // MARK - Facebook Authentication
    @objc func authenticateWithFacebook(sender: UIButton!) {

        self.authenticationState = .loggingIn

        let loginManager = LoginManager()
        loginManager.logOut()

        loginManager.logIn(permissions: [Permission.publicProfile, Permission.email, Permission.userFriends], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.somethingWentWrong()

                print("Login failed: \(error)")
            case .cancelled:
                self.somethingWentWrong()

                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):

                // POST: accessToken.authenticationToken
                self.dependencyGraph.faveService.authenticate(network: "facebook", accessToken: accessToken.tokenString, completion: { response, error in

                    guard let authenticationInfo = response else {
                        self.somethingWentWrong()

                        return
                    }

                    self.dependencyGraph.authenticator.login(jwtToken: authenticationInfo.token, completion: { completed in
                        if completed {
                            self.dependencyGraph.storage.saveUser(user: authenticationInfo.user)

                            if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
                                let tabBarItemImage = UIImage(base64String: authenticationInfo.user.profilePicture)?
                                    .resize(targetSize: CGSize(width: 24, height: 24))?
                                    .roundedImage?
                                    .withRenderingMode(.alwaysOriginal)
                                tabBarItem.image = tabBarItemImage
                                tabBarItem.selectedImage = tabBarItemImage
                            }

                            self.didSuccessfullyAuthenticate(user: authenticationInfo.user)
                        } else {
                            self.dependencyGraph.storage.deleteUser()

                            self.somethingWentWrong()
                        }
                    })
                })
            }
        }
    }

    func didSuccessfullyAuthenticate(user: User) {
        self.authenticationState = .loggedIn(user: user)
    }

    func somethingWentWrong() {
        self.authenticationState = .loggedOut

        showToast(title: "Oops! Something went wront. Please try again.")
    }
}

extension SplashScreenViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / view.frame.width))

        self.welcomeScrollViewPageControl.currentPageIndicatorTintColor = self.onboardingPageContent[pageIndex].color

        welcomeScrollViewPageControl.currentPage = pageIndex
    }
}
