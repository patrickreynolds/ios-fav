import UIKit

import Cartography

enum OnboardingWelcomePageContentType {
    case createList
    case shareRecommendation
    case discoverNewPlace

    var title: String {
        switch self {
        case .createList:
            return "Create lists"
        case .shareRecommendation:
            return "Share recommendations"
        case .discoverNewPlace:
            return "Discover new places"
        }
    }

    var subtitle: String {
        switch self {
        case .createList:
            return "Create lists of all your \nfavorite spots in one place."
        case .shareRecommendation:
            return "Send and receive trusted \nrecommendations from friends."
        case .discoverNewPlace:
            return "See where everyone’s going and \nwhat they’re saying about it."
        }
    }

    var image: UIImage? {
        switch self {
        case .createList:
            return UIImage.init()
        case .shareRecommendation:
            return UIImage.init()
        case .discoverNewPlace:
            return UIImage.init()
        }
    }

    private var imageName: String {
        switch self {
        case .createList:
            return "create-list"
        case .shareRecommendation:
            return "share-recommendations"
        case .discoverNewPlace:
            return "discover-new-places"
        }
    }

    var color: UIColor {
        switch self {
        case .createList:
            return FaveColors.HJCerulean
        case .shareRecommendation:
            return FaveColors.HJSilverTree
        case .discoverNewPlace:
            return FaveColors.HJTorchRed
        }
    }
}

class OnboardingWelcomePage: UIView {

    let type: OnboardingWelcomePageContentType

    private lazy var title: Label = {
        let label = Label(text: type.title,
                          font: FaveFont(style: .h3, weight: .bold) ,
                          textColor: type.color,
                          textAlignment: .center,
                          numberOfLines: 0)

        return label
    }()

    private lazy var subtitle: Label = {
        let label = Label(text: type.subtitle,
                          font: FaveFont(style: FaveDeviceSize.isIPhone5sOrLess() ? .h5 : .h4, weight: .regular) ,
                          textColor: type.color,
                          textAlignment: .center,
                          numberOfLines: 0)

        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        imageView.backgroundColor = FaveColors.Black20
        imageView.layer.cornerRadius = 6

        return imageView
    }()

    init(type: OnboardingWelcomePageContentType) {
        self.type = type

        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.White

        addSubview(title)
        addSubview(subtitle)
        addSubview(imageView)

        constrain(self) { view in
            view.width == UIScreen.main.bounds.width
        }

        constrain(title, self) { title, view in
            let titleTopMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                titleTopMargin = 24
            } else {
                titleTopMargin = 48
            }

            title.top == view.top + titleTopMargin
            title.right == view.right - 16
            title.left == view.left + 16
        }

        constrain(subtitle, title, self) { subtitle, title, view in
            let subtitleTopMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                subtitleTopMargin = 8
            } else {
                subtitleTopMargin = 16
            }

            subtitle.top == title.bottom + subtitleTopMargin
            subtitle.right == view.right - 16
            subtitle.left == view.left + 16
        }

        constrain(imageView, subtitle, self) { imageView, subtitle, view in
            let imageViewTopMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() {
                imageViewTopMargin = 24
            } else {
                imageViewTopMargin = 32
            }

            imageView.top == subtitle.bottom + imageViewTopMargin
            imageView.right == view.right - 16
            imageView.left == view.left + 16
            imageView.height == view.width

            imageView.bottom == view.bottom ~ UILayoutPriority(100)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
