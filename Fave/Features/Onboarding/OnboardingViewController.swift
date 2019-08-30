import UIKit

// MARK: Public Imports

import Cartography

protocol OnboardingViewControllerDelegate {
    func didAdvanceOnboarding()
}

enum OnboardingStepType {
    case createList(user: User, step: Int)
    case addEntry(user: User, step: Int)
    case askForReccomendations(user: User, step: Int)
    case setupNotifications(user: User, step: Int)

    var headerTitle: String {
        return "Welcome to Fave"
    }

    var headerSubtitle: String {
        switch self {
        case .createList(_, let step):
            return "Step \(step): Create a list"
        case .addEntry(_, let step):
            return "Step \(step): Add en entry"
        case .askForReccomendations(_, let step):
            return "Step \(step): Ask for recommendations"
        case .setupNotifications(_, let step):
            return "Step \(step): Get updates"
        }
    }

    var title: String {
        switch self {
        case .createList:
            return "Welcome! Let’s get started by creating a list."
        case .addEntry:
            return "Now let’s add an entry to your San Francisco Parks list."
        case .askForReccomendations:
            return "Here’s where it get fun. Ask your friends for a few recs!"
        case .setupNotifications(let user, _):
            return "One last thing, \(user.firstName)!"
        }
    }

    var subtitle: String {
        switch self {
        case .createList:
            return ""
        case .addEntry:
            return "Results"
        case .askForReccomendations:
            return "Friends on Fave"
        case .setupNotifications:
            return "Know when you get awesome recs, new followers, and other updates."
        }
    }
}

class OnboardingViewController: FaveVC {

    // MARK: - VC Properties

    let user: User
    let suggestions: [User]
    let steps: [OnboardingStepType]
    var currentStep: OnboardingStepType


    // MARK: - UI Properties

    private lazy var onboardingHeaderView: OnboardingContextualHeaderView = {
        let onboardingView = OnboardingContextualHeaderView(steps: steps)

        return onboardingView
    }()

    private lazy var onboardingScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)

        scrollView.contentSize.width = UIScreen.main.bounds.width * CGFloat(steps.count)
        scrollView.backgroundColor = FaveColors.White
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false

        _ = scrollView.tapped { recognizer in
            self.didAdvanceOnboarding()
        }

        return scrollView
    }()

    private lazy var onboardingStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        let onboardingScreens: [UIView] = steps.enumerated().map { index, type in

            let view = UIView()

            let label = Label(
                text: "Page \(index + 1)",
                font: FaveFont(style: .h4, weight: .light),
                textColor: FaveColors.Black80,
                textAlignment: .center,
                numberOfLines: 1)

            view.addSubview(label)

            view.backgroundColor = index.isMultiple(of: 2) ? FaveColors.Black20 : FaveColors.Black30

            constrain(view, label) { view, label in
                view.width == UIScreen.main.bounds.width

                label.centerX == view.centerX
                label.centerY == view.centerY
            }

            return view
        }

        for page in onboardingScreens {
            stackView.addArrangedSubview(page)
        }

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    // MARK: - Initializers

    init(dependencyGraph: DependencyGraphType, user: User, suggestions: [User]) {
        self.user = user
        self.suggestions = suggestions

        if suggestions.isEmpty {
            self.steps = [
                .createList(user: user, step: 1),
                .addEntry(user: user, step: 2),
                .setupNotifications(user: user, step: 3)
            ]
        } else {
            self.steps = [
                .createList(user: user, step: 1),
                .addEntry(user: user, step: 2),
                .askForReccomendations(user: user, step: 3),
                .setupNotifications(user: user, step: 4)
            ]
        }

        currentStep = steps[0]

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .onboardingScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(onboardingHeaderView)
        view.addSubview(onboardingScrollView)

        onboardingScrollView.addSubview(onboardingStackView)

        constrain(onboardingHeaderView, view) { onboardingHeaderView, view in
            onboardingHeaderView.topMargin == view.topMargin + 52
            onboardingHeaderView.right == view.right
            onboardingHeaderView.left == view.left
        }

        constrain(onboardingScrollView, onboardingHeaderView, view) { onboardingScrollView, onboardingHeaderView, view in
            onboardingScrollView.top == onboardingHeaderView.bottom
            onboardingScrollView.right == view.right
            onboardingScrollView.bottom == view.bottomMargin
            onboardingScrollView.left == view.left
        }

        constrain(onboardingStackView, onboardingScrollView) { stackView, scrollView in
            stackView.top == scrollView.top
            stackView.right == scrollView.right
            stackView.bottom == scrollView.bottom
            stackView.left == scrollView.left

            stackView.height == scrollView.height
        }

        view.backgroundColor = FaveColors.White

        _ = view.tapped { gesture in
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onboardingHeaderView.advanceToStep(step: currentStep, withLabelAnimation: false)
    }

    fileprivate func offsetForStepIndex(index: Int) -> CGFloat {
        return CGFloat(CGFloat(index) * UIScreen.main.bounds.width)
    }
}

// MARK: - OnboardingViewControllerDelegate

extension OnboardingViewController: OnboardingViewControllerDelegate {
    func didAdvanceOnboarding() {

        guard let lastStep = steps.last, lastStep != currentStep else {
            // Make sure feed is loaded
            navigationController?.dismiss(animated: true, completion: nil)

            return
        }

        var nextStepIndex = 0

        for (index, stepInSteps) in steps.enumerated() {
            if currentStep == stepInSteps {
                nextStepIndex = index + 1
            }
        }

        let nextStep = steps[nextStepIndex]

        let offset = CGPoint.init(x: offsetForStepIndex(index: nextStepIndex), y: 0)
        onboardingScrollView.setContentOffset(offset, animated: true)
        onboardingHeaderView.advanceToStep(step: nextStep)

        currentStep = nextStep
    }
}


// MARK: - OnboardingViewControllerDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\(scrollView.contentOffset)")
    }
}

// MARK: - OnboardingStepType Equatable

extension OnboardingStepType: Equatable {
    public static func ==(a: OnboardingStepType, b: OnboardingStepType) -> Bool {
        return a.title == b.title && a.subtitle == b.subtitle
    }
}
