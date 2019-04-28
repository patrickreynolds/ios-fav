import Foundation
import UIKit

import Cartography

class DiscoverUserSectionHeaderView: UIView {

    let user: User

    let profileImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        let imageViewDiameter: CGFloat = 48

        imageView.layer.cornerRadius = imageViewDiameter / 2
        imageView.layer.masksToBounds = true

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

    init(user: User) {
        self.user = user

        super.init(frame: CGRect.zero)

        addSubview(profileImageView)
        addSubview(titleLabel)

        constrain(profileImageView, self) { profileImageView, view in
            profileImageView.top == view.top + 16
            profileImageView.bottom == view.bottom - 8
            profileImageView.left == view.left + 16
        }

        constrain(titleLabel, profileImageView, self) { titleLabel, profileImageView, view in
            titleLabel.top == view.top + 12
            titleLabel.right == view.right - 16
            titleLabel.bottom == view.bottom - 12
            titleLabel.left == profileImageView.right + 16
        }

        profileImageView.image = UIImage(base64String: user.profilePicture)
        titleLabel.text = "\(user.firstName) \(user.lastName)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
