import UIKit

import Cartography

protocol ListTableHeaderViewDelegate {
    func showLogin()
    func entriesButtonTapped()
    func suggestionsButtonTapped()
    func didUpdateRelationship(to relationship: FaveRelationshipType, forList list: List)
    func didTapFollowedByLabel(list: List)
}

enum FaveRelationshipType {
    case notFollowing
    case following
}

class ListTableHeaderView: UIView {

    var list: List
    var delegate: ListTableHeaderViewDelegate?
    let dependencyGraph: DependencyGraphType

    var listItems: [Item] = []

    var entries: [Item] {
        return listItems.filter({ item in
            return !item.isRecommendation
        })
    }

    var recommendations: [Item] {
        return listItems.filter({ item in
            return item.isRecommendation
        })
    }

    var entryTitleString: String {
        return entries.count == 1 ? "\(entries.count) Entry" : "\(entries.count) Entries"
    }

    var recommendationTitleString: String {
        return recommendations.count == 1 ? "\(recommendations.count) Rec" : "\(recommendations.count) Recs"
    }

    var numberOfFollowers = 0 {
        didSet {
            guard numberOfFollowers != oldValue else {
                return
            }

            followerCountLabelText = numberOfFollowers == 1 ? "\(numberOfFollowers) Follower" : "\(numberOfFollowers) Followers"
        }
    }

    var followerCountLabelText = "0 Followers" {
        didSet {

            guard followerCountLabelText != oldValue else {
                return
            }

            followerCountLabel.text = followerCountLabelText
        }
    }

    private var followerRelationship: FaveRelationshipType = .notFollowing {
        didSet {
            guard followerRelationship != oldValue else {
                return
            }

            if followerRelationship == .following {
                let attributedTitle = NSAttributedString(string: "Following",
                                                         font: FaveFont(style: .small, weight: .semiBold).font,
                                                         textColor: FaveColors.Black90)
                relationshipButton.setAttributedTitle(attributedTitle, for: .normal)

                relationshipButton.backgroundColor = FaveColors.White

                relationshipButton.layer.borderColor = FaveColors.Black30.cgColor
                relationshipButton.layer.borderWidth = 1
            } else {
                let attributedTitle = NSAttributedString(string: "Follow",
                                                         font: FaveFont(style: .small, weight: .semiBold).font,
                                                         textColor: FaveColors.White)
                relationshipButton.setAttributedTitle(attributedTitle, for: .normal)

                relationshipButton.backgroundColor = FaveColors.Accent
                relationshipButton.layer.borderWidth = 0
            }
        }
    }

