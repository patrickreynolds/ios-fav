import UIKit
import Cartography

class ProfileInputTitleView: UIView {

    private let title: String

    private lazy var titleLabel: Label = {
        let label = Label(text: self.title,
                                font: FaveFont(style: .h5, weight: .bold),
                                textColor: FaveColors.Black90,
                                textAlignment: .left,
                                numberOfLines: 0)

        return label
    }()

    init(title: String) {
        self.title = title

        super.init(frame: .zero)

        addSubview(titleLabel)

        constrain(titleLabel, self) { titleLabel, view in
            titleLabel.top == view.top
            titleLabel.right == view.right - 16
            titleLabel.bottom == view.bottom
            titleLabel.left == view.left + 16
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
