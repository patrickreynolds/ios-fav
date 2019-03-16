import Foundation

extension Int {
    var asLocaleCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self))!
    }
}
