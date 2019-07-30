import UIKit
import Cartography

class ProfileInputView: UIView {

    let title: String
    let placeholder: String
    let contentType: UITextContentType?
    let autocapitalizationType: UITextAutocapitalizationType?

    var delegate: UITextFieldDelegate? {
        didSet {
            valueTextField.delegate = delegate
        }
    }

    private var _value: String {
        didSet {
            valueTextField.text = _value
        }
    }

    private(set) var value: String {
        get {
            return valueTextField.text ?? ""
        }

        set {
            self._value = newValue
        }
    }

    private lazy var titleLabel: Label = {
        let label = Label(text: title,
                            font: FaveFont(style: .h5, weight: .regular),
                            textColor: FaveColors.Black90,
                            textAlignment: .left,
                            numberOfLines: 1)

        return label
    }()

    private lazy var valueTextField: UITextField = {
        let textfield = UITextField.init(frame: .zero)

        textfield.text = _value
        textfield.placeholder = placeholder
        textfield.font = FaveFont(style: .h5, weight: .regular).font

        textfield.delegate = delegate

        if let contentType = contentType {
            textfield.textContentType = contentType
        }

        if let autocapitalizationType = autocapitalizationType {
            textfield.autocapitalizationType = autocapitalizationType
        }

        return textfield
    }()

    private lazy var dividerView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 1
        }

        return view
    }()

    init(title: String, placeholder: String, value: String, contentType: UITextContentType? = nil, autocapitalizationType: UITextAutocapitalizationType? = nil) {
        self.title = title
        self.placeholder = placeholder
        self._value = value
        self.contentType = contentType
        self.autocapitalizationType = autocapitalizationType

        super.init(frame: .zero)

        addSubview(titleLabel)
        addSubview(valueTextField)
        addSubview(dividerView)

        constrain(titleLabel, self) { titleLabel, view in
            titleLabel.top == view.top + 16
            titleLabel.bottom == view.bottom - 16
            titleLabel.left == view.left + 16
        }

        constrain(valueTextField, titleLabel, self) { textField, titleLabel, view in
            textField.centerY == titleLabel.centerY
            textField.left == view.left + 120
            textField.right == view.right - 16
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
