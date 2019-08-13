import UIKit
import Cartography

class AlertVC: FaveVC {

    // MARK: - Properties

    private let contentView: UIView
    fileprivate let actions: [ Action ]
    private let animator: UIViewControllerTransitioningDelegate
    private let collectionView: UICollectionView
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    /// Creates a AlertVC with the specified content view and actions for the preferred style, if possible.
    ///
    /// - parameter dependencyGraph: A reference to a DependencyGraphType.
    /// - parameter analyticsImpressionEvent: The impression event that will be logged with the alert is shown.
    /// - parameter contentView: The view that will be displayed at the top of the alert. It's height should be computable
    /// assuming that its width is constrained.
    /// - parameter actions: An array of actions that the alert should display. This array should not be empty because then
    init(dependencyGraph: DependencyGraphType,
         analyticsImpressionEvent: AnalyticsImpressionEvent = .alertShown,
         contentView: UIView,
         actions: [Action]) {
        self.contentView = contentView
        self.actions = actions.sorted { $0.type.rawValue < $1.type.rawValue }

        let collectionViewLayout: UICollectionViewLayout
        let collectionViewCellClass: AlertCollectionViewCell.Type
        animator = DialogAnimator()
        collectionViewLayout = DialogAlertCollectionViewLayout(actions: self.actions)
        collectionViewCellClass = DialogAlertCollectionViewCell.self


        self.collectionView = {
            let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
            collectionView.backgroundColor = UIColor.clear
            collectionView.delaysContentTouches = false
            collectionView.register(collectionViewCellClass)
            collectionView.isScrollEnabled = false // This is a temporary fix to a bug where the collection view is scrollable when it shouldn't. We will go back and address then in the future when it becomes an issue such as when we want to support landscape mode.

            return collectionView
        }()

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: analyticsImpressionEvent)

        collectionView.dataSource = self
        collectionView.delegate = self

        modalPresentationStyle = .custom
        transitioningDelegate = animator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        view.addSubview(contentView)
        view.addSubview(collectionView)

        constrain(contentView, collectionView, view) { contentView, collectionView, superview  in
            contentView.top == superview.top
            contentView.left == superview.left
            contentView.right == superview.right

            collectionView.top == contentView.bottom
            collectionView.bottom == superview.bottom
            collectionView.left == superview.left
            collectionView.right == superview.right
            collectionViewHeightConstraint = (collectionView.height == 0)

            // This is for the edge case where so many actions are added to the collection view that it would go off the
            // edge of the screen. The height constraint could break in that scenario and the collection view would be
            // allowed to scroll naturally.
            collectionViewHeightConstraint?.priority = UILayoutPriority.defaultHigh
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // UICollectionView has no intrinsic content size based on its content. You need to explicitly set a height
        // constraint to make it be as big as it needs to display its content without scrolling.
        collectionViewHeightConstraint?.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
    }
}

// MARK: - Action Extension

extension AlertVC {
    class Action: NSObject {
        // MARK: - Enumerations

        enum `Type`: Int {
            case positive
            case negative
            case neutral
            case positiveReversed
        }

        // MARK: - Type Aliases

        typealias ShouldDismissClosure = (() -> Bool)
        typealias DidDismissClosure = (() -> Void)

        // MARK: - Properties

        let title: String
        let type: Type
        let icon: UIImage?
        let shouldDismiss: ShouldDismissClosure
        let didDismiss: DidDismissClosure
        @objc dynamic var enabled: Bool = true

        // MARK: - Initializers

        init(title: String, type: Type, icon: UIImage? = nil, shouldDismiss: @escaping ShouldDismissClosure = { return true }, didDismiss: @escaping DidDismissClosure = {}) {
            self.title = title
            self.type = type
            self.icon = icon
            self.shouldDismiss = shouldDismiss
            self.didDismiss = didDismiss
        }
    }
}

// MARK: - UICollectionViewDataSource Extension

extension AlertVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(DialogAlertCollectionViewCell.self, indexPath: indexPath)

        let action = actions[indexPath.row]
        cell.populate(action: action)

        return cell
    }
}

// MARK: - UICollectionViewDelegate Extension

extension AlertVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let action = actions[indexPath.row]

        return action.enabled
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let action = actions[indexPath.row]

        if action.shouldDismiss() {
            dismiss(animated: true) {
                action.didDismiss()
            }
        }
    }
}

