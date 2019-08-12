import UIKit
import Cartography

protocol ShareItemUserSearchResultTableViewCellDelegate {}

enum ShareItemSelectionState {
    case selected
    case unselected

    var image: UIImage? {
        switch self {
        case .selected:
            return UIImage(named: "icon-row-selected")
        case .unselected:
            return UIImage(named: "icon-row-unselected")
        }
    }
}

class ShareItemUserSearchResultTableViewCell: UITableViewCell {

    var user: User?
    var selectionState: ShareItemSelectionState = .unselected
    var delegate: ShareItemUserSearchResultTableViewCellDelegate?

    private lazy var profilePictureImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        let size: CGFloat = 44

        imageView.layer.cornerRadius = size / 2
        imageView.layer.masksToBounds = true

        constrain(imageView) { imageView in
            imageView.width == size
            imageView.height == size
        }

        return imageView
    }()

    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .semiBold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black70,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var labelView: UIView = {
        let view = UIView(frame: .zero)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        constrain(titleLabel, subtitleLabel, view) { titleLabel, subtitleLabel, view in
            titleLabel.top == view.top + 4
            titleLabel.right == view.right
            titleLabel.left == view.left

            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.right == titleLabel.right
            subtitleLabel.bottom == view.bottom - 4
            subtitleLabel.left == titleLabel.left
        }

        return view
    }()

    private lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        let size: CGFloat = 24

        imageView.backgroundColor = FaveColors.White

        constrain(imageView) { imageView in
            imageView.width == size
            imageView.height == size
        }

        return imageView
    }()

    private lazy var selectedBackgroundColorView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.White

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectedBackgroundView = selectedBackgroundColorView

        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(labelView)
        contentView.addSubview(accessoryImageView)

        constrain(profilePictureImageView, contentView) { imageView, view in
            imageView.top == view.top + 8
            imageView.left == view.left + 16
            imageView.bottom == view.bottom - 8
        }

        constrain(labelView, profilePictureImageView, contentView) { labelView, profilePictureImageView, view in
            labelView.centerY == view.centerY
            labelView.left == profilePictureImageView.right + 16
        }

        constrain(accessoryImageView, labelView, contentView) { accessoryImageView, labelView, view in
            accessoryImageView.centerY == view.centerY
            accessoryImageView.right == view.right - 16
            accessoryImageView.left == labelView.right + 16
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(user: User, isSelected: Bool) {
        self.user = user
        self.selectionState = isSelected ? .selected : .unselected

        titleLabel.text = user.handle
        subtitleLabel.text = "\(user.firstName) \(user.lastName)"
        profilePictureImageView.image = UIImage(base64String: user.profilePicture)


        UIView.transition(with: self.accessoryImageView, duration: 0.15, options: .transitionCrossDissolve, animations: {
            self.accessoryImageView.image = self.selectionState.image
        }, completion: nil)
    }
}
