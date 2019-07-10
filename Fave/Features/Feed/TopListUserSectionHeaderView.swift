import UIKit

import Cartography

protocol TopListUserSectionHeaderViewDelegate {
    func didSelectTopListUserHeader(user: User)
}

class TopListUserSectionHeaderView: UIView {

    var delegate: TopListUserSectionHeaderViewDelegate?

    var owner: User?

    let profileImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        let imageViewDiameter: CGFloat = 48

        imageView.layer.cornerRadius = imageViewDiameter / 2
        imageView.layer.masksToBounds = true

        imageView.backgroundColor = FaveColors.Black20

        constrain(imageView) { imageView in
            imageView.height == imageViewDiameter
            imageView.width == imageViewDiameter
        }

        return imageView
    }()

    let titleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .semiBold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var ownerLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black60,
                               textAlignment: .left,
                               numberOfLines: 1)

        return label
    }()

    init(list: List) {
        self.owner = list.owner

        super.init(frame: CGRect.zero)

        addSubview(profileImageView)
        addSubview(titleLabel)
        addSubview(ownerLabel)

        constrain(profileImageView, self) { profileImageView, view in
            profileImageView.top == view.top + 16
            profileImageView.bottom == view.bottom - 8
            profileImageView.left == view.left + 16
        }

        constrain(titleLabel, profileImageView, self) { titleLabel, profileImageView, view in
            titleLabel.top == view.top + 12
            titleLabel.right == view.right - 16
            titleLabel.left == profileImageView.right + 16
        }

        constrain(ownerLabel, titleLabel, self) { ownerLabel, titleLabel, view in
            ownerLabel.top == titleLabel.bottom

            ownerLabel.left == titleLabel.left
            ownerLabel.right == titleLabel.right

            ownerLabel.bottom == view.bottom - 12
        }

        profileImageView.image = UIImage(base64String: list.owner.profilePicture)
        titleLabel.text = list.title
        ownerLabel.text = "by \(list.owner.handle)"

        isUserInteractionEnabled = true

        _ = tapped { tapped in
            if let owner = self.owner {
                self.delegate?.didSelectTopListUserHeader(user: owner)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
