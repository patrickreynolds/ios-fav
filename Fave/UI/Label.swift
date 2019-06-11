import UIKit
import Cartography

class Label: UIView, Shimmerable {
    // MARK: - Properties

    private var topLabelConstraint: NSLayoutConstraint?
    private var bottomLabelConstraint: NSLayoutConstraint?

    private let label: UILabel
    private let textAlignment: NSTextAlignment

    var text: String? {
        didSet {
            updateLabel()
        }
    }

    var font: FaveFont {
        didSet {
            updateLabel()
        }
    }

    var textColor: UIColor {
        didSet {
            updateLabel()
        }
    }

    var contentHuggingPriority: UILayoutPriority? {
        didSet {
            updateLabel()
        }
    }

    var contentCompressionResistancePriority: UILayoutPriority? {
        didSet {
            updateLabel()
        }
    }

    var attributedText: NSMutableAttributedString? {
        didSet {
            updateLabel()
        }
    }

    // MARK: - Initializers

    init(text: String? = nil,
         font: FaveFont,
         textColor: UIColor = FaveColors.Black90,
         textAlignment: NSTextAlignment = .natural,
         numberOfLines: Int = 1) {
        self.label = UILabel() // swiftlint:disable:this affirm_label
        self.label.numberOfLines = numberOfLines

        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment

        super.init(frame: CGRect.zero)

        layoutMargins = UIEdgeInsets.zero
        isUserInteractionEnabled = false

        addSubview(label)

        constrain(label, self) { label, view in
            topLabelConstraint = (label.top == view.topMargin)
            bottomLabelConstraint = (label.bottom == view.bottomMargin)
            label.left == view.leftMargin
            label.right == view.rightMargin
        }

        updateLabel()
    }

    func setSecondaryColors(subtext: String, color: UIColor) {
        let range = NSString(string: self.label.attributedText?.string ?? "").range(of: subtext)

        if range.location != NSNotFound {
            updateLabel(secondaryTextColor: color, secondaryTextLocation: range)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func updateLabel(secondaryTextColor: UIColor? = nil, secondaryTextLocation: NSRange? = nil) {
        if let text = text, text.isEmpty == false || attributedText != nil {
            var attributes = [NSAttributedString.Key: AnyObject]()
            attributes[NSAttributedString.Key.font] = font.font
            attributes[NSAttributedString.Key.foregroundColor] = textColor

            let paragraphStyle = NSMutableParagraphStyle()
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            paragraphStyle.alignment = textAlignment
            paragraphStyle.lineBreakMode = .byTruncatingTail

            if label.numberOfLines == 1 {
                if let kerning = font.kerning {
                    // BUG: Apparently you cannot use line spacing and kerning together or else the line spacing is applied even to single lines.
                    // https://openradar.appspot.com/31401189
                    // So we can only apply kerning to single lines of text where line spacing is not being set.
                    attributes[NSAttributedString.Key.kern] = NSNumber(value: kerning)
                }
            } else {
                // We only set the line spacing if the number of lines is not one
                paragraphStyle.lineSpacing = font.lineSpacing
            }

            // Enable multiple text formatting (e.g. "See Details")
            let string = NSMutableAttributedString(string: text, attributes: attributes)
            if let color = secondaryTextColor, let location = secondaryTextLocation {
                string.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: location)
            }

            label.attributedText = string

            let halfLineSpacing = font.lineSpacing / 2
            topLabelConstraint?.constant = halfLineSpacing
            bottomLabelConstraint?.constant = -halfLineSpacing

            if let compressionPriority = contentCompressionResistancePriority {
                label.setContentCompressionResistancePriority(compressionPriority, for: NSLayoutConstraint.Axis.horizontal)
            }

            if let huggingPriority = contentHuggingPriority {
                label.setContentHuggingPriority(huggingPriority, for: NSLayoutConstraint.Axis.horizontal)
            }

            if let attributedText = attributedText {
                attributedText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange.init(location: 0, length: attributedText.string.count))
                label.attributedText = attributedText
            }
        } else {
            label.attributedText = nil

            topLabelConstraint?.constant = 0
            bottomLabelConstraint?.constant = 0
        }
    }

    // MARK: - UIAccessibility Methods

    override var accessibilityLabel: String? {
        set {
            label.accessibilityLabel = newValue
        }
        get {
            return label.accessibilityLabel
        }
    }
}

