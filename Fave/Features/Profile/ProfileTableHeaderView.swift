import UIKit

import Cartography

protocol ProfileTableHeaderViewDelegate {
    func editProfileButtonTapped()
    func didTapFollowingListsLabel(user: User)
    func relationshipButtonTapped(relationship: UserRelationship, userId: Int)
}

enum UserRelationship {
    case loading
    case following
    case notFollowing
}

class ProfileTableHeaderView: UIView {
    struct Constants {
        static let HorizontalSpacing: CGFloat = 0
    }

    let dependencyGraph: DependencyGraphType
    var user: User?
    var delegate: ProfileTableHeaderViewDelegate?

    var followingCount: Int = 0 {
        didSet {
            guard followingCount != oldValue else {
                return
            }

            updateFollowingCountLabel(followingCount: followingCount)
        }
    }

    private var relationshipStatus: UserRelationship = .loading {
        didSet {

            let title: String
            let textColor: UIColor
            let backgroundColor: UIColor
            let borderColor: UIColor


            switch relationshipStatus {
            case .loading:

                title = "Loading..."
                textColor = FaveColors.Black70
                backgroundColor = FaveColors.White
                borderColor = FaveColors.Black30

            case .following:

                title = "Following"
                textColor = FaveColors.Black90
                backgroundColor = FaveColors.White
                borderColor = FaveColors.Black30

            case .notFollowing:

                title = "Follow"
                textColor = FaveColors.White
                backgroundColor = FaveColors.Accent
                borderColor = FaveColors.Accent

            }

            let attributedTitle = NSAttributedString(string: title,
                                                     font: FaveFont(style: .h5, weight: .semiBold).font,
                                                     textColor: textColor)

            UIView.animate(withDuration: 0.15) {
                self.relationshipButton.backgroundColor = backgroundColor
                self.relationshipButton.layer.borderColor = borderColor.cgColor
                self.relationshipButton.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
    }

    private lazy var listsLabel: Label = {

        let titleString = "0 Lists"

        let label = Label(text: titleString, font: FaveFont(style: .small, weight: .semiBold), textColor: FaveColors.Black70, textAlignment: .left, numberOfLines: 0)

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

    private lazy var relationshipButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.backgroundColor = FaveColors.White
        button.addTarget(self, action: #selector(relationshipButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.0
        button.layer.borderColor = FaveColors.Black30.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let attributedTitle = NSAttributedString(string: "Loading...",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.Black70)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    let nameLabel = Label(text: "",
                               font: FaveFont(style: .h3, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

    let aboutMeLabel = Label(
        text: "",
        font: FaveFont(style: .h5, weight: .regular),
        textColor: FaveColors.Black70,
        textAlignment: .left,
        numberOfLines: 0)

    lazy var followingLabel: Label = {
        let label = Label(
            text: "Not following any lists",
            font: FaveFont(style: .h5, weight: .regular),
            textColor: FaveColors.Black90,
            textAlignment: .left,
            numberOfLines: 0)

        _ = label.tapped { _ in
            if let user = self.user {
                self.delegate?.didTapFollowingListsLabel(user: user)
            }
        }

        label.isUserInteractionEnabled = true

        return label
    }()

    let listCountLabel = Label(
        text: "No lists".uppercased(),
        font: FaveFont(style: .small, weight: .semiBold),
        textColor: FaveColors.Black60,
        textAlignment: .left,
        numberOfLines: 0)

    let profilePictureImageView = UIImageView(frame: CGRect.zero)

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

    private lazy var actionsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 16

        return stackView
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 8
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
        addSubview(actionsStackView)
        addSubview(listCountLabel)
        addSubview(dividerView)

        constrain(profilePictureImageView, self) { imageView, view in
            imageView.height == 80
            imageView.width == 80
        }

        constrainToSuperview(primaryContentView, exceptEdges: [.bottom])

        constrain(actionsStackView, primaryContentView, dividerView, self) { editProfileButton, primaryContentView, dividerView, view in
            editProfileButton.top == primaryContentView.bottom + 16
            editProfileButton.right == view.right - 16
            editProfileButton.left == view.left + 16
            editProfileButton.bottom == dividerView.top - 16
        }

        var isUserProfile = false

        if let user = user {
            if let currentUser = dependencyGraph.storage.getUser() {
                isUserProfile = user.id == currentUser.id

                self.user = isUserProfile ? currentUser : user
            }
        } else {
            isUserProfile = true
        }

        if isUserProfile {
            actionsStackView.addArrangedSubview(editProfileButton)
        } else {
            actionsStackView.addArrangedSubview(relationshipButton)
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

    func updateUserInfo(user: User, followingCount: Int = 0) {
        self.user = user

        nameLabel.text = ("\(user.firstName) \(user.lastName)")

        profilePictureImageView.image = UIImage(base64String: user.profilePicture)
        profilePictureImageView.layer.cornerRadius = 80 / 2
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.clipsToBounds = true

        self.followingCount = followingCount
        
        if user.bio.isEmpty {
            aboutMeLabel.text = ""
        } else {
            aboutMeLabel.text = user.bio
            aboutMeLabel.textColor = FaveColors.Black90
        }
    }

    func updateListInfo(lists: [List]) {
        let listString = lists.count == 1 ? "List".uppercased() : "Lists".uppercased()
        listCountLabel.text = "\(lists.count) \(listString)"
    }

    func updateRelationship(relationship: UserRelationship) {
        self.relationshipStatus = relationship
    }

    @objc func editProfile(sender: UIButton!) {
        delegate?.editProfileButtonTapped()
    }

    @objc func relationshipButtonTapped(button: UIButton!) {
        guard let user = user else {
            return
        }

        delegate?.relationshipButtonTapped(relationship: relationshipStatus, userId: user.id)
    }

    func updateFollowingCountLabel(followingCount: Int) {
        let followingAttributedText: NSMutableAttributedString = NSMutableAttributedString()

        let primaryAttributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: FaveFont(style: .h5, weight: .semiBold).font,
            NSAttributedString.Key.foregroundColor: FaveColors.Black90
        ]

        let standardAttributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: FaveFont(style: .h5, weight: .regular).font,
            NSAttributedString.Key.foregroundColor: FaveColors.Black90
        ]

        let followingText = NSAttributedString(string: "Following ", attributes: standardAttributes)

        let followingCountText = NSAttributedString(string: "\(followingCount)", attributes: followingCount == 0 ? standardAttributes : primaryAttributes )

        let listText = NSAttributedString(string: " list", attributes: standardAttributes)

        followingAttributedText.append(followingText)
        followingAttributedText.append(followingCountText)
        followingAttributedText.append(listText)

        followingLabel.attributedText = followingAttributedText
    }
}
