import UIKit

import Cartography

protocol EntryTableViewCellDelegate {
    func faveItemButtonTapped(item: Item, from: Bool, to: Bool)
    func shareItemButtonTapped(item: Item)
    func photoTapped(item: Item, list: List?)
    func dismissButtonTapped(item: Item)
    func addToListButtonTapped(item: Item, autoMerge: Bool)
    func didTapOwnerView(owner: User)
}

class EntryTableViewCell: UITableViewCell {

    var dependencyGraph: DependencyGraphType?
    var item: Item?
    var list: List?
    var currentUser: User?
    var mySavedItem: Item?
    var delegate: EntryTableViewCellDelegate?

    var itemIsAlreadySavedConstraint: NSLayoutConstraint?
    var itemIsNotAlreadySavedConstraint: NSLayoutConstraint?
    
    var isRecommendationConstraint: NSLayoutConstraint?
    var isNotRecommendationConstraint: NSLayoutConstraint?

    var returnPhotos: Bool = false

    var photos: [FavePhotoType] {
        guard let item = item, let googleItem = item.contextualItem as? GoogleItemType else {
            return []
        }

        let savedPhotos = googleItem.savedPhotos

        if !savedPhotos.isEmpty {
            return savedPhotos
        } else {
            return Array(googleItem.photos.prefix(5))
        }
    }

    var itemIsSavedByUser = false
    let faveActionIcon = UIImageView(frame: .zero)
    let faveActionLabel = Label(text: "Save", font: FaveFont(style: .small, weight: .semiBold), textColor: FaveColors.Black70, textAlignment: .center, numberOfLines: 1)

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
    
    let ownerNameLabel = Label(text: "",
        font: FaveFont(style: .h5, weight: .regular),
        textColor: FaveColors.Black90,
        textAlignment: .left,
        numberOfLines: 0)
    
    let ownerImageView = UIImageView(frame: .zero)

    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                           font: FaveFont(style: .h4, weight: .bold),
                           textColor: FaveColors.Black90,
                           textAlignment: .left,
                           numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black70,
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
        let actionContentView = UIView(frame: .zero)

        let icon = faveActionIcon
        icon.image = UIImage(named: "icon-fave-not-faved")
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

            icon.width == 16
            icon.height == 16
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
        let actionContentView = UIView(frame: .zero)

        let shareIcon = UIImageView(frame: .zero)
        shareIcon.image = UIImage(named: "icon-share")
        shareIcon.tintColor = FaveColors.Black60

        let shareLabel = Label(text: "Share", font: FaveFont(style: .small, weight: .semiBold), textColor: FaveColors.Black70, textAlignment: .center, numberOfLines: 1)

        actionContentView.addSubview(shareIcon)
        actionContentView.addSubview(shareLabel)

