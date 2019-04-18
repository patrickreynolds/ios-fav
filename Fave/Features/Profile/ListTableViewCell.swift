import Foundation
import UIKit
import Cartography

class ListTableViewCell: UITableViewCell {
    private lazy var titleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .semiBold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

        label.setContentHuggingPriority(.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        label.contentHuggingPriority = .defaultLow

        return label
    }()

    private lazy var followerLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black60,
                               textAlignment: .left,
                               numberOfLines: 1)

        return label
    }()

    private lazy var entryLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black60,
                               textAlignment: .left,
                               numberOfLines: 1)

        label.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        label.contentHuggingPriority = .defaultHigh

        return label
    }()

    private lazy var navigationIndicatorImageView: UIView = {
        let imageView = UIImageView(frame: CGRect.zero)

        imageView.image = UIImage(named: "icon-chevron-right")
        imageView.tintColor = FaveColors.Black50
        imageView.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)

        return imageView
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black10

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(followerLabel)

        contentView.addSubview(entryLabel)
        contentView.addSubview(navigationIndicatorImageView)

        contentView.addSubview(borderView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 12
            label.left == view.left + 16
        }

        constrain(followerLabel, titleLabel, contentView) { label, titleLabel, view in
            label.left == titleLabel.left
            label.top == titleLabel.bottom
            label.bottom == view.bottom - 12
        }

        constrain(entryLabel, titleLabel, contentView) { label, titleLabel, view in
            label.left == titleLabel.right + 16
            label.top == titleLabel.top
        }

        constrain(navigationIndicatorImageView, entryLabel, contentView) { imageView, entryLabel, view in
            imageView.left == entryLabel.right + 2
            imageView.right == view.right - 16
            imageView.centerY == entryLabel.centerY
            imageView.height == 20
            imageView.width == 20
        }

        constrain(borderView, contentView) { borderView, view in
            borderView.left == view.left + 16
            borderView.right == view.right - 16
            borderView.bottom == view.bottom
            borderView.height == 1
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(list: List) {
        titleLabel.text = list.title

        let followerString = list.numberOfFollowers == 1 ? "\(list.numberOfFollowers) follower" : "\(list.numberOfFollowers) followers"
        followerLabel.text = followerString

        entryLabel.text = "\(list.numberOfItems)"
    }
}
