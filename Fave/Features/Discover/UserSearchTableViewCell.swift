import UIKit
import Cartography

class UserTableViewCell: UITableViewCell {

    private lazy var profilePictureImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        constrain(imageView) { imageView in
            imageView.height == 48
            imageView.width == 48
        }

        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true

        return imageView
    }()

    private lazy var labelView: UIView = {
        let view = UIView.init(frame: .zero)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        constrainToSuperview(titleLabel, exceptEdges: [.bottom])
        constrainToSuperview(subtitleLabel, exceptEdges: [.top])

        constrain(titleLabel, subtitleLabel) { titleLabel, subtitleLabel in
            subtitleLabel.top == titleLabel.bottom
        }

        return view
    }()

    private lazy var titleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .small, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .small, weight: .regular),
                               textColor: FaveColors.Black70,
                               textAlignment: .left,
                               numberOfLines: 0)

        return label
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black10

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(labelView)

        contentView.addSubview(borderView)

        constrain(profilePictureImageView, contentView) { imageView, view in
            imageView.top == view.top + 12
            imageView.left == view.left + 16
            imageView.bottom == view.bottom - 12
        }

        constrain(labelView, profilePictureImageView, contentView) { labelView, imageView, view in
            labelView.left == imageView.right + 16
            labelView.right == view.right - 16
            labelView.centerY == imageView.centerY
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

    func populate(user: User) {
        titleLabel.text = user.handle
        subtitleLabel.text = "\(user.firstName) \(user.lastName)"

        self.profilePictureImageView.image = UIImage(base64String: user.profilePicture)
    }
}
