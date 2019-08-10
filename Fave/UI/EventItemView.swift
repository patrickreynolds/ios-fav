import UIKit

import Cartography

class EventItemView: UIView {

    var dependencyGraph: DependencyGraphType?

    var imageViewHeightConstraint: NSLayoutConstraint?

    private lazy var titleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 2)

        label.contentHuggingPriority = .defaultHigh
        label.contentCompressionResistancePriority = .defaultHigh

        return label
    }()


    private lazy var subtitleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black70,
                               textAlignment: .left,
                               numberOfLines: 2)

        label.contentHuggingPriority = .defaultHigh
        label.contentCompressionResistancePriority = .defaultHigh

        return label
    }()

    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        imageView.backgroundColor = FaveColors.Black20

        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true

        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)

        return imageView
    }()

    init(item: String = "", list: String = "", dependencyGraph: DependencyGraphType?) {
        self.dependencyGraph = dependencyGraph

        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.White
        layer.borderColor = FaveColors.Black30.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
        layer.masksToBounds = true
        clipsToBounds = true

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(previewImageView)

        setContentHuggingPriority(.defaultHigh, for: .vertical)

        constrain(titleLabel, subtitleLabel, previewImageView, self) { titleLabel, subtitleLabel, previewImageView, view in
            titleLabel.top == view.top + 16
            titleLabel.right == view.right - 16
            titleLabel.left == previewImageView.right + 16

            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.right == titleLabel.right
            subtitleLabel.bottom == view.bottom - 16
            subtitleLabel.left == titleLabel.left

            previewImageView.top == view.top
            previewImageView.bottom == view.bottom
            previewImageView.left == view.left
            previewImageView.width == 96
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(dependencyGraph: DependencyGraphType, withEvent event: FeedEvent) {
        self.dependencyGraph = dependencyGraph

        titleLabel.text = event.item.title
        subtitleLabel.text = event.list.title

        previewImageView.image = nil

        // Removing in favor of variable EventItemView heights via huggingPriority and compressionResistance
//        if imageViewHeightConstraint == nil && previewImageView.image != nil {
//            let currentHeight = previewImageView.frame.size.height
//
//            constrain(previewImageView) { previewImageView in
//                imageViewHeightConstraint = previewImageView.height == currentHeight
//            }
//        }

        if let googleItem = event.item.contextualItem as? GoogleItemType,
            let photo = googleItem.photos.first,
            let dependencyGraph = self.dependencyGraph,
            let googlePhotoUrl = photo.photoUrl(googleApiKey: dependencyGraph.appConfiguration.googleAPIKey, googlePhotoReference: photo.googlePhotoReference, maxHeight: 400, maxWidth: 400) {

            FaveImageCache.downloadImage(url: googlePhotoUrl) { image in
                UIView.transition(with: self.previewImageView, duration: 0.15, options: .transitionCrossDissolve, animations: {

                    guard let image = image else {
                        self.previewImageView.backgroundColor = FaveColors.Black20

                        return
                    }

                    self.previewImageView.image = image

                }, completion: nil)
            }
//                DispatchQueue.global().async {
//                    do {
//                        let data = try Data(contentsOf: googlePhotoUrl)
//
//                        DispatchQueue.main.async {
//                            UIView.transition(with: self.previewImageView, duration: 0.15, options: .transitionCrossDissolve, animations: {
//                                self.previewImageView.image = UIImage(data: data)
//                            }, completion: nil)
//                        }
//                        return
//                    } catch {
//                        print(error)
//                    }
//                }
        }
    }
}
