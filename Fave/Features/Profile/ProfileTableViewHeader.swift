import Foundation
import UIKit

import Cartography

class ProfileTableViewHeader: UIView {
    struct Constants {
        static let HorizontalSpacing: CGFloat = 0
    }

    let user: User?
    let dependencyGraph: DependencyGraphType

    private lazy var userButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitle("Edit profile", for: .normal)
        button.setTitleColor(FaveColors.Black90, for: .normal)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(reqeustUserInfo), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1.0
        button.layer.borderColor = FaveColors.Black30.cgColor

        return button
    }()

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
    

    init(dependencyGraph: DependencyGraphType, user: User?) {
        self.dependencyGraph = dependencyGraph
        self.user = user

        super.init(frame: CGRect.zero)

        isUserInteractionEnabled = true

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

        updateUserInfo(user: user)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUserInfo(user: User?) {
        nameLabel.text = ("\(user?.firstName ?? "") \(user?.lastName ?? "")")

        if let unwrappedUser = user {
            let imageData = Data(referencing: unwrappedUser.profilePicture)
            profilePictureImageView.image = UIImage(data: imageData)
            profilePictureImageView.layer.cornerRadius = 80 / 2
            profilePictureImageView.backgroundColor = FaveColors.Black20
        }
    }

    @objc func reqeustUserInfo(sender: UIButton!) {
        print("\nEdit profile\n")
    }
}