        constrain(shareIcon, shareLabel, actionContentView) { shareIcon, shareLabel, view in
            shareIcon.top == view.top + 4
            shareIcon.bottom == view.bottom - 4
            shareIcon.left == view.left

            shareLabel.centerY == shareIcon.centerY + 2
            shareLabel.left == shareIcon.right + 8
            shareLabel.right == view.right

            shareIcon.width == 16
            shareIcon.height == 16
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

    private lazy var addToListActionView: UIView = {
        let view = UIView(frame: .zero)

        let button = UIButton(frame: .zero)

        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        button.addTarget(self, action: #selector(addToListButtonTapped), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Add to list",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        view.addSubview(button)

        constrain(button, view) { button, view in
            button.top == view.top + 8
            button.bottom == view.bottom - 8
            button.left == view.left
            button.right == view.right
        }

        return view
    }()

    private lazy var addToSpecificListActionView: UIView = {
        let view = UIView(frame: .zero)

        let button = UIButton(frame: .zero)

        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        button.addTarget(self, action: #selector(addToSpecifcListButtonTapped), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Add to list",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        view.addSubview(button)

        constrain(button, view) { button, view in
            button.top == view.top + 8
            button.bottom == view.bottom - 8
            button.left == view.left
            button.right == view.right
        }

        return view
    }()

    private lazy var dismissActionView: UIView = {
        let view = UIView(frame: .zero)

        let button = UIButton(frame: .zero)

        button.backgroundColor = FaveColors.White
        button.layer.cornerRadius = 6
        button.layer.borderColor = FaveColors.Black40.cgColor
        button.layer.borderWidth = 1.0
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Dismiss",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Black80)
        button.setAttributedTitle(attributedTitle, for: .normal)

        view.addSubview(button)

        constrain(button, view) { button, view in
            button.top == view.top + 8
            button.bottom == view.bottom - 8
            button.left == view.left
            button.right == view.right
        }

        view.addSubview(button)

        constrain(button, view) { button, view in
            button.centerX == view.centerX
            button.centerY == view.centerY
        }

        return view
    }()

    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 16.0

        stackView.addArrangedSubview(faveActionView)
        stackView.addArrangedSubview(shareActionView)

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

    private lazy var cardShadowView: UIView = {
        let shadowView = UIView(frame: .zero)

        shadowView.backgroundColor = UIColor.clear

        shadowView.layer.shadowColor = FaveColors.Black100.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        shadowView.layer.shadowRadius = 6
        shadowView.layer.shadowOpacity = 0.08

        return shadowView
    }()

    private lazy var cardView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.White

        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        view.layer.borderColor = FaveColors.Black30.cgColor
        view.layer.borderWidth = 0.5

        return view
    }()

    private lazy var savedItemContextView: SavedItemContextView = {
        let view = SavedItemContextView()

        return view
    }()

    private lazy var ownerView: UIView = {
        let view = UIView(frame: .zero)

        let ownerImageViewDiameter: CGFloat = 24.0

        ownerImageView.layer.cornerRadius = ownerImageViewDiameter / 2
        ownerImageView.clipsToBounds = true
        ownerImageView.layer.masksToBounds = true
        
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


    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)

        return layout
    }()

    private lazy var photosCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = false
        collectionView.register(ItemGooglePhotoCollectionViewCell.self)
        collectionView.backgroundColor = FaveColors.White
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        contentView.addSubview(cardShadowView)

        cardShadowView.addSubview(cardView)

        constrainToSuperview(cardView)

        cardView.addSubview(titleLabel)
        cardView.addSubview(ownerView)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(photosCollectionView)
        cardView.addSubview(actionStackView)

        cardView.addSubview(borderView)
        cardView.addSubview(savedItemContextView)

        constrain(cardShadowView, contentView) { cardShadowView, contentView in
            cardShadowView.top == contentView.top + 16
            cardShadowView.right == contentView.right - 16
            cardShadowView.bottom == contentView.bottom
            cardShadowView.left == contentView.left + 16
        }

        constrain(savedItemContextView, titleLabel, cardView) { savedItemContextView, titleLabel, view in
            itemIsAlreadySavedConstraint = savedItemContextView.top == view.top + 16
            savedItemContextView.right == view.right - 16
            savedItemContextView.bottom == titleLabel.top - 2
            savedItemContextView.left == view.left + 16
        }

        constrain(titleLabel, cardView) { label, view in
            itemIsNotAlreadySavedConstraint = label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16
        }
        
        constrain(ownerView, titleLabel) { ownerView, titleLabel in
            ownerView.top == titleLabel.bottom + 8
            ownerView.right == titleLabel.right
            ownerView.left == titleLabel.left
        }

        constrain(subtitleLabel, titleLabel, ownerView) { subtitleLabel, titleLabel, ownerView in
            isRecommendationConstraint = subtitleLabel.top == ownerView.bottom + 8
            isNotRecommendationConstraint = subtitleLabel.top == titleLabel.bottom + 4
            subtitleLabel.right == titleLabel.right
            subtitleLabel.left == titleLabel.left
        }

        constrain(photosCollectionView, subtitleLabel, cardView) { collectionView, subtitleLabel, cardView in
            collectionView.top == subtitleLabel.bottom + 16
            collectionView.right == cardView.right
            collectionView.left == cardView.left
            collectionView.height == 80
        }

        constrain(actionStackView, borderView, photosCollectionView, cardView) { actionStackView, borderView, photosCollectionView, contentView in
            actionStackView.top == photosCollectionView.bottom + 16
            actionStackView.right == contentView.right - 16
            actionStackView.bottom == borderView.top - 8
            actionStackView.left == contentView.left + 16
        }

        constrain(borderView, cardView) { borderView, view in
            borderView.left == view.left
            borderView.right == view.right
            borderView.bottom == view.bottom
            borderView.height == 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        returnPhotos = false
//        photosCollectionView.reloadData()
    }

    func populate(dependencyGraph: DependencyGraphType, item: Item, list: List?, mySavedItem: Item?) {
        self.dependencyGraph = dependencyGraph
        self.item = item
        self.list = list
        self.mySavedItem = mySavedItem
        self.currentUser = dependencyGraph.storage.getUser()

        itemIsSavedByUser = item.isSaved ?? false

        updateSavedItemContext(item: item)

        titleLabel.text = item.contextualItem.name
        subtitleLabel.text = item.note
        faveScoreLabel.text = "\(item.numberOfFaves)"

        returnPhotos = true

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

        if let currentUser = dependencyGraph.storage.getUser(), item.isRecommendation {

            actionStackView.removeAllArrangedSubviews()

            if item.owner.id == currentUser.id {
                actionStackView.addArrangedSubview(addToListActionView)
                actionStackView.addArrangedSubview(dismissActionView)
            } else {
                actionStackView.addArrangedSubview(faveActionView)
                actionStackView.addArrangedSubview(shareActionView)
            }

            isRecommendationConstraint?.isActive = true
            isNotRecommendationConstraint?.isActive = false

            UIView.animate(withDuration: 0.15, animations: {
                self.layoutIfNeeded()
            }) { success in
                UIView.animate(withDuration: 0.15) {
                    self.ownerView.alpha = 1
                }
            }

            ownerNameLabel.text = "Recommended by \(item.addedBy.firstName) \(item.addedBy.lastName)"
            ownerImageView.image = UIImage(base64String: item.addedBy.profilePicture)

            _ = ownerView.tapped { tapped in
                self.delegate?.didTapOwnerView(owner: item.addedBy)
            }
        } else {
            isRecommendationConstraint?.isActive = false
            isNotRecommendationConstraint?.isActive = true

            UIView.animate(withDuration: 0.15, animations: {
                self.ownerView.alpha = 0
            }) { success in
                UIView.animate(withDuration: 0.15) {
                    self.layoutIfNeeded()
                }
            }

            actionStackView.removeAllArrangedSubviews()

            actionStackView.addArrangedSubview(faveActionView)
            actionStackView.addArrangedSubview(shareActionView)
        }

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        photosCollectionView.reloadData()
    }

    private func updateSavedItemContext(item: Item) {
        guard let mySavedItem = mySavedItem else {
            savedItemContextView.alpha = 0
            itemIsNotAlreadySavedConstraint?.isActive = true
            itemIsAlreadySavedConstraint?.isActive = false

            return
        }

//        let myItem = item.owner.id == user.id
////        let viewingRecommendation = item.isRecommendation && item.owner.id == user.id
//        let isSameItem = item.dataId == mySavedItem.dataId
        //        let myItem = item.owner.id == user.id

        let notPresentList = (list?.id != mySavedItem.listId)
        let isSameItem = item.dataId == mySavedItem.dataId

        if (itemIsSavedByUser && isSameItem && notPresentList) {
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


        faveActionIcon.image = itemIsSavedByUser ? UIImage(named: "icon-fave-faved") : UIImage(named: "icon-fave-not-faved")
        faveActionLabel.text = itemIsSavedByUser ? "Saved" : "Save"
    }

    @objc func faveItemButtonTapped() {
        guard let item = item else {
            return
        }

        performImpact(style: .light)

        delegate?.faveItemButtonTapped(item: item, from: itemIsSavedByUser, to: !itemIsSavedByUser)

        itemIsSavedByUser = !itemIsSavedByUser

        updateSavedItemContext(item: item)
    }

    @objc func shareItemButtonTapped() {
        guard let item = item else {
            return
        }

        performImpact(style: .light)

        delegate?.shareItemButtonTapped(item: item)
    }

    @objc func addToListButtonTapped(sender: UIButton!) {
        guard let item = item else {
            return
        }

        delegate?.addToListButtonTapped(item: item, autoMerge: false)
    }

    @objc func addToSpecifcListButtonTapped(sender: UIButton!) {
        guard let item = item else {
            return
        }

        delegate?.addToListButtonTapped(item: item, autoMerge: true)
    }

    @objc func dismissButtonTapped(sender: UIButton!) {
        guard let item = item else {
            return
        }

        delegate?.dismissButtonTapped(item: item)
    }
}

extension EntryTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = item else {
            return
        }

        delegate?.photoTapped(item: item, list: list)
    }
}

extension EntryTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if returnPhotos {
            return photos.count
        } else {
            return 10
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ItemGooglePhotoCollectionViewCell.self, indexPath: indexPath)

        let photo = photos[indexPath.row]

        cell.populate(photo: photo, showPhoto: returnPhotos)

        return cell
    }
}

extension EntryTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}
