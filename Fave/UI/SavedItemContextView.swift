import UIKit
import Cartography

class SavedItemContextView: UIView {

    private var title: String = "" {
        didSet {
            titleLabel.text = "Saved on your \(title)"
        }
    }

    private lazy var savedItemImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        imageView.image = UIImage(named: "icon-fave-faved")?.withRenderingMode(.alwaysOriginal)

        constrain(imageView) { imageView in
            imageView.height == 12
            imageView.width == 12
        }

        return imageView
    }()

    private lazy var titleLabel: Label = {
        let label = Label(text: "", font: FaveFont(style: .small, weight: .regular), textColor: FaveColors.Black70, textAlignment: .left, numberOfLines: 0)

        return label
    }()

    init() {
        super.init(frame: .zero)

        addSubview(savedItemImageView)
        addSubview(titleLabel)

        constrain(savedItemImageView, self) { imageView, view in
            imageView.left == view.left
            imageView.top == view.top
            imageView.bottom == view.bottom
        }

        constrain(titleLabel, savedItemImageView, self) { label, imageView, view in
            label.centerY == view.centerY
            label.right == view.right
            label.left == imageView.right + 4
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setListTitle(title: String) {
        self.title = title
    }
}
