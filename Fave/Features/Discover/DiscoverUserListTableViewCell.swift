import UIKit

import Cartography

protocol DiscoverUserTableViewCellDelegate {
//    func faveItemButtonTapped(item: Item)
//    func shareItemButtonTapped(item: Item)
//    func didTapFollowButtonForList(list: List?)
    func showLogin()
    func didUpdateRelationship(to relationship: FaveRelationshipType, forUser user: User)
}

class DiscoverUserTableViewCell: UITableViewCell {

    var user: User?
    var dependencyGraph: DependencyGraphType?
    var delegate: DiscoverUserTableViewCellDelegate?

    private var relationship: FaveRelationshipType = .notFollowing {
        didSet {
            if relationship == .following {
                let attributedTitle = NSAttributedString(string: "Following",
                                                         font: FaveFont(style: .small, weight: .semiBold).font,
                                                         textColor: FaveColors.Black90)
                followButton.setAttributedTitle(attributedTitle, for: .normal)

                followButton.backgroundColor = FaveColors.White

                followButton.layer.borderColor = FaveColors.Black30.cgColor
                followButton.layer.borderWidth = 1
            } else {
                let attributedTitle = NSAttributedString(string: "Follow",
                                                         font: FaveFont(style: .small, weight: .semiBold).font,
                                                         textColor: FaveColors.White)
                followButton.setAttributedTitle(attributedTitle, for: .normal)

                followButton.backgroundColor = FaveColors.Accent
                followButton.layer.borderWidth = 0
            }
        }
    }

    let titleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .semiBold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    let subtitleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black60,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        let imageViewDiameter: CGFloat = 40

        imageView.layer.cornerRadius = imageViewDiameter / 2
        imageView.layer.masksToBounds = true

        constrain(imageView) { imageView in
            imageView.height == imageViewDiameter
            imageView.width == imageViewDiameter
        }

        return imageView
    }()

    private lazy var followButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.backgroundColor = FaveColors.Accent
        button.setTitleColor(FaveColors.White, for: .normal)
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)

        let attributedTitle = NSAttributedString(string: "Follow",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        button.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.vertical)

        button.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)

        button.isUserInteractionEnabled = true

        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(followButton)

        constrain(profileImageView, contentView) { profileImageView, view in
            profileImageView.centerY == view.centerY
            profileImageView.left == view.left + 16
        }

        constrain(titleLabel, profileImageView, contentView) { titleLabel, profileImageView, view in
            titleLabel.top == view.top + 12
            titleLabel.left == profileImageView.right + 16
        }

        constrain(subtitleLabel, titleLabel, contentView) { subtitleLabel, titleLabel, view in
            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.right == titleLabel.right
            subtitleLabel.bottom == view.bottom - 12
            subtitleLabel.left == titleLabel.left
        }

        constrain(followButton, titleLabel, contentView) { followButton, titleLabel, view in
            followButton.right == view.right - 16
            followButton.left == titleLabel.right + 8
            followButton.centerY == view.centerY
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(dependencyGraph: DependencyGraphType, user: User, isUserFollowing: Bool) {
        self.user = user
        self.dependencyGraph = dependencyGraph

        titleLabel.text = "\(user.firstName) \(user.lastName)"
        subtitleLabel.text = "\(user.handle)"
        profileImageView.image = UIImage(base64String: user.profilePicture)

        if isUserFollowing {
            relationship = .following
        } else {
            relationship = .notFollowing
        }

        if let authenticatedUser = dependencyGraph.storage.getUser(), authenticatedUser.id == user.id {
            followButton.isHidden = true
        }
    }

    @objc func didTapFollowButton(sender: UIButton!) {

        sender.performImpact(style: .light)

        guard let dependencyGraph = dependencyGraph, dependencyGraph.authenticator.isLoggedIn() else {
            delegate?.showLogin()

            return
        }

        guard let user = user else {
            return
        }

        let newRelationship: FaveRelationshipType = relationship == .notFollowing ? .following : .notFollowing

        relationship = newRelationship

        delegate?.didUpdateRelationship(to: newRelationship, forUser: user)
    }
}
