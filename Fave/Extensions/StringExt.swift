import Foundation

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "1":
            return true
        case "false", "0":
            return false
        default:
            return nil
        }
    }
}
