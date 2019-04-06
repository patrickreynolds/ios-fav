import Foundation
import UIKit

protocol Haptic {
    func performImpact(style: UIImpactFeedbackGenerator.FeedbackStyle)
}

extension Haptic {
    func performImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
