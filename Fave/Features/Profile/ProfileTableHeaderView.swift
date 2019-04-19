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
        text: true ? "Must-read books, niche podcasts, undiscovered places, fresh kicks, and good food." : "",
        font: FaveFont.init(style: .h5, weight: .regular),
        textColor: FaveColors.Black70,
        textAlignment: .left,
        numberOfLines: 0)

    let followingLabel = Label(
        text: "20 Followers",
        font: FaveFont.init(style: .h5, weight: .regular),
        textColor: FaveColors.Black90,
        textAlignment: .left,
        numberOfLines: 0)

    let profilePictureImageView = UIImageView.init(frame: CGRect.zero)

    private lazy var profileHeaderStackView: UIStackView = {
        let headerStackView = UIStackView(frame: .zero)

        let labelsStackView = UIStackView(frame: .zero)
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(aboutMeLabel)
        labelsStackView.addArrangedSubview(followingLabel)

        nameLabel.contentCompressionResistancePriority = .defaultHigh
        aboutMeLabel.contentCompressionResistancePriority = .defaultHigh
        aboutMeLabel.contentHuggingPriority = .defaultHigh
        nameLabel.contentHuggingPriority = .defaultHigh

        labelsStackView.axis = .vertical
        labelsStackView.distribution = .fillProportionally
        labelsStackView.alignment = .fill


        let primaryInfoStackView = UIStackView(frame: .zero)
        primaryInfoStackView.addArrangedSubview(labelsStackView)
        primaryInfoStackView.addArrangedSubview(profilePictureImageView)

        primaryInfoStackView.axis = .horizontal
//        primaryInfoStackView.distribution = .fillProportionally
//        primaryInfoStackView.alignment = .fill
        primaryInfoStackView.spacing = 16



        let editProfileButtonStackView = UIStackView(frame: .zero)
        editProfileButtonStackView.addArrangedSubview(editProfileButton)



        let listCountStackView = UIStackView.init(frame: .zero)
        listCountStackView.addArrangedSubview(listsLabel)
        listCountStackView.alignment = UIStackView.Alignment.leading


        headerStackView.addArrangedSubview(primaryInfoStackView)
        headerStackView.addArrangedSubview(editProfileButtonStackView)
        headerStackView.addArrangedSubview(listCountStackView)

        headerStackView.axis = .vertical
        headerStackView.distribution = .fillProportionally
        headerStackView.alignment = .fill

        return headerStackView
    }()

    init(dependencyGraph: DependencyGraphType, user: User?) {
        self.dependencyGraph = dependencyGraph
        self.user = user

        super.init(frame: CGRect.zero)

        isUserInteractionEnabled = true

        addSubview(profileHeaderStackView)

        constrain(profilePictureImageView, self) { imageView, view in
            imageView.height == 80
            imageView.width == 80
        }

        constrainToSuperview(profileHeaderStackView)

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

        profilePictureImageView.image = UIImage.init(base64String: unwrappedUser.profilePicture)
        profilePictureImageView.layer.cornerRadius = 80 / 2
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.clipsToBounds = true
    }

    @objc func editProfile(sender: UIButton!) {
        delegate?.editProfileButtonTapped()
    }
}
