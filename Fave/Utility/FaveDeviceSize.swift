import UIKit

struct FaveDeviceSize {
    static func isIPhone4OrLess() -> Bool {
        return UIScreen.main.bounds.size.height <= 480.0
    }

    static func isIPhone5sOrLess() -> Bool {
        return UIScreen.main.bounds.size.width <= 320.0
    }

    static func isIPhone6() -> Bool {
        return UIScreen.main.bounds.size.height == 667.0
    }

    static func isIPhone6Plus() -> Bool {
        return UIScreen.main.bounds.size.height == 736.0
    }

    static func isIPhoneX() -> Bool {
        return UIScreen.main.bounds.size.height == 812.0
    }
}
