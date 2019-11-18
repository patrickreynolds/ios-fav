import UIKit

import Cartography

protocol ItemTableHeaderViewDelegate {
    func saveItemButtonTapped(item: Item, from: Bool, to: Bool)
    func didTapSavedByOthersLabel(item: Item)
}

class ItemTableHeaderView: UIView {

    var currentUser: User?
    var mySavedItem: Item?

    var list: List?

    var item: Item {
        didSet {
            itemIsSavedByUser = item.isSaved ?? false

            titleLabel.text = self.item.contextualItem.name
            itemNoteLabel.text = self.item.note
            savedByOthersCount = self.item.numberOfFaves
        }
    }

    var savedByOthersCount: Int = 0 {
        didSet {
            let savedByAttributedText: NSMutableAttributedString = NSMutableAttributedString()

            let primaryAttributes: [NSAttributedString.Key : Any]? = [
                NSAttributedString.Key.font: FaveFont(style: .h5, weight: .semiBold).font,
                NSAttributedString.Key.foregroundColor: FaveColors.Black90
            ]

            let standardAttributes: [NSAttributedString.Key : Any]? = [
                NSAttributedString.Key.font: FaveFont(style: .h5, weight: .regular).font,
                NSAttributedString.Key.foregroundColor: FaveColors.Black90
            ]

            let savedByText = NSAttributedString(string: "Saved by ", attributes: standardAttributes)

            let savedByOthersCountText = NSAttributedString(string: "\(savedByOthersCount)", attributes: savedByOthersCount == 0 ? standardAttributes : primaryAttributes)

            let othersString = savedByOthersCount == 1 ? " other" : " others"
            let othersText = NSAttributedString(string: "\(othersString)", attributes: standardAttributes)

            savedByAttributedText.append(savedByText)
            savedByAttributedText.append(savedByOthersCountText)
            savedByAttributedText.append(othersText)

            savedByOthersLabel.attributedText = savedByAttributedText
        }
    }

    var delegate: ItemTableHeaderViewDelegate?

    var userHasSavedThisItemConstraint: NSLayoutConstraint?
    var userHasNotSavedThisItemConstraint: NSLayoutConstraint?

