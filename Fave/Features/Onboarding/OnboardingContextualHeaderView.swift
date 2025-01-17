import UIKit

import Cartography

protocol OnboardingContextualHeaderViewDelegate {
    func didTapSkipButton()
}

class OnboardingContextualHeaderView: UIView {

    // MARK: - Properties

    let steps: [OnboardingStepType]
    var delegate: OnboardingContextualHeaderViewDelegate?

    // MARK: - UI Properties

    private lazy var progressView: LinearProgressView = {
        let progressView = LinearProgressView()

        progressView.trackColor = FaveColors.Black20
        progressView.progressColor = FaveColors.HJCerulean

        return progressView
    }()

    private lazy var titleLabel: Label = {
        let label = Label(
            text: steps.first?.headerTitle ?? "",
            font: FaveFont(style: .small, weight: .semiBold),
            textColor: FaveColors.Black90,
            textAlignment: .left,
            numberOfLines: 1)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(
            text: steps.first?.headerSubtitle ?? "",
            font: FaveFont(style: .small, weight: .regular),
            textColor: FaveColors.Black90,
            textAlignment: .left,
            numberOfLines: 1)

        return label
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton.init(frame: .zero)

        button.backgroundColor = FaveColors.White
        button.addTarget(self, action: #selector(skipOnboardingTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .right

        let attributedTitle = NSAttributedString(string: "Skip",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Black60)

        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()


    // MARK: - Initializers

    init(steps: [OnboardingStepType]) {
        self.steps = steps

        super.init(frame: .zero)

        addSubview(progressView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(skipButton)

        constrain(progressView, self) { progressView, view in
            progressView.top == view.top + 8
            progressView.right == view.right - 16
            progressView.left == view.left + 16
        }

        constrain(titleLabel, progressView, self) { titleLabel, progressView, view in
            titleLabel.top == progressView.bottom + 8
            titleLabel.right == view.right - 16
            titleLabel.left == view.left + 16
        }

        constrain(subtitleLabel, titleLabel, self) { subtitleLabel, titleLabel, view in
            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.right == view.right - 16
            subtitleLabel.left == view.left + 16
            subtitleLabel.bottom == view.bottom - 8
        }

        constrain(skipButton, progressView, self) { button, progressView, view in
            button.top == progressView.bottom + 8
            button.right == view.right - 16
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func advanceToStep(step: OnboardingStepType, withLabelAnimation labelAnimation: Bool = true) {
        // set progress
        // set title

        var stepIndex: Double = 0

        for (index, stepInSteps) in steps.enumerated() {
            if step == stepInSteps {
                stepIndex = Double(index + 1)
            }
        }

        progressView.updateProgress(progress: stepIndex / Double(steps.count))

        delay(0.15) {
            UIView.transition(with: self.titleLabel, duration: labelAnimation ? 0.4 : 0.0, options: .transitionCrossDissolve, animations: {
                self.subtitleLabel.text = step.headerSubtitle
            }, completion: nil)
        }
    }

    @objc func skipOnboardingTapped(button: UIButton!) {
        delegate?.didTapSkipButton()
    }

    func hideSkipButton() {
        UIView.animate(withDuration: 0.15) {
            self.skipButton.alpha = 0
        }
    }
}