    private lazy var relationshipButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.addTarget(self, action: #selector(didTapRelationshipButton), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)

        let attributedTitle = NSAttributedString(string: "Follow",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var listSegmentedControl: ListSegmentedControl = {
        let listSegmentedControlView = ListSegmentedControl(tabs: [entryTitleString, recommendationTitleString])

        listSegmentedControlView.delegate = self

        return listSegmentedControlView
    }()

    private lazy var titleLabel: Label = {
        let label = Label(text: self.list.title,
                          font: FaveFont(style: .h3, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var listDescriptionLabel: Label = {
        let label = Label(text: self.list.description,
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black70,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var ownerView: UIView = {
        let view = UIView.init(frame: .zero)

        let ownerImageViewDiameter: CGFloat = 24.0

        let ownerNameLabel = Label(text: "by \(self.list.owner.handle)",
                                   font: FaveFont(style: .h5, weight: .regular),
                                   textColor: FaveColors.Black90,
                                   textAlignment: .left,
                                   numberOfLines: 0)

        let ownerImageView = UIImageView.init(frame: .zero)
        ownerImageView.layer.cornerRadius = ownerImageViewDiameter / 2
        ownerImageView.clipsToBounds = true
        ownerImageView.layer.masksToBounds = true
        ownerImageView.image = UIImage.init(base64String: self.list.owner.profilePicture)

        view.addSubview(ownerNameLabel)
        view.addSubview(ownerImageView)

        constrain(ownerNameLabel, ownerImageView, view) { label, imageView, view in
            imageView.left == view.left
            imageView.right == label.left - 8
            imageView.centerX == label.centerX

            label.top == view.top
            label.right == view.right
            label.bottom == view.bottom

            imageView.height == 24
            imageView.width == 24
        }

        return view
    }()

    private lazy var followerCountLabel: Label = {
        let label = Label(text: self.followerCountLabelText,
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        _ = label.tapped { _ in
            self.delegate?.didTapFollowedByLabel(list: self.list)
        }

        label.isUserInteractionEnabled = true

        return label
    }()

    private lazy var relationshipStackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)

        if let user = dependencyGraph.storage.getUser() {
            if list.owner.id != user.id {
                stackView.addArrangedSubview(relationshipButton)
            }

            stackView.addArrangedSubview(followerCountLabel)
        } else {
            stackView.addArrangedSubview(relationshipButton)
            stackView.addArrangedSubview(followerCountLabel)
        }

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 24.0

        return stackView
    }()

    private lazy var borderView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 8
        }

        return view
    }()

    init(dependencyGraph: DependencyGraphType, list: List) {
        self.dependencyGraph = dependencyGraph
        self.list = list
        self.listItems = list.items

        super.init(frame: CGRect.zero)

        isUserInteractionEnabled = true

        backgroundColor = FaveColors.White

        addSubview(titleLabel)
        addSubview(ownerView)
        addSubview(listDescriptionLabel)
        addSubview(relationshipStackView)
        addSubview(listSegmentedControl)
        addSubview(borderView)

        constrain(titleLabel, self) { label, view in
            label.left == view.left + 16
            label.top == view.top + 16
            label.right == view.right - 16
        }

        constrain(ownerView, titleLabel, self) { ownerView, titleLabel, view in
            ownerView.top == titleLabel.bottom + 4
            ownerView.right == view.right - 16
            ownerView.left == view.left + 16
        }

        constrain(listDescriptionLabel, ownerView, self) { descriptionLabel, ownerView, view in
            descriptionLabel.top == ownerView.bottom + 16
            descriptionLabel.right == view.right - 16
            descriptionLabel.left == view.left + 16
        }

        constrain(relationshipStackView, listDescriptionLabel, self) { stackView, label, view in
            stackView.top == label.bottom + 16
            stackView.right == view.right - 16
            stackView.left == view.left + 16
        }

        constrain(listSegmentedControl, relationshipStackView, self) { listSegmentedControl, relationshipStackView, view in
            listSegmentedControl.top == relationshipStackView.bottom + 16
            listSegmentedControl.right == view.right
            listSegmentedControl.bottom == view.bottom
            listSegmentedControl.left == view.left
            listSegmentedControl.height == (list.title.lowercased() == "recommendations" ? 0 : 61) // 1 (top divider) + 56 (tab height) + 4 (bottom divider)
        }

        constrain(borderView, relationshipStackView, listSegmentedControl, self) { borderView, relationshipStackView, listSegmentedControl, view in
            borderView.right == view.right
            borderView.bottom == view.bottom
            borderView.left == view.left

//            borderView.top == listSegmentedControl.top - 1
        }

        if list.title.lowercased() == "recommendations" {
            listSegmentedControl.isHidden = true
            borderView.isHidden = false
        } else {
            borderView.isHidden = true
            listSegmentedControl.isHidden = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTapRelationshipButton(sender: UIButton!) {
        print("\nFollow List Button Tapped\n")

        sender.performImpact(style: .light)

        guard dependencyGraph.authenticator.isLoggedIn() else {
            delegate?.showLogin()

            return
        }

        let newRelationship: FaveRelationshipType = followerRelationship == .notFollowing ? .following : .notFollowing

        followerRelationship = newRelationship

        let followers = numberOfFollowers

        if newRelationship == .following {
            numberOfFollowers = followers + 1
        } else {
            numberOfFollowers = followers - 1
        }

        delegate?.didUpdateRelationship(to: newRelationship, forList: list)
    }

    @objc func shareList(sender: UIButton!) {
        print("\nShare List Button Tapped\n")
    }

    @objc func editList(sender: UIButton!) {
        print("\nEdit List Button Tapped\n")
    }

    @objc func entriesButtonTapped(sender: UIButton!) {
        print("\n\nList Button Tapped\n\n")
        delegate?.entriesButtonTapped()
    }

    @objc func suggestionsButtonTapped(sender: UIButton!) {
        print("\nRecommendations Button Tapped\n")

        delegate?.suggestionsButtonTapped()
    }

    func updateHeaderInfo(list: List, listItems: [Item]) {
        self.listItems = listItems

        listSegmentedControl.updateTitleAtIndex(title: entryTitleString, index: 0)
        listSegmentedControl.updateTitleAtIndex(title: recommendationTitleString, index: 1)

        numberOfFollowers = list.numberOfFollowers

        if let relationship = list.isUserFollowing {
            followerRelationship = relationship ? .following : .notFollowing
        } else {
            followerRelationship = .notFollowing
        }
    }
}

extension ListTableHeaderView: ListSegmentedControlDelegate {
    func didSelectItemAtIndex(index: Int) {
        if index == 0 {
            print("\nDid tap entries tab\n")

            delegate?.entriesButtonTapped()
        } else if index == 1 {
            print("\nDid tap suggestions tab\n")
            delegate?.suggestionsButtonTapped()
        }
    }
}
