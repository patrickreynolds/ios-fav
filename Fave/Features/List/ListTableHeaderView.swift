import Foundation
import UIKit

import Cartography

protocol ListTableHeaderViewDelegate {
    func entriesButtonTapped()
    func suggestionsButtonTapped()
}

class ListTableHeaderView: UIView {
    struct Constants {
        static let HorizontalSpacing: CGFloat = 0
    }

    var list: List
    var delegate: ListTableHeaderViewDelegate?
    let dependencyGraph: DependencyGraphType

    var followerCountLabelText = "" {
        didSet {
            followerCountLabel.text = followerCountLabelText
        }
    }

    private lazy var relationshipButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.addTarget(self, action: #selector(followList), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)

        let attributedTitle = NSAttributedString(string: "Follow",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var entriesButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(entriesButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        let attributedTitle = NSAttributedString(string: "\(self.list.numberOfItems) Entries",
            font: FaveFont(style: .small, weight: .semiBold).font,
            textColor: UIColor.white)

        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var suggestionsButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(suggestionsButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = FaveColors.White
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        let attributedTitle = NSAttributedString(string: "\(self.list.numberOfSuggestions) Suggestions",
            font: FaveFont(style: .small, weight: .semiBold).font,
            textColor: FaveColors.Accent)

        button.setAttributedTitle(attributedTitle, for: .normal)


        return button
    }()

    private lazy var toggleListView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        view.addSubview(entriesButton)
        view.addSubview(suggestionsButton)

        constrain(entriesButton, view) { button, view in
            button.top == view.top + 16
            button.left == view.left + 16
            button.bottom == view.bottom - 8
        }

        constrain(suggestionsButton, entriesButton, view) { recommendationsButton, entriesButton, view in
            recommendationsButton.top == entriesButton.top
            recommendationsButton.left == entriesButton.right + 8
            recommendationsButton.bottom == entriesButton.bottom
        }

        return view
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

    let followerCountLabel = Label(text: "0 Followers",
        font: FaveFont(style: .h5, weight: .regular),
        textColor: FaveColors.Black90,
        textAlignment: .left,
        numberOfLines: 0)

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

    init(dependencyGraph: DependencyGraphType, list: List) {
        self.dependencyGraph = dependencyGraph
        self.list = list

        super.init(frame: CGRect.zero)

        isUserInteractionEnabled = true

        backgroundColor = FaveColors.White

        addSubview(titleLabel)
        addSubview(ownerView)
        addSubview(listDescriptionLabel)
        addSubview(relationshipStackView)
        addSubview(toggleListView)

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

        constrain(toggleListView, relationshipStackView, self) { toggleListView, relationshipStackView, view in
            toggleListView.top == relationshipStackView.bottom + 16
            toggleListView.right == view.right
            toggleListView.bottom == view.bottom
            toggleListView.left == view.left
            toggleListView.height == 56
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func followList(sender: UIButton!) {
        print("\nFollow List Button Tapped\n")
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
        let attributedTitle = NSAttributedString(string: "\(listItems.count) Entries",
            font: FaveFont(style: .small, weight: .semiBold).font,
            textColor: UIColor.white)

        entriesButton.setAttributedTitle(attributedTitle, for: .normal)

        followerCountLabelText = "\(list.numberOfFollowers) Followers"
    }
}
