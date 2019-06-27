import UIKit

import Cartography

protocol DiscoverUserListTableViewCellDelegate {
//    func faveItemButtonTapped(item: Item)
//    func shareItemButtonTapped(item: Item)
//    func didTapFollowButtonForList(list: List?)
    func didUpdateRelationship(to relationship: FaveRelationshipType, forList list: List)
}



class DiscoverUserListTableViewCell: UITableViewCell {

    var list: List?
    var delegate: DiscoverUserListTableViewCellDelegate?

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
        contentView.addSubview(followButton)

        constrain(titleLabel, contentView) { titleLabel, view in
            titleLabel.top == view.top + 12
            titleLabel.left == view.left + 16
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

    func populate(list: List) {
        self.list = list

        titleLabel.text = list.title

        let listSubtitleString = list.numberOfFollowers == 1 ? "\(list.numberOfFollowers) follower" : "\(list.numberOfFollowers) followers"

        subtitleLabel.text = listSubtitleString

        let userFollowing = list.isUserFollowing ?? false

        if userFollowing {
            relationship = .following
        } else {
            relationship = .notFollowing
        }
    }

    @objc func didTapFollowButton() {
        guard let list = list else {
            return
        }

        let newRelationship: FaveRelationshipType = relationship == .notFollowing ? .following : .notFollowing

        relationship = newRelationship

        delegate?.didUpdateRelationship(to: newRelationship, forList: list)
    }
}
