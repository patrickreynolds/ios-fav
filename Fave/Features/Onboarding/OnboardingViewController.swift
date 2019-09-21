import UIKit

// MARK: Public Imports

import Cartography

protocol OnboardingViewControllerDelegate {
    var keyboardHeight: CGFloat { get set }

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
            return "Step \(step): Add an entry"
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
        case .addEntry(_, _):
            return ""
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
    var stepViews: [UIView] = []
    var currentStep: OnboardingStepType
    var list: List?
    var keyboardHeight: CGFloat = 0


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

//        _ = scrollView.tapped { recognizer in
//            self.didAdvanceOnboarding()
//        }

        return scrollView
    }()

    private lazy var onboardingStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        let onboardingScreens: [UIView] = steps.enumerated().map { index, step in

            if index == 0 {
                let view = CreateListOnboardingStepView(step: step)

                view.delegate = self
                view.createListDelegate = self

                stepViews.append(view)

                return view
            } else if index == 1 {
                let view: AddEntryOnboardingStepView = AddEntryOnboardingStepView(step: step)

                view.list = list
                view.delegate = self

                view.delegate = self
                view.addEntryDelegate = self

                stepViews.append(view)

                return view
            } else {
                if suggestions.isEmpty {
                    let view = GetUpdatesOnboardingStepView(step: step)
                    view.delegate = self

                    return view
                } else {
                    if index == 2 {
                        // Return recommendations

                        return UIView()
                    } else {
                        let view = GetUpdatesOnboardingStepView(step: step)
                        view.delegate = self

                        return view
                    }
                }
            }
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
            onboardingHeaderView.topMargin == view.topMargin + 40
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

        if let view = stepViews[safeIndex: nextStepIndex] as? AddEntryOnboardingStepView {
            view.makeAddEntryFirstResponder()
        } else if let view = stepViews[safeIndex: nextStepIndex] as? GetUpdatesOnboardingStepView {
            view.showPushNotificationsPrompt(dependencyGraph: dependencyGraph, viewController: self)
        }

        let offset = CGPoint(x: offsetForStepIndex(index: nextStepIndex), y: 0)
        onboardingScrollView.setContentOffset(offset, animated: true)
        onboardingHeaderView.advanceToStep(step: nextStep)

        currentStep = nextStep
    }
}


extension OnboardingViewController: CreateListOnboardingStepViewDelegate {
    func createList(title: String, completion: @escaping (_ listId: Int) -> ()) {
        delay(0.5) {
            completion(1)
        }
    }
}

extension OnboardingViewController: AddEntryOnboardingStepViewDelegate {
    func didSelectItem(placeId: String, completion: @escaping () -> ()) {
        delay(0.5) {
            completion()
        }
    }
}


// MARK: - OnboardingViewControllerDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("\(scrollView.contentOffset)")
    }
}


// MARK: - OnboardingStepType Equatable

extension OnboardingStepType: Equatable {
    public static func ==(a: OnboardingStepType, b: OnboardingStepType) -> Bool {
        return a.title == b.title && a.subtitle == b.subtitle
    }
}
