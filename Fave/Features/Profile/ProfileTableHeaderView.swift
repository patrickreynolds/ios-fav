import Foundation
import UIKit

import Cartography

protocol ProfileTableHeaderViewDelegate {
    func editProfileButtonTapped()
}

class ProfileTableHeaderView: UIView {
    struct Constants {
        static let HorizontalSpacing: CGFloat = 0
    }

    let dependencyGraph: DependencyGraphType
    let user: User?
    var delegate: ProfileTableHeaderViewDelegate?

    var topButtonConstraint: NSLayoutConstraint?
    var bottomButtonConstraint: NSLayoutConstraint?
    var bottomLabelConstraint: NSLayoutConstraint?

    private lazy var editProfileButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1.0
        button.layer.borderColor = FaveColors.Black30.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let attributedTitle = NSAttributedString(string: "Edit profile",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.Black90)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    let nameLabel = Label(text: "Temp",
                               font: FaveFont(style: .h2, weight: .bold),
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

        addSubview(editProfileButton)
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

        constrain(aboutMeLabel, nameLabel, self) { subtitleLabel, nameLabel, view in
            subtitleLabel.left == nameLabel.left
            subtitleLabel.top == nameLabel.bottom
            subtitleLabel.right == nameLabel.right
            bottomLabelConstraint = subtitleLabel.bottom == view.bottom - 16
        }

        constrain(editProfileButton, aboutMeLabel, self) { button, label, view in
            topButtonConstraint = button.top == label.bottom + 16
            button.left == view.left + 16
            button.right == view.right - 16
            bottomButtonConstraint = button.bottom == view.bottom - 16
        }

        updateUserInfo(user: user)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUserInfo(user: User?) {

        guard let unwrappedUser = user else {
            return
        }

        nameLabel.text = ("\(unwrappedUser.firstName) \(unwrappedUser.lastName)")

        let imageData = Data(referencing: unwrappedUser.profilePicture)
        profilePictureImageView.image = UIImage(data: imageData)
        profilePictureImageView.layer.cornerRadius = 80 / 2
        profilePictureImageView.backgroundColor = FaveColors.Black20

        guard let currentUser = dependencyGraph.storage.getUser() else {
            topButtonConstraint?.isActive = false
            bottomButtonConstraint?.isActive = false
            bottomLabelConstraint?.isActive = true

            return
        }

        if unwrappedUser.id == currentUser.id {
            topButtonConstraint?.isActive = true
            bottomButtonConstraint?.isActive = true
            bottomLabelConstraint?.isActive = false
        } else {
            topButtonConstraint?.isActive = false
            bottomButtonConstraint?.isActive = false
            bottomLabelConstraint?.isActive = true
        }
    }

    @objc func editProfile(sender: UIButton!) {
        delegate?.editProfileButtonTapped()
    }
}
