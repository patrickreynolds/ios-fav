import UIKit

import Cartography

protocol TopListViewDelegate {
    func didSelectUser(user: User)
    func didSelectList(list: List)
    func didSelectItem(item: Item, list: List)
}

class TopListView: UIView {

    private var dependencyGraph: DependencyGraphType?

    var delegate: TopListViewDelegate?

    private var list: List? = nil {
        didSet {
            guard let list = list else { return }

            updateContent(list: list)
        }
    }

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        let imageViewDiameter: CGFloat = 48

        imageView.layer.cornerRadius = imageViewDiameter / 2
        imageView.layer.masksToBounds = true

        imageView.backgroundColor = FaveColors.Black20

        constrain(imageView) { imageView in
            imageView.height == imageViewDiameter
            imageView.width == imageViewDiameter
        }

        return imageView
    }()

    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .center,
                          numberOfLines: 1)

        return label
    }()

    private lazy var ownerLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black70,
                          textAlignment: .center,
                          numberOfLines: 1)

        return label
    }()

    private lazy var photoStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.backgroundColor = FaveColors.White
        stackView.removeAllArrangedSubviews()

        var photos: [FavePhotoType] = []

        self.list?.items.forEach { item in
            if let contextualItem = item.contextualItem as? GoogleItemType {

                let itemPhotos: [FavePhotoType] = !contextualItem.savedPhotos.isEmpty ? contextualItem.savedPhotos : Array(contextualItem.photos.prefix(5))

                if let photo = itemPhotos.first {
                    photos.append(photo)
                }
            }
        }

        let photoImageViews: [UIImageView] = Array(photos).prefix(3).map({ photo in
            let imageView = UIImageView.init(frame: .zero)

            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            imageView.contentMode = UIImageView.ContentMode.scaleAspectFill
            imageView.backgroundColor = FaveColors.Black20

            FaveImageCache.downloadImage(url: photo.url) { downloadedImageURL, image in
                guard let image = image else {
                    DispatchQueue.main.async {
                        imageView.backgroundColor = FaveColors.Black20
                    }

                    return
                }

                DispatchQueue.main.async {
                    if downloadedImageURL == photo.url.absoluteString {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    } else {
                        print("")
                    }
                }
            }

            return imageView
        })

        photoImageViews.forEach { imageView in
            stackView.addArrangedSubview(imageView)
        }

        stackView.spacing = 4
        stackView.distribution = UIStackView.Distribution.fillEqually

        return stackView
    }()

    private lazy var roundedBorderView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.White

        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        view.layer.borderColor = FaveColors.Black20.cgColor
        view.layer.borderWidth = 0.5

        return view
    }()

    private lazy var seeAllItemsButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)

        let attributedTitle = NSAttributedString(string: "View list",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        button.addTarget(self, action: #selector(didTapListButton), for: .touchUpInside)

        return button
    }()

    init(list: List) {
        self.list = list

        super.init(frame: .zero)

        addSubview(roundedBorderView)
        constrainToSuperview(roundedBorderView)

        roundedBorderView.addSubview(profileImageView)
        roundedBorderView.addSubview(titleLabel)
        roundedBorderView.addSubview(ownerLabel)
        roundedBorderView.addSubview(photoStackView)
        roundedBorderView.addSubview(seeAllItemsButton)

        constrain(self) { view in
            view.height == UIScreen.main.bounds.width - 16
            view.width == UIScreen.main.bounds.width - 64
        }

        constrain(profileImageView, roundedBorderView) { profileImageView, view in
            profileImageView.centerX == view.centerX
            profileImageView.top == view.top + 24
        }

        constrain(titleLabel, profileImageView, roundedBorderView) { titleLabel, profileImageView, view in
            titleLabel.top == profileImageView.bottom + 12
            titleLabel.left == view.left + 16
            titleLabel.right == view.right - 16
        }

        constrain(ownerLabel, titleLabel, roundedBorderView) { ownerLabel, titleLabel, view in
            ownerLabel.top == titleLabel.bottom
            ownerLabel.left == view.left + 16
            ownerLabel.right == view.right - 16
        }

        constrain(photoStackView, ownerLabel, roundedBorderView) { photoStackView, ownerLabel, view in
            photoStackView.top == ownerLabel.bottom + 24 ~ UILayoutPriority.defaultHigh
            photoStackView.left == view.left + 4
            photoStackView.right == view.right - 4
            photoStackView.height == ((UIScreen.main.bounds.width - 64 - 16) / 3)
        }

        constrain(seeAllItemsButton, photoStackView, roundedBorderView) { button, stackView, view in
            button.top == stackView.bottom + 24 ~ UILayoutPriority.defaultLow
            button.centerX == view.centerX
            button.bottom == view.bottom - 24
        }

        updateContent(list: list)

        setNeedsLayout()
        layoutIfNeeded()

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.08
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTapListButton(sender: UIButton!) {
        if let list = list {
            delegate?.didSelectList(list: list)
        }
    }

    func updateContent(list: List) {
        profileImageView.image = UIImage(base64String: list.owner.profilePicture)
        titleLabel.text = list.title
        ownerLabel.text = "by \(list.owner.firstName) \(list.owner.lastName)"
    }
}
