import UIKit

import Cartography

class DialogAlertCollectionViewCell: AlertCollectionViewCell {
    // MARK: - Constants

    private struct Constants {
        static let LabelHorizontalPadding: CGFloat = 12
    }

    // MARK: - Properties

    private let labelBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4

        return view
    }()

    private let label = Label(font: FaveFont(style: .h5, weight: .bold), textAlignment: .center)

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(labelBackgroundView)
        contentView.addSubview(label)

        constrainToSuperview(labelBackgroundView)
        let labelInsets = UIEdgeInsets(top: 0,
                                       left: Constants.LabelHorizontalPadding,
                                       bottom: 0,
                                       right: Constants.LabelHorizontalPadding)
        constrainToSuperview(label, edgeInsets: labelInsets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - AlertCollectionViewCell Methods

    override func populate(action: AlertVC.Action) {
        super.populate(action: action)

        label.text = action.title

        update(isHighlighted)
    }

    override func actionEnableStateChanged() {
        update(false)
    }

    // MARK: - UICollectionViewCell Methods

    override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue

            update(newValue)
        }
        get {
            return super.isHighlighted
        }
    }

    // MARK: - ReuseableCollectionViewCellType Methods

    override class func defaultReuseIdentifier() -> String {
        return super.defaultReuseIdentifier()
    }

    // MARK: - Private Methods

    fileprivate func update(_ highlighted: Bool) {
        guard let actionType = action?.type else { return }

        guard action?.enabled == true else {
            label.textColor = FaveColors.Black20
            return
        }

        switch actionType {
        case .positive:
            labelBackgroundView.backgroundColor = highlighted ? FaveColors.Accent : FaveColors.Accent
            label.textColor = FaveColors.White
        case .negative:
            labelBackgroundView.backgroundColor = highlighted ? FaveColors.RedDark : FaveColors.Red
            label.textColor = FaveColors.White
        case .neutral:
            labelBackgroundView.backgroundColor = FaveColors.Clear
            label.textColor = highlighted ? FaveColors.Black80 : FaveColors.Black70
        case .positiveReversed:
            labelBackgroundView.backgroundColor = FaveColors.Clear
            label.textColor = highlighted ? FaveColors.Accent : FaveColors.Accent
        }
    }
}

