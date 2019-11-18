import UIKit
import TTTAttributedLabel

protocol AttributedLabelFragment {
    var text: String { get }
}

extension AttributedLabelFragment {
    var link: URL? {
        return URL(string: text)
    }
}

extension String: AttributedLabelFragment {
    var text: String {
        return self
    }
}

struct AttributedLabelActionFragment: AttributedLabelFragment {
    var text: String
    var handler: () -> Void
}

class FaveAttributedLabel: UIView {
    private let label = TTTAttributedLabel(frame: .zero)

    init(fontStyle: FaveFontStyle,
         textColor: UIColor,
         linkColor: UIColor = FaveColors.Accent,
         textAlignment: NSTextAlignment = .left,
         fragments: [AttributedLabelFragment]) {
        super.init(frame: .zero)

        addSubview(label)
        constrainToSuperview(label)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.minimumLineHeight = fontStyle.lineHeight

        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: fontStyle.withWeight(.regular),
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.underlineStyle: 0,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        let textString = fragments.reduce("") { "\($0)\($1.text)" }
        let attributedString = NSMutableAttributedString(string: textString, attributes: attributes)
        label.attributedText = attributedString

        label.textAlignment = textAlignment
        label.numberOfLines = 0

        let linkAttributes: [AnyHashable : Any] = [
            NSAttributedString.Key.font: fontStyle.withWeight(.semiBold),
            NSAttributedString.Key.foregroundColor: linkColor, kCTForegroundColorAttributeName as AnyHashable: linkColor.cgColor
        ]
        label.linkAttributes = linkAttributes
        label.activeLinkAttributes = linkAttributes

        let actionFragments = fragments.compactMap { $0 as? AttributedLabelActionFragment }

        for fragment in actionFragments {
            let range = (textString as NSString).range(of: fragment.text)
            let link = label.addLink(to: fragment.link, with: range)
            link?.accessibilityValue = fragment.text

            let handler: TTTAttributedLabelLinkBlock = { _, _  in
                fragment.handler()
            }

            link?.linkTapBlock = handler
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
