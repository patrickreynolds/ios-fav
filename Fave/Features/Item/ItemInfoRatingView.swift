import Foundation
import UIKit

import Cartography

enum ItemInfoRatingType {
    case google
    case yelp

    var ratingImageString: String {
        switch self {
        case .google:
            return "data-type-google"
        case .yelp:
            return "data-type-yelp"
        }
    }

    var ratingImageView: UIImageView {
        let imageView = UIImageView(frame: .zero)

        constrain(imageView) { imageView in
            imageView.height == 20
            imageView.width == 20
        }

        imageView.image = UIImage(named: ratingImageString)

        return imageView
    }
}

class ItemInfoRatingView: UIView {

    let ratingType: ItemInfoRatingType

    private lazy var ratingImageView: UIImageView = {
        let imageView = self.ratingType.ratingImageView

        return imageView
    }()

    private lazy var ratingLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .semiBold),
                          textColor: FaveColors.Black80,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    init(ratingType: ItemInfoRatingType, rating: Double) {
        self.ratingType = ratingType

        super.init(frame: .zero)

        addSubview(ratingImageView)
        addSubview(ratingLabel)

        constrain(ratingImageView, ratingLabel, self) { imageView, label, view in
            imageView.top == view.top + 4
            imageView.bottom == view.bottom - 4
            imageView.left == view.left

            label.left == imageView.right + 8
            label.centerY == imageView.centerY
            label.right == view.right
        }

        ratingLabel.text = "\(rating)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
