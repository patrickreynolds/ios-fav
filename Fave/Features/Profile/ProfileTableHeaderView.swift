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

    private lazy var listsLabel: Label = {

//        if let user = user {
//            let titleString = "0 Lists" // self.lists.count == 1 ? "\(self.lists.count) List" : "\(self.lists.count) Lists"
//        }

        let titleString = "0 Lists"

        let label = Label.init(text: titleString, font: FaveFont(style: .small, weight: .semiBold), textColor: FaveColors.Black70, textAlignment: .left, numberOfLines: 0)

        return label
    }()

    private lazy var editProfileButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.0
        button.layer.borderColor = FaveColors.Black30.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let attributedTitle = NSAttributedString(string: "Edit profile",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.Black90)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    let nameLabel = Label(text: "",
                               font: FaveFont(style: .h3, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

    let aboutMeLabel = Label(
        text: false ? "Must-read books, niche podcasts, undiscovered places, fresh kicks, and good food." : "",
        font: FaveFont.init(style: .h5, weight: .regular),
        textColor: FaveColors.Black70,
        textAlignment: .left,
        numberOfLines: 0)

    let followingLabel = Label(
        text: "Followers",
        font: FaveFont.init(style: .h5, weight: .regular),
        textColor: FaveColors.Black90,
        textAlignment: .left,
        numberOfLines: 0)

    let listCountLabel = Label(
        text: "Lists".uppercased(),
        font: FaveFont.init(style: .xsmall, weight: .semiBold),
        textColor: FaveColors.Black60,
        textAlignment: .left,
        numberOfLines: 0)

    let profilePictureImageView = UIImageView.init(frame: CGRect.zero)

    private lazy var primaryContentView: UIView = {
        let view = UIView(frame: .zero)

        nameLabel.contentCompressionResistancePriority = .defaultHigh
        aboutMeLabel.contentCompressionResistancePriority = .defaultHigh
        aboutMeLabel.contentHuggingPriority = .defaultHigh
        nameLabel.contentHuggingPriority = .defaultHigh

        view.addSubview(nameLabel)
        view.addSubview(aboutMeLabel)
        view.addSubview(followingLabel)
        view.addSubview(profilePictureImageView)

        constrain(nameLabel, profilePictureImageView, view) { nameLabel, imageView, view in
            nameLabel.top == view.top + 16
            nameLabel.right == imageView.left - 16
            nameLabel.left == view.left + 16
        }

        constrain(aboutMeLabel, nameLabel, view) { aboutMeLabel, nameLabel, view in
            aboutMeLabel.top == nameLabel.bottom + 4
            aboutMeLabel.right == nameLabel.right
            aboutMeLabel.left == nameLabel.left
        }

        constrain(followingLabel, aboutMeLabel, view) { followingLabel, aboutMeLabel, view in
            followingLabel.top == aboutMeLabel.bottom + 8
            followingLabel.right == aboutMeLabel.right
            followingLabel.left == aboutMeLabel.left
            followingLabel.bottom == view.bottom - 16
        }

        constrain(profilePictureImageView, view) { imageView, view in
            imageView.top == view.top + 16
            imageView.right == view.right - 16
        }

        constrain(view) { view in
            view.height == (80 + 16 + 16) ~ UILayoutPriority(400)
        }

        return view
    }()

    private lazy var dividerView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 4
        }

        return view
    }()

    init(dependencyGraph: DependencyGraphType, user: User?) {
        self.dependencyGraph = dependencyGraph
        self.user = user

        super.init(frame: CGRect.zero)

        isUserInteractionEnabled = true
        backgroundColor = FaveColors.White

        addSubview(primaryContentView)
        addSubview(editProfileButton)
        addSubview(listCountLabel)
        addSubview(dividerView)

        constrain(profilePictureImageView, self) { imageView, view in
            imageView.height == 80
            imageView.width == 80
        }

        constrainToSuperview(primaryContentView, exceptEdges: [.bottom])

        let isUserProfile = true

        if isUserProfile {
            constrain(editProfileButton, primaryContentView, dividerView, self) { editProfileButton, primaryContentView, dividerView, view in
                editProfileButton.top == primaryContentView.bottom
                editProfileButton.right == view.right - 16
                editProfileButton.left == view.left + 16
                editProfileButton.bottom == dividerView.top - 16
            }
        } else {
            constrain(primaryContentView, dividerView, self) { primaryContentView, dividerView, view in
                dividerView.top == primaryContentView.bottom
            }
        }

        constrain(primaryContentView, dividerView, self) { primaryContentView, dividerView, view in
            dividerView.right == view.right
            dividerView.left == view.left
        }

        constrain(listCountLabel, dividerView, self) { listCountLabel, dividerView, view in
            listCountLabel.top == dividerView.bottom + 16
            listCountLabel.left == view.left + 16
            listCountLabel.bottom == view.bottom
        }

        if let user = user {
            updateUserInfo(user: user)
        } else {
            // put into loading state
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUserInfo(user: User) {
        nameLabel.text = ("\(user.firstName) \(user.lastName)")

        profilePictureImageView.image = UIImage.init(base64String: user.profilePicture)
        profilePictureImageView.layer.cornerRadius = 80 / 2
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.clipsToBounds = true
    }

    func updateListInfo(lists: [List]) {
        listCountLabel.text = lists.count == 1 ? "\(lists.count) List" : "\(lists.count) Lists"
    }

    @objc func editProfile(sender: UIButton!) {
        delegate?.editProfileButtonTapped()
    }
}
