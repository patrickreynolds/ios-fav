import Foundation
import UIKit

extension UIColor {
    convenience init(r red: Int, g green: Int, b blue: Int, a alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 1.0, "Invalid alpha component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(hex: Int) {
        self.init(r:(hex >> 16) & 0xff, g:(hex >> 8) & 0xff, b:hex & 0xff)
    }

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    private func toBarTintColorN(_ tintColorN: CGFloat) -> CGFloat {
        let a: CGFloat = tintColorN - 40
        let b: CGFloat = 1 - 40 / 255.0
        return a / b
    }

    private func fromBarTintColorN(_ tintColorN: CGFloat) -> CGFloat {
        let a: CGFloat = tintColorN + 40
        let b: CGFloat = 1 - 40 / 255.0
        return a * b
    }

    func rgbHex() -> UInt {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: UInt = (UInt)(r * 255) << 16 | (UInt)(g * 255) << 8 | (UInt)(b * 255) << 0

        return rgb
    }

    func rgbaHex() -> UInt {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgba: UInt = (UInt)(r * 255) << 24 | (UInt)(g * 255) << 16 | (UInt)(b * 255) << 8 | (UInt)(b * 255) << 0

        return rgba
    }

    func hexString() -> String {
        return String(format: "%06x", rgbHex())
    }

    func htmlHexString() -> String {
        return "#\(hexString())"
    }
}

