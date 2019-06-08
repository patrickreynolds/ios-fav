import Foundation
import UIKit

import Cartography

protocol EntryTableViewCellDelegate {
    func faveItemButtonTapped(item: Item, from: Bool, to: Bool)
    func shareItemButtonTapped(item: Item)
}

class EntryTableViewCell: UITableViewCell {

    var item: Item?
    var list: List?
    var currentUser: User?
    var mySavedItem: Item?
    var delegate: EntryTableViewCellDelegate?

    var itemIsAlreadySavedConstraint: NSLayoutConstraint?
    var itemIsNotAlreadySavedConstraint: NSLayoutConstraint?

    var itemIsSavedByUser = false
    let faveActionIcon = UIImageView.init(frame: .zero)
    let faveActionLabel = Label.init(text: "Save", font: FaveFont(style: .small, weight: .semiBold), textColor: FaveColors.Black70, textAlignment: .center, numberOfLines: 1)

    var faveScoreLabel = Label(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.FaveOrange,
                               textAlignment: .left,
                               numberOfLines: 1)

    var googleScoreLabel = Label(text: "",
                                 font: FaveFont(style: .h5, weight: .regular),
                                 textColor: FaveColors.FaveOrange,
                                 textAlignment: .left,
                                 numberOfLines: 1)

    var yelpScoreLabel = Label(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.FaveOrange,
                               textAlignment: .left,
                               numberOfLines: 1)


    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                           font: FaveFont(style: .h4, weight: .semiBold),
                           textColor: FaveColors.Black90,
                           textAlignment: .left,
                           numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black60,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var navigationIndicatorImageView: UIView = {
        let imageView = UIImageView(frame: CGRect.zero)

        imageView.image = UIImage(named: "icon-small-chevron")
        imageView.tintColor = FaveColors.Black60

        return imageView
    }()

    private lazy var faveItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Black20
        button.addTarget(self, action: #selector(faveItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Save",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Accent)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var faveActionView: UIView = {
        let view = UIView(frame: CGRect.zero)
        let actionContentView = UIView.init(frame: .zero)

        let icon = faveActionIcon
        icon.image = UIImage.init(named: "icon-fave-not-faved")
        icon.tintColor = FaveColors.Black60

        let label = faveActionLabel

        actionContentView.addSubview(icon)
        actionContentView.addSubview(label)

        constrain(icon, label, actionContentView) { icon, label, view in
            icon.top == view.top + 4
            icon.bottom == view.bottom - 4
            icon.left == view.left

            label.centerY == icon.centerY + 2
            label.left == icon.right + 8
            label.right == view.right

            icon.width == 20
            icon.height == 20
        }

        view.addSubview(actionContentView)

        constrain(actionContentView, view) { contentView, view in
            contentView.top == view.top + 8
            contentView.centerX == view.centerX
            contentView.bottom == view.bottom - 8
        }

        _ = view.tapped { _ in
            self.faveItemButtonTapped()
        }

        return view
    }()

