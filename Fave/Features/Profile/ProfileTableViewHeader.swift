import Foundation
import UIKit

import Cartography

class ProfileTableViewHeader: UIView {
    struct Constants {
        static let HorizontalSpacing: CGFloat = 48
    }

    let user: User

    let userButton = UIButton(frame: CGRect.zero)

    let nameLabel = Label(text: "Temp",
                               font: FaveFont(style: .h3, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

    let aboutMeLabel = Label(
        text: "Must-read books, niche podcasts, undiscovered places, fresh kicks, and good food.",
        font: FaveFont.init(style: .h5, weight: .regular),
        textColor: FaveColors.Black70,
        textAlignment: .left,
        numberOfLines: 0)

    let profilePictureImageView = UIImageView.init(frame: CGRect.zero)
    

    init(user: User) {
        self.user = user

        super.init(frame: CGRect.zero)

        self.isUserInteractionEnabled = true

//        nameLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
//        aboutMeLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.vertical)
//
//        profilePictureImageView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)

        userButton.setTitle("Edit profile", for: .normal)
        userButton.setTitleColor(FaveColors.Black90, for: .normal)
        userButton.backgroundColor = UIColor.white
        userButton.addTarget(self, action: #selector(reqeustUserInfo), for: .touchUpInside)
        userButton.layer.cornerRadius = 4
        userButton.layer.borderWidth = 1.0
        userButton.layer.borderColor = FaveColors.Black30.cgColor

        addSubview(userButton)
        addSubview(nameLabel)
        addSubview(aboutMeLabel)
        addSubview(profilePictureImageView)

        constrain(nameLabel, profilePictureImageView, self) { label, imageView, view in
            label.left == view.left + 16
            label.top == view.top + 16
            label.right == imageView.left - 16
        }

        constrain(profilePictureImageView, self) { imageView, view in
            imageView.top == view.top + 16
            imageView.right == view.right - 16
            imageView.height == 80
            imageView.width == 80
        }

        constrain(aboutMeLabel, nameLabel) { subtitleLabel, nameLabel in
            subtitleLabel.left == nameLabel.left
            subtitleLabel.top == nameLabel.bottom
            subtitleLabel.right == nameLabel.right
        }

        constrain(userButton, aboutMeLabel, self) { button, label, view in
            button.top == label.bottom + 16
            button.left == view.left + 16
            button.right == view.right - 16
            button.bottom == view.bottom - 16
        }

        nameLabel.text = ("\(user.firstName) \(user.lastName)")

        let imageData = Data(referencing: user.profilePicture)
        profilePictureImageView.image = UIImage(data: imageData)
        profilePictureImageView.layer.cornerRadius = 80 / 2
        profilePictureImageView.backgroundColor = FaveColors.Black20
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func reqeustUserInfo(sender: UIButton!) {
        print("\(user.description)")

        //        dependencyGraph.faveService.getCurrentUser { response, error in
        //            if let user = response {
        //                print("\n\nUser keys: \(Array(user.keys))\n\n")
        //
        //                print("\n\nUser: \(user.description)\n\n")
        //            }
        //        }
    }
}
