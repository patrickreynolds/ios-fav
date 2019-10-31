import UIKit

import Cartography

class GetUpdatesOnboardingStepView: UIView {

    let step: OnboardingStepType
    var delegate: OnboardingViewControllerDelegate?

    var dependencyGraph: DependencyGraphType? = nil
    var viewController: FaveVC? = nil

    private lazy var titleLabel: Label = {
        let label = Label(
            text: step.title,
            font: FaveFont(style: .h4, weight: .bold),
            textColor: FaveColors.Black100,
            textAlignment: .left,
            numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(
            text: step.subtitle,
            font: FaveFont(style: .h5, weight: .regular),
            textColor: FaveColors.Black100,
            textAlignment: .left,
            numberOfLines: 0)

        return label
    }()

    private lazy var skipButtonLoadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)

        indicator.style = UIActivityIndicatorView.Style.white
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var registerNotificationsLoadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)

        indicator.style = UIActivityIndicatorView.Style.white
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton(frame: .zero)

        let buttonHeight: CGFloat = 56

        button.backgroundColor = FaveColors.White
        button.layer.cornerRadius = buttonHeight / 2
        button.layer.borderColor = FaveColors.HJCerulean.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(skipNotificationsTapped), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Skip".uppercased(),
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.HJCerulean)

        button.setAttributedTitle(attributedTitle, for: .normal)

        constrain(button) { button in
            button.height == 56
        }

        button.addSubview(skipButtonLoadingSpinner)

        constrain(skipButtonLoadingSpinner, button) { spinner, button in
            spinner.centerX == button.centerX
            spinner.centerY == button.centerY
        }

        return button
    }()

    private lazy var registerNotificationsButton: UIButton = {
        let button = UIButton(frame: .zero)

        let buttonHeight: CGFloat = 56

        button.backgroundColor = FaveColors.HJCerulean
        button.layer.cornerRadius = buttonHeight / 2
        button.addTarget(self, action: #selector(registerNotificationsTapped), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Get updates".uppercased(),
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)

        button.setAttributedTitle(attributedTitle, for: .normal)

        constrain(button) { button in
            button.height == 56
        }

        button.addSubview(registerNotificationsLoadingSpinner)

        constrain(registerNotificationsLoadingSpinner, button) { spinner, button in
            spinner.centerX == button.centerX
            spinner.centerY == button.centerY
        }

        return button
    }()

    private lazy var notificationsIllustrationImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        imageView.image = UIImage.init(named: "illustration-onboarding-notifications")
        imageView.backgroundColor = FaveColors.White
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFit

        return imageView
    }()


    // MARK: - Initializers

    init(step: OnboardingStepType) {
        self.step = step

        super.init(frame: .zero)

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(notificationsIllustrationImageView)
        addSubview(skipButton)
        addSubview(registerNotificationsButton)

        constrain(self) { view in
            view.width == UIScreen.main.bounds.width
        }

        constrain(titleLabel, self) { label, view in
            label.top == view.top + 24
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(subtitleLabel, titleLabel, self) { subtitleLabel, titleLabel, view in
            subtitleLabel.top == titleLabel.bottom + 8
            subtitleLabel.right == view.right - 16
            subtitleLabel.left == view.left + 16
        }

        constrain(notificationsIllustrationImageView, subtitleLabel, self) { imageView, label, view in
            imageView.top == label.bottom + 16
            imageView.right == view.right
            imageView.left == view.left
        }

        constrain(skipButton, registerNotificationsButton, self) { skipButton, registerNotificationsButton, view in
            let buttonBottomMargin: CGFloat
            let buttonHorizontalPadding: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                buttonBottomMargin = 16
                buttonHorizontalPadding = 16
            } else if FaveDeviceSize.isIPhone6() {
                buttonBottomMargin = 24
                buttonHorizontalPadding = 16
            } else {
                buttonBottomMargin = 40
                buttonHorizontalPadding = 16
            }

            skipButton.left == view.left + buttonHorizontalPadding
            skipButton.right == registerNotificationsButton.left - buttonHorizontalPadding
            skipButton.bottom == view.bottomMargin - buttonBottomMargin

            registerNotificationsButton.right == view.right - buttonHorizontalPadding
            registerNotificationsButton.bottom == view.bottomMargin - buttonBottomMargin

            registerNotificationsButton.width == skipButton.width
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    @objc func skipNotificationsTapped(sender: UIButton!) {
        skipButton.performImpact(style: .light)

        UIView.animate(withDuration: 0.15, animations: {
            self.skipButton.titleLabel?.alpha = 0
        }) { completion in
            self.skipButtonLoadingSpinner.startAnimating()
        }

        delay(0) {
            self.delegate?.didAdvanceOnboarding()
        }
    }

    @objc func registerNotificationsTapped(sender: UIButton!) {
        registerNotificationsButton.performImpact(style: .light)

        UIView.animate(withDuration: 0.15, animations: {
            self.registerNotificationsButton.titleLabel?.alpha = 0
        }) { completion in
            self.registerNotificationsLoadingSpinner.startAnimating()
        }

        guard let dependencyGraph = self.dependencyGraph, let viewController = self.viewController else {
            return
        }

        if dependencyGraph.authenticator.isLoggedIn() {

            PushNotifications.shouldPromptToRegisterForNotifications(dependencyGraph: dependencyGraph) { shouldPrompt in

                guard shouldPrompt else {
                    return
                }

                PushNotifications.promptForPushNotifications(dependencyGraph: dependencyGraph, fromViewController: viewController) {
                    self.delegate?.didAdvanceOnboarding()
                }
            }
        }
    }

    func preparePushNotificationsPrompt(dependencyGraph: DependencyGraphType, viewController: FaveVC) {
        self.dependencyGraph = dependencyGraph
        self.viewController = viewController
    }
}
