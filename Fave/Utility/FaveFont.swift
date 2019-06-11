import UIKit

struct FaveFont {
    static var useCalibre = false

    let style: FaveFontStyle
    let weight: FaveFontWeight
    let honorLineHeight: Bool

    var font: UIFont {
        return style.withWeight(weight)
    }

    var lineHeight: CGFloat {
        return honorLineHeight ? style.lineHeight : style.rawValue
    }

    var lineSpacing: CGFloat {
        return honorLineHeight ? style.lineSpacing : 0
    }

    var kerning: Float? {
        switch style {
        case .xsmall: return 0.5
        case .xxsmall: return 0.5
        default: return nil
        }
    }

    init(style: FaveFontStyle, weight: FaveFontWeight, honorLineHeight: Bool = true) {
        self.style = style
        self.weight = weight
        self.honorLineHeight = honorLineHeight
    }
}

enum FaveFontWeight: String {
    // ProximaNova weights. Should be deprecated and removed at some point
    case light = "-Light"
    case regular = "-Regular"
    case semiBold = "-Semibold"
    case bold = "-Bold"
    case extraBold = "-Extrabld"
    // Calibre
    case calibreBold = "Calibre-Bold"
    case calibreSemiBold = "Calibre-Semibold"
    case calibreMedium = "Calibre-Medium"
    case calibreRegular = "Calibre-Regular"
}

enum FaveFontStyle: CGFloat {
    case display = 56.0
    case title = 48.0
    case header = 40.0
    case h1 = 32.0
    case h2 = 28.0
    case h3 = 24.0
    case h4 = 20.0
    case h5 = 16.0
    case small = 14.0
    case xsmall = 12.0
    case xxsmall = 10.0

    var lineHeight: CGFloat {
        return self.rawValue + lineSpacing
    }

    var lineSpacing: CGFloat {
        switch self {
        case .display: return 0
        case .title: return 0
        case .h5: return 6
        default: return 8
        }
    }

    func withWeight(_ weight: FaveFontWeight) -> UIFont {
        var name = "ProximaNova" + weight.rawValue

        if FaveFont.useCalibre {
            name = calibreFontName(weight)
        }

        return UIFont(name: name, size: self.rawValue)!
    }

    private func calibreFontName(_ weight: FaveFontWeight) -> String {
        switch weight {
        case .extraBold:
            return FaveFontWeight.calibreBold.rawValue
        case .semiBold:
            return FaveFontWeight.calibreMedium.rawValue
        case .bold:
            return FaveFontWeight.calibreSemiBold.rawValue
        case .regular, .light:
            return FaveFontWeight.calibreRegular.rawValue
        case .calibreBold, .calibreSemiBold, .calibreMedium, .calibreRegular:
            return weight.rawValue
        }
    }
}
