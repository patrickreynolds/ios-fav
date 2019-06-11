import UIKit

extension String {
    func attributedStringWithFont(_ font: UIFont) -> NSAttributedString {
        return NSAttributedString(string: self, font: font)
    }

    func attributedStringWithFont(_ font: UIFont, textColor: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self, font: font, textColor: textColor)
    }

    func attributedStringWithTextColor(_ textColor: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self, textColor: textColor)
    }
}

extension NSAttributedString {
    convenience init(string: String, font: UIFont, textColor: UIColor) {
        self.init(string: string, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor])
    }

    convenience init(string: String, font: UIFont) {
        self.init(string: string, attributes: [NSAttributedString.Key.font: font])
    }

    convenience init(string: String, textColor: UIColor) {
        self.init(string: string, attributes: [NSAttributedString.Key.foregroundColor: textColor])
    }

    var paragraphStyle: NSParagraphStyle? {
        for (_, value) in allAttributes() {
            if let style = value as? NSParagraphStyle {
                return style
            }
        }
        return nil
    }

    func withFont(_ font: UIFont, textColor: UIColor) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor])
        return attrStr
    }

    func withFont(_ font: UIFont) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.font: font])
        return attrStr
    }

    func withTextColor(_ textColor: UIColor) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.foregroundColor: textColor])
        return attrStr
    }

    func withLineHeight(_ lineHeight: CGFloat) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = (attrStr.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attrStr
    }

    func withLineHeightMultiple(_ lineHeightMultiple: CGFloat) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = (attrStr.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attrStr
    }

    func withLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = (attrStr.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attrStr
    }

    func withParagraphSpacing(_ paragraphSpacing: CGFloat) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = (attrStr.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = paragraphSpacing
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attrStr
    }

    func withLineSpacing(_ lineSpacing: CGFloat) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = (attrStr.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attrStr
    }

    func withTextAlignment(_ textAlignment: NSTextAlignment) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = (attrStr.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attrStr
    }

    func withUnderline() -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue as AnyObject])
        return attrStr
    }

    func withKern(spacing: Double) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.kern: spacing as AnyObject])
        return attrStr
    }

    func withBackground(color: UIColor) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(attributedString: self)
        attrStr.setAttributes(allAttributes() + [NSAttributedString.Key.backgroundColor: color])
        return attrStr
    }

    func withAttributesForString(_ string: String, font: UIFont? = nil, textColor: UIColor? = nil) -> NSAttributedString {
        let attrString = NSMutableAttributedString(attributedString: self)
        let range = (attrString.string as NSString).range(of: string)
        if let font = font, let textColor = textColor {
            attrString.setAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor], range: range)
        } else if let font = font {
            attrString.setAttributes([NSAttributedString.Key.font: font], range: range)
        } else if let textColor = textColor {
            attrString.setAttributes([NSAttributedString.Key.foregroundColor: textColor], range: range)
        }
        return attrString
    }

    func withAttributes(_ attributes: [NSAttributedString.Key: AnyObject]) -> NSAttributedString {
        let attrString = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: self.length)
        attrString.setAttributes(attributes, range: range)
        return attrString
    }

    func allAttributes() -> [NSAttributedString.Key: Any] {
        if length <= 0 {
            return [:]
        }

        var range = NSRange(location: 0, length: length)
        return attributes(at: 0, effectiveRange: &range)
    }

    var mutableAttributedString: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: self)
    }
}

extension NSMutableAttributedString {
    var attributedString: NSAttributedString {
        return NSAttributedString(attributedString: self)
    }

    func setAttributes(_ attrs: [NSAttributedString.Key : Any]?) {
        setAttributesSafe(attrs, range: NSRange(location: 0, length: length))
    }

    /* TODO: 3.21.2018 – Hacky AF. Swift 4 changed string functions quite a bit and this is just to keep us moving (apologies to future self or someone else who has to figure this out for real */
    func setAttributesSafe(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        guard string.count >= range.length else {
            return
        }

        if let _ = string.substring(with: range) {
            setAttributes(attrs, range: range)
        }
    }
}

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}
