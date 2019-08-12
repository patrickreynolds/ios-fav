import UIKit
import Cartography

class ProfileActionView: UIView {

    private let action: (() -> ())

    private var _color: UIColor {
        didSet {
            actionLabel.textColor = _color
        }
    }

    private(set) var color: UIColor {
        get {
            return self._color
        }

        set {
            self._color = newValue
        }
    }

    private var _title: String = "" {
        didSet {
            actionLabel.text = _title
        }
    }

    var title: String {
        get {
            return self._title
        }

        set {
            self._title = newValue
        }
    }

    private lazy var actionLabel: Label = {
        let label = Label(text: _title,
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: color,
                          textAlignment: .left,
                          numberOfLines: 1)

        label.isUserInteractionEnabled = true

        _ = label.tapped { _ in
            self.action()
        }

        return label
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 1
        }

        return view
    }()

    init(title: String, color: UIColor, action: @escaping () -> ()) {
        self._title = title
        self._color = color
        self.action = action

        super.init(frame: .zero)

        self.backgroundColor = FaveColors.White

        addSubview(actionLabel)
        addSubview(dividerView)

        constrain(actionLabel, self) { actionLabel, view in
            actionLabel.top == view.top + 16
            actionLabel.right == view.right - 16
            actionLabel.bottom == view.bottom - 16
            actionLabel.left == view.left + 16
        }

        constrain(dividerView, self) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left + 16
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