    var itemIsSavedByUser: Bool = false {
        didSet {
            if itemIsSavedByUser {
                faveItemButton.layer.borderColor = FaveColors.Black30.cgColor
                faveItemButton.layer.borderWidth = 1
                faveItemButton.backgroundColor = FaveColors.White
                let attributedTitle = NSAttributedString(string: "Saved",
                                                         font: FaveFont(style: .small, weight: .semiBold).font,
                                                         textColor: FaveColors.Black90)
                faveItemButton.setAttributedTitle(attributedTitle, for: .normal)
            } else {
                faveItemButton.layer.borderWidth = 0
                faveItemButton.backgroundColor = FaveColors.Accent
                let attributedTitle = NSAttributedString(string: "Save",
                                                         font: FaveFont(style: .small, weight: .semiBold).font,
                                                         textColor: FaveColors.White)
                faveItemButton.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
    }

    private lazy var faveItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.addTarget(self, action: #selector(faveItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.0
        button.layer.borderColor = FaveColors.Black50.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Save",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var titleLabel: Label = {
        let label = Label(text: self.item.contextualItem.name,
                          font: FaveFont(style: .h3, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        return label
    }()

    private lazy var itemNoteLabel: Label = {
        let label = Label(text: self.item.note,
                          font: FaveFont(style: .h5, weight: .regular) ,
                          textColor: FaveColors.Black70,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var savedByOthersLabel: Label = {
        let labelText = self.item.numberOfFaves == 1 ? "Saved by \(self.item.numberOfFaves) other" : "Saved by \(self.item.numberOfFaves) others"

        let label = Label(text: labelText,
                          font: FaveFont(style: .h5, weight: .regular) ,
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        _ = label.tapped({ tapped in
            self.delegate?.didTapSavedByOthersLabel(item: self.item)
        })

        label.isUserInteractionEnabled = false

        return label
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 8
        }

        return view
    }()

    private lazy var savedItemContextView: SavedItemContextView = {
        let view = SavedItemContextView()

        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        return view
    }()

    init(item: Item, list: List?) {
        self.item = item
        self.list = list

        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.White

        isUserInteractionEnabled = true

        addSubview(savedItemContextView)
        addSubview(titleLabel)
        addSubview(itemNoteLabel)
        addSubview(savedByOthersLabel)
        addSubview(faveItemButton)
        addSubview(dividerView)

        constrain(titleLabel, savedItemContextView, self) { label, savedItemContextView, view in
            userHasNotSavedThisItemConstraint = label.top == view.top + 16
            userHasSavedThisItemConstraint = label.top == savedItemContextView.bottom + 8

            savedItemContextView.top == view.top + 12
            savedItemContextView.right == view.right - 16
            savedItemContextView.left == label.left

            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(itemNoteLabel, titleLabel, self) { itemNoteLabel, titleLabel, view in
            itemNoteLabel.top == titleLabel.bottom + 8
            itemNoteLabel.right == titleLabel.right
            itemNoteLabel.left == titleLabel.left
        }

        constrain(itemNoteLabel, savedByOthersLabel, self) { noteLabel, savedByOthersLabel, view in
            savedByOthersLabel.top == noteLabel.bottom + 16
            savedByOthersLabel.right == view.right - 16
            savedByOthersLabel.left == view.left + 16
        }

        if let user = currentUser, item.addedBy.id == user.id {
            constrain(savedByOthersLabel, dividerView) { savedByOthersLabel, dividerView in
                savedByOthersLabel.bottom == dividerView.top - 16
            }
        } else {
            constrain(faveItemButton, savedByOthersLabel, dividerView, self) { stackView, savedByOthersLabel, dividerView, view in
                stackView.top == savedByOthersLabel.bottom + 16
                stackView.right == view.right - 16
                stackView.bottom == dividerView.top - 16
                stackView.left == view.left + 16
            }
        }

        constrain(dividerView, self) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left
        }

        updateSavedItemContext(item: item)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeader(item: Item, user: User?, mySavedItem: Item?) {
        self.currentUser = user
        self.item = item
        self.mySavedItem = mySavedItem

        updateSavedItemContext(item: item)
    }

    private func updateSavedItemContext(item: Item) {
        guard let user = currentUser, let mySavedItem = mySavedItem else {
            savedItemContextView.alpha = 0
            userHasNotSavedThisItemConstraint?.isActive = true
            userHasSavedThisItemConstraint?.isActive = false
            itemIsSavedByUser = false

            return
        }

        //        let myItem = item.owner.id == user.id

        let notPresentList = (list?.id != mySavedItem.listId)
        let isSameItem = item.dataId == mySavedItem.dataId

        if (itemIsSavedByUser && isSameItem && notPresentList) {
            savedItemContextView.setListTitle(title: mySavedItem.listTitle)

            self.userHasSavedThisItemConstraint?.isActive = true
            self.userHasNotSavedThisItemConstraint?.isActive = false

            UIView.animate(withDuration: 0.15) {
                self.savedItemContextView.alpha = 1
            }
        } else {
            self.userHasNotSavedThisItemConstraint?.isActive = true
            self.userHasSavedThisItemConstraint?.isActive = false

            UIView.animate(withDuration: 0.15) {
                self.savedItemContextView.alpha = 0
            }
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @objc func faveItemButtonTapped(sender: UIButton!) {
        delegate?.saveItemButtonTapped(item: item, from: itemIsSavedByUser, to: !itemIsSavedByUser)

        itemIsSavedByUser = !itemIsSavedByUser

        updateSavedItemContext(item: item)
    }

    func updateContent(item: Item) {
        self.item = item
    }
}
