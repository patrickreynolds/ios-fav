import UIKit

import Cartography

class GetUpdatesOnboardingStepView: UIView {

    let step: OnboardingStepType
    var delegate: OnboardingViewControllerDelegate?

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

    private lazy var getStartedLoadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)

        indicator.style = UIActivityIndicatorView.Style.white
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var getStartedButton: UIButton = {
        let button = UIButton(frame: .zero)

        let buttonHeight: CGFloat = 56

        button.backgroundColor = FaveColors.HJCerulean
        button.layer.cornerRadius = buttonHeight / 2
        button.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Get started".uppercased(),
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)

        button.setAttributedTitle(attributedTitle, for: .normal)

        constrain(button) { button in
            button.height == 56
        }

        button.addSubview(getStartedLoadingSpinner)

        constrain(getStartedLoadingSpinner, button) { spinner, button in
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
        addSubview(getStartedButton)

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

        constrain(getStartedButton, self) { button, view in
            let buttonBottomMargin: CGFloat
            let buttonHorizontalPadding: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                buttonBottomMargin = 16
                buttonHorizontalPadding = 16
            } else if FaveDeviceSize.isIPhone6() {
                buttonBottomMargin = 24
                buttonHorizontalPadding = 24
            } else {
                buttonBottomMargin = 40
                buttonHorizontalPadding = 32
            }

            button.left == view.left + buttonHorizontalPadding
            button.right == view.right - buttonHorizontalPadding
            button.bottom == view.bottomMargin - buttonBottomMargin
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    @objc func getStartedTapped(sender: UIButton!) {
        getStartedButton.performImpact(style: .light)

        UIView.animate(withDuration: 0.15, animations: {
            self.getStartedButton.titleLabel?.alpha = 0
        }) { completion in
            self.getStartedLoadingSpinner.startAnimating()
        }

        delay(0.3) {
            self.delegate?.didAdvanceOnboarding()
        }
    }

    func showPushNotificationsPrompt(dependencyGraph: DependencyGraphType, viewController: FaveVC) {
        if dependencyGraph.authenticator.isLoggedIn() {

            PushNotifications.shouldPromptToRegisterForNotifications(dependencyGraph: dependencyGraph) { shouldPrompt in

                guard shouldPrompt else {
                    return
                }

                PushNotifications.promptForPushNotifications(dependencyGraph: dependencyGraph, fromViewController: viewController) {}
            }
        }
    }
}
