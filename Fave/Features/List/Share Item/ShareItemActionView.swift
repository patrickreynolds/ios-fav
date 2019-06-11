import UIKit
import Cartography

protocol ShareItemActionViewDelegate {
    func addToListActionTapped()
    func copyLinkActionTapped()
    func shareToActionTapped()
}

enum ShareItemActionType {
    case addToList
    case copyLink
    case shareTo

    var title: String {
        switch self {
        case .addToList:
            return "Add to list"
        case .copyLink:
            return "Copy link"
        case .shareTo:
            return "Share to..."
        }
    }

    var icon: UIImage? {
        let image: UIImage?

        switch self {
        case .addToList:
            image = UIImage.init(named: "icon-add")?.withRenderingMode(.alwaysTemplate)
        case .copyLink:
            image = UIImage.init(named: "icon-link")?.withRenderingMode(.alwaysTemplate)
        case .shareTo:
            image = UIImage.init(named: "icon-share")?.withRenderingMode(.alwaysTemplate)
        }

        return image
    }
}

class ShareItemActionView: UIView {

    let type: ShareItemActionType

    var delegate: ShareItemActionViewDelegate?

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        let size: CGFloat = 24

        imageView.backgroundColor = FaveColors.White
        imageView.image = self.type.icon
        imageView.tintColor = FaveColors.Black90

        constrain(imageView) { imageView in
            imageView.width == size
            imageView.height == size
        }

        return imageView
    }()

    private lazy var iconView: UIView = {
        let view = UIView.init(frame: .zero)

        let size: CGFloat = 56

        view.backgroundColor = FaveColors.White
        view.layer.borderColor = FaveColors.Black30.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = size / 2
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        view.addSubview(iconImageView)

        constrain(iconImageView, view) { iconImageView, view in
            iconImageView.centerY == view.centerY
            iconImageView.centerX == view.centerX
        }

        constrain(view) { view in
            view.height == size
            view.width == size
        }

        return view
    }()

    private lazy var titleLabel: Label = {
        let titleLabel = Label(text: self.type.title,
                             font: FaveFont(style: .small, weight: .regular),
                             textColor: FaveColors.Black90,
                             textAlignment: .center,
                             numberOfLines: 0)

        return titleLabel
    }()

    private lazy var actionViewContent: UIView = {
        let view = UIView.init(frame: .zero)

        view.addSubview(iconView)
        view.addSubview(titleLabel)

        constrain(iconView, titleLabel, view) { iconView, titleLabel, view in
            iconView.top == view.top + 12
            iconView.centerX == view.centerX

            titleLabel.top == iconView.bottom + 4
            titleLabel.centerX == view.centerX
            titleLabel.bottom == view.bottom - 12
        }

        return view
    }()

    init(shareItemActionType type: ShareItemActionType) {
        self.type = type

        super.init(frame: .zero)

        backgroundColor = FaveColors.Black05

        addSubview(actionViewContent)

        constrainToSuperview(actionViewContent)

        _ = tapped { _ in
            switch self.type {
            case .addToList:
                self.delegate?.addToListActionTapped()
            case .copyLink:
                self.delegate?.copyLinkActionTapped()
            case .shareTo:
                self.delegate?.shareToActionTapped()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
