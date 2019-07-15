import UIKit
import Cartography
import MBProgressHUD

protocol EditProfileViewControllerDelegate {
    func didLogout()
}

enum AuthenticationState {
    case loggedIn
    case loggedOut
}

class EditProfileViewController: FaveVC {

    var user: User

    var delegate: EditProfileViewControllerDelegate?

    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)

        view.addSubview(profileInfoStackView)
        view.addSubview(savingUserInfoActivityIndicator)

        constrain(view) { contentView in
            contentView.width == UIScreen.main.bounds.width
        }

        constrainToSuperview(profileInfoStackView, exceptEdges: [.bottom])

        constrain(profileInfoStackView, view) { profileInfoStackView, view in
            profileInfoStackView.bottom == view.bottom - 40
        }

        constrain(savingUserInfoActivityIndicator, view) { savingUserInfoActivityIndicator, view in
            savingUserInfoActivityIndicator.centerY == view.centerY
            savingUserInfoActivityIndicator.centerX == view.centerX
        }

        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)

        scrollView.addSubview(contentView)

        constrainToSuperview(contentView)

        return scrollView
    }()

    private lazy var profileInfoStackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)

        stackView.addArrangedSubview(profilePictureContentView)
        stackView.addArrangedSubview(userInfoContentView)
        stackView.addArrangedSubview(privateUserInfoContentView)
        stackView.addArrangedSubview(moreInfoContentView)

        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.setCustomSpacing(40, after: userInfoContentView)
        stackView.setCustomSpacing(40, after: privateUserInfoContentView)
        stackView.setCustomSpacing(40, after: moreInfoContentView)

        return stackView
    }()

    private lazy var profilePictureContentView: UIView = {
        let view = UIView(frame: .zero)

        let imageSize: CGFloat = 72

        let imageView = UIImageView.init(frame: .zero)
        imageView.image = UIImage.init(base64String: user.profilePicture)
        imageView.layer.borderColor = FaveColors.Black30.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.cornerRadius = imageSize / 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true

        let actionLabel = Label(text: "Change Profile Photo",
                                 font: FaveFont(style: .h5, weight: .semiBold),
                                 textColor: FaveColors.Accent,
                                 textAlignment: .left,
                                 numberOfLines: 1)

        let disclaimerLabel = Label(text: "Coming soon!",
                                font: FaveFont(style: .xsmall, weight: .regular),
                                textColor: FaveColors.Black60,
                                textAlignment: .left,
                                numberOfLines: 1)

        view.addSubview(imageView)
        view.addSubview(actionLabel)
        view.addSubview(disclaimerLabel)

        constrain(imageView, actionLabel, disclaimerLabel, view) { imageView, actionLabel, disclaimerLabel, view in
            imageView.top == view.top + 12
            imageView.width == imageSize
            imageView.height == imageSize

            imageView.centerX == view.centerX

            actionLabel.centerX == view.centerX
            actionLabel.top == imageView.bottom + 12

            disclaimerLabel.centerX == view.centerX
            disclaimerLabel.top == actionLabel.bottom + 2
            disclaimerLabel.bottom == view.bottom - 12
        }

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    private lazy var firstNameProfileInputView: ProfileInputView = {
        let profileInputView = ProfileInputView(title: "First name", placeholder: "First name", value: user.firstName, autocapitalizationType: .words)

        profileInputView.delegate = self

        return profileInputView
    }()

    private lazy var lastNameProfileInputView: ProfileInputView = {
        let profileInputView = ProfileInputView(title: "Last name", placeholder: "Last name", value: user.lastName, autocapitalizationType: .words)

        profileInputView.delegate = self

        return profileInputView
    }()

    private lazy var usernameProfileInputView: ProfileInputView = {
        let profileInputView = ProfileInputView(title: "Username", placeholder: "Username", value: user.handle, contentType: .username, autocapitalizationType: .none)

        profileInputView.delegate = self

        return profileInputView
    }()

    private lazy var bioProfileInputView: ProfileInputView = {
        let profileInputView = ProfileInputView(title: "Bio", placeholder: "Bio", value: "", autocapitalizationType: .sentences)

        profileInputView.delegate = self

        return profileInputView
    }()

    private lazy var userInfoContentView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.addArrangedSubview(firstNameProfileInputView)
        stackView.addArrangedSubview(lastNameProfileInputView)
        stackView.addArrangedSubview(usernameProfileInputView)
        stackView.addArrangedSubview(bioProfileInputView)

        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical

        return stackView
    }()

    private lazy var privateInformationTitleView: ProfileInputTitleView = {
        let inputTitleView = ProfileInputTitleView.init(title: "Private Information")

        return inputTitleView
    }()

    private lazy var emailProfileInputView: ProfileInputView = {
        let profileInputView = ProfileInputView(title: "Email", placeholder: "Email", value: user.email, contentType: .emailAddress, autocapitalizationType: .none)

        profileInputView.delegate = self

        return profileInputView
    }()

    private lazy var privateUserInfoContentView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.addArrangedSubview(privateInformationTitleView)
        stackView.addArrangedSubview(emailProfileInputView)

        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical

        return stackView
    }()

    private lazy var moreInformationTitleView: ProfileInputTitleView = {
        let inputTitleView = ProfileInputTitleView.init(title: "More Information")

        return inputTitleView
    }()

    private lazy var submitFeedbackProfileActionView: ProfileActionView = {
        let actionView = ProfileActionView.init(title: "Submit feedback", color: FaveColors.Accent, action: {
            self.didTapFeedback()
        })

        return actionView
    }()

    private lazy var logoutProfileActionView: ProfileActionView = {
        let title = authenticationState == .loggedIn ? "Log out" : "Sign in"
        let color = authenticationState == .loggedIn ? UIColor.red : FaveColors.Accent

        let actionView = ProfileActionView.init(title: title, color: color, action: {
            self.didTapAuthentication()
        })

        return actionView
    }()

    private lazy var moreInfoContentView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical

        stackView.addArrangedSubview(moreInformationTitleView)
        stackView.addArrangedSubview(submitFeedbackProfileActionView)
        stackView.addArrangedSubview(logoutProfileActionView)

        return stackView
    }()

    private lazy var savingUserInfoActivityIndicator: MBProgressHUD = {
        let hud = MBProgressHUD(frame: .zero)

        hud.animationType = .fade
        hud.contentColor = FaveColors.Black50

        return hud
    }()

    var authenticationState: AuthenticationState = .loggedOut {
        didSet {
            if authenticationState == .loggedIn {
                logoutProfileActionView.title = "Log out"
            } else {
                logoutProfileActionView.title = "Sign in"
            }
        }
    }

    init(dependencyGraph: DependencyGraphType, user: User) {
        self.user = user

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .editProfileScreenShown)

        authenticationState = dependencyGraph.authenticator.isLoggedIn() ? .loggedIn : .loggedOut
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        view.backgroundColor = FaveColors.White

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveInformation))

        let titleViewLabel = Label.init(text: "Edit Profile", font: FaveFont.init(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.addSubview(scrollView)

        constrainToSuperview(scrollView, exceptEdges: [.bottom])

        constrain(scrollView, view) { scrollView, view in
            scrollView.bottom == view.bottomMargin
        }
    }

    override func didSuccessfullyAuthenticate(viewController: LoggedOutViewController) {
        super.didSuccessfullyAuthenticate(viewController: viewController)

        authenticationState = .loggedIn
    }

    @objc func dismissView(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveInformation(sender: UIButton!) {
        // save all of the info
        // dismiss upon complete

        let firstName = firstNameProfileInputView.value
        let lastName = lastNameProfileInputView.value
        let handle = usernameProfileInputView.value
        let bio = bioProfileInputView.value
        let email = emailProfileInputView.value

        savingUserInfoActivityIndicator.show(animated: true)
        dependencyGraph.faveService.updateUser(firstName: firstName, lastName: lastName, email: email, handle: handle, bio: bio) { user, error in
            self.savingUserInfoActivityIndicator.hide(animated: true)

            guard let user = user else {
                let alertController = UIAlertController(title: "Oops!", message: "Something went wrong with saving your updates. Feel free to give it another try, otherwise try in a bit – we might have our 💩 together by then.", preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
                    switch action.style {
                    case .default, .cancel, .destructive:

                        alertController.dismiss(animated: true, completion: nil)

                    }}))

                self.present(alertController, animated: true, completion: nil)

                return
            }

            self.dependencyGraph.storage.saveUser(user: user)

            self.dismiss(animated: true, completion: nil)
        }
    }

    func didTapFeedback() {
        let alertController = UIAlertController(title: "Submit Feedback", message: "Let us know if there's anything you like, want us to add, or just want to say hi 😊", preferredStyle: .alert)

        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Let us know what you think..."
        })

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:
                alertController.dismiss(animated: true, completion: nil)
            }}
        ))

        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:

                if let feedback = alertController.textFields?.first?.text {
                    print("\n\nFeedback: \(feedback)\n\n")

                    // TODO: Post feedback
                    let submitFeedbackIsEnabled = false

                    if submitFeedbackIsEnabled {
                        self.dependencyGraph.faveService.submitFeedback(feedback: feedback) { success, error in
                            if let success = success {
                                print("\nFeedback success: \(success)\n")
                            }
                        }
                    }
                }

                alertController.dismiss(animated: true, completion: nil)
            }}
        ))

        self.present(alertController, animated: true, completion: nil)
    }

    func didTapAuthentication() {
        let tabBC: UITabBarController? = self.presentingViewController as? UITabBarController ?? nil

        if dependencyGraph.authenticator.isLoggedIn() {
            self.dependencyGraph.authenticator.logout { success in
                if success {
                    self.authenticationState = .loggedOut

                    if let tabBarController = tabBC {
                        tabBarController.selectedIndex = 0
                    }

                    self.delegate?.didLogout()

                    self.dismiss(animated: true) {}
                }
            }
        } else {
            login()
        }
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        return false
    }
}
