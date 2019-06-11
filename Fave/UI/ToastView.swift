import UIKit
import Cartography

enum ToastAttitude {
    case success

    var color: UIColor {
        switch self {
            case .success:
                return FaveColors.SuccessGreen.withAlphaComponent(0.92)
        }
    }
}

class ToastView: UIView {

    var attitude: ToastAttitude = .success

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .semiBold),
                          textColor: FaveColors.White,
                          textAlignment: .center,
                          numberOfLines: 0)

        return label
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = attitude.color

        addSubview(titleLabel)

        constrain(titleLabel, self) { titleLabel, view in

            titleLabel.top == view.top + 16
            titleLabel.bottom == view.bottom - 16
            
            titleLabel.centerX == view.centerX
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
