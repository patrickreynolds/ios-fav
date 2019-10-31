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
            return UIImage(named: self.imageName)
        case .shareRecommendation:
            return UIImage(named: self.imageName)
        case .discoverNewPlace:
            return UIImage(named: self.imageName)
        }
    }

    private var imageName: String {
        switch self {
        case .createList:
            return "Welcome Illustration - Create Lists"
        case .shareRecommendation:
            return "Welcome Illustration - Share Recommendations"
        case .discoverNewPlace:
            return "Welcome Illustration - Discover"
        }
    }

    var color: UIColor {
        switch self {
        case .createList:
            return FaveColors.HJCerulean
        case .shareRecommendation:
            return FaveColors.HJSilverTree
        case .discoverNewPlace:
            return FaveColors.HJTorchRed.withAlphaComponent(0.80)
        }
    }
}

class OnboardingWelcomePageView: UIView {

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

        imageView.backgroundColor = FaveColors.White
        imageView.contentMode = .scaleAspectFit
        imageView.image = type.image
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)


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
                titleTopMargin = 24
            }

            title.top == view.top + titleTopMargin
            title.right == view.right - 16
            title.left == view.left + 16
        }

        constrain(subtitle, title, self) { subtitle, title, view in
            let subtitleTopMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() || FaveDeviceSize.isIPhone6() {
                subtitleTopMargin = 8
            } else {
                subtitleTopMargin = 12
            }

            subtitle.top == title.bottom + subtitleTopMargin
            subtitle.right == view.right - 16
            subtitle.left == view.left + 16
        }

        constrain(imageView, subtitle, self) { imageView, subtitle, view in
            let imageViewTopMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() || FaveDeviceSize.isIPhone6() {
                imageViewTopMargin = 16
            } else {
                imageViewTopMargin = 32
            }

            imageView.top == subtitle.bottom + imageViewTopMargin
            imageView.right == view.right
            imageView.left == view.left
            imageView.height == view.width

            imageView.bottom == view.bottom ~ UILayoutPriority(100)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