    private lazy var shareActionView: UIView = {
        let view = UIView(frame: CGRect.zero)
        let actionContentView = UIView.init(frame: .zero)

        let shareIcon = UIImageView.init(frame: .zero)
        shareIcon.image = UIImage.init(named: "icon-share")
        shareIcon.tintColor = FaveColors.Black60

        let shareLabel = Label.init(text: "Share", font: FaveFont(style: .small, weight: .semiBold), textColor: FaveColors.Black70, textAlignment: .center, numberOfLines: 1)

        actionContentView.addSubview(shareIcon)
        actionContentView.addSubview(shareLabel)

        constrain(shareIcon, shareLabel, actionContentView) { shareIcon, shareLabel, view in
            shareIcon.top == view.top + 4
            shareIcon.bottom == view.bottom - 4
            shareIcon.left == view.left

            shareLabel.centerY == shareIcon.centerY + 2
            shareLabel.left == shareIcon.right + 8
            shareLabel.right == view.right

            shareIcon.width == 20
            shareIcon.height == 20
        }

        view.addSubview(actionContentView)

        constrain(actionContentView, view) { contentView, view in
            contentView.top == view.top + 8
            contentView.centerX == view.centerX
            contentView.bottom == view.bottom - 8
        }

        _ = view.tapped { _ in
            self.shareItemButtonTapped()
        }

        return view
    }()

    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)

        stackView.addArrangedSubview(faveActionView)
        stackView.addArrangedSubview(shareActionView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 16.0

        return stackView
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    private lazy var savedItemContextView: SavedItemContextView = {
        let view = SavedItemContextView()

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(actionStackView)

        contentView.addSubview(dividerView)
        contentView.addSubview(borderView)
        contentView.addSubview(savedItemContextView)

        constrain(savedItemContextView, titleLabel, contentView) { savedItemContextView, titleLabel, view in
            itemIsAlreadySavedConstraint = savedItemContextView.top == view.top + 16
            savedItemContextView.right == view.right - 16
            savedItemContextView.bottom == titleLabel.top - 4
            savedItemContextView.left == view.left + 16
        }

        constrain(titleLabel, contentView) { label, view in
            itemIsNotAlreadySavedConstraint = label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(subtitleLabel, titleLabel) { subtitleLabel, titleLabel in
            subtitleLabel.top == titleLabel.bottom + 4
            subtitleLabel.right == titleLabel.right
            subtitleLabel.left == titleLabel.left
        }

        constrain(dividerView, subtitleLabel, actionStackView, contentView) { dividerView, subtitleLabel, actionStackView, view in
            dividerView.top == subtitleLabel.bottom + 16
            dividerView.right == view.right - 16
            dividerView.bottom == actionStackView.top - 8
            dividerView.left == view.left + 16
            dividerView.height == 1
        }

        constrain(actionStackView, borderView, contentView) { actionStackView, borderView, contentView in
            actionStackView.right == contentView.right - 16
            actionStackView.bottom == borderView.top - 8
            actionStackView.left == contentView.left + 16
        }

        constrain(borderView, contentView) { borderView, view in
            borderView.left == view.left
            borderView.right == view.right
            borderView.bottom == view.bottom
            borderView.height == 4
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item, currentUser: User?, list: List, mySavedItem: Item?) {
        self.item = item
        self.list = list
        self.mySavedItem = mySavedItem
        self.currentUser = currentUser

        itemIsSavedByUser = item.isSaved ?? false

        updateSavedItemContext(item: item)

        titleLabel.text = item.contextualItem.name
        subtitleLabel.text = item.note
        faveScoreLabel.text = "\(item.numberOfFaves)"

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        if item.note.isEmpty {
            var keywords = ""
            var counter = 0
            googleItem.keywords?.forEach { keyword in
                if counter < 3 {
                    keywords += "\(keyword), "
                    counter += 1
                }
            }

            keywords = String(keywords.dropLast(2))

            subtitleLabel.text = keywords
        }
    }

    private func updateSavedItemContext(item: Item) {
        guard let user = currentUser, let list = list, let mySavedItem = mySavedItem else {
            savedItemContextView.alpha = 0
            itemIsNotAlreadySavedConstraint?.isActive = true
            itemIsAlreadySavedConstraint?.isActive = false

            return
        }

        let isSameItem = item.dataId == mySavedItem.dataId
        let notMyList = list.owner.id != user.id

        if itemIsSavedByUser && isSameItem && notMyList {
            UIView.animate(withDuration: 0.15) {
                self.savedItemContextView.alpha = 1
            }

            itemIsAlreadySavedConstraint?.isActive = true
            itemIsNotAlreadySavedConstraint?.isActive = false
            savedItemContextView.setListTitle(title: mySavedItem.listTitle)
        } else {
            savedItemContextView.alpha = 0
            itemIsNotAlreadySavedConstraint?.isActive = true
            itemIsAlreadySavedConstraint?.isActive = false
        }
    }

    @objc func faveItemButtonTapped() {
        guard let item = item else {
            return
        }

        delegate?.faveItemButtonTapped(item: item, from: itemIsSavedByUser, to: !itemIsSavedByUser)

        itemIsSavedByUser = !itemIsSavedByUser

        updateSavedItemContext(item: item)
    }

    @objc func shareItemButtonTapped() {
        guard let item = item else {
            return
        }

        delegate?.shareItemButtonTapped(item: item)
    }
}
