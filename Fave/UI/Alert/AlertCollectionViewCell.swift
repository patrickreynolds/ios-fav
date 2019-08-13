import UIKit

import Cartography

/// The AlertCollectionViewCell is a UICollectionViewCell subclass that represents a "button" inside the AlertVC.
///
/// It is a simple label whose text color changes based on the highlighted state of the cell and the type of the action
/// that the cell is representing.
class AlertCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants

    fileprivate struct Constants {
        static let EnabledKeyPath = "enabled"
    }

    // MARK: - Properties

    var action: AlertVC.Action? {
        willSet {
            action?.removeObserver(self, forKeyPath: Constants.EnabledKeyPath)
        }
        didSet {
            action?.addObserver(self, forKeyPath: Constants.EnabledKeyPath, options: .new, context: nil)
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        accessibilityTraits = .button
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinitializer

    deinit {
        action?.removeObserver(self, forKeyPath: Constants.EnabledKeyPath)
    }

    // MARK: - ReuseableCollectionViewCellType Methods

    override class func defaultReuseIdentifier() -> String {
        return "AlertCollectionViewCell"
    }

    // MARK: - Public Methods

    func populate(action: AlertVC.Action) {
        accessibilityLabel = action.title

        self.action = action
    }

    /// This is a conceptually abstract method designed to be overridden so subclasses can respond to changes in the
    /// action's enabled state.
    func actionEnableStateChanged() {
    }
}

// MARK: - KVO Methods

extension AlertCollectionViewCell {
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        guard object != nil else { return }

        if keyPath == Constants.EnabledKeyPath {
            actionEnableStateChanged()
        }
    }
}

