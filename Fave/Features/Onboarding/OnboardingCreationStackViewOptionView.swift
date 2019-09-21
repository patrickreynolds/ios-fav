import UIKit

import Cartography

struct OnboardingCreationStackViewOption {
    let title: String
    let primary: Bool
    let hasBorder: Bool
}

class OnboardingCreationStackViewOptionView: UIView {

    // MARK: - Properties

    let option: OnboardingCreationStackViewOption

    // MARK: - UI Properties

    private lazy var titleLabel: Label = {
        let label = Label(
            text: option.title,
            font: FaveFont(style: .h5, weight: option.primary ? .semiBold : .regular),
            textColor: option.primary ? FaveColors.Black100 : FaveColors.Black60,
            textAlignment: .center,
            numberOfLines: 1)

        return label
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == (self.option.hasBorder ? 1 : 0)
        }

        return view
    }()

    // MARK: - Initializers

    init(option: OnboardingCreationStackViewOption) {
        self.option = option

        super.init(frame: .zero)

        backgroundColor = FaveColors.White

        addSubview(titleLabel)
        addSubview(dividerView)

        constrain(titleLabel, self) { label, view in
            label.left == view.left
            label.right == view.right
            label.top == view.top + 16
            label.bottom == view.bottom - 16
        }

        constrain(dividerView, self) { dividerView, view in
            dividerView.right == view.right - 16
            dividerView.left == view.left + 16
            dividerView.bottom == view.bottom
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions

    func simulateTap(completion handler: (() -> ())?) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
            self.backgroundColor = FaveColors.Black20
        }) { completion in }

        UIView.animate(withDuration: 0.15, delay: 0.16, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
            self.backgroundColor = FaveColors.White
        }) { completion in
            handler?()
        }
    }
}
