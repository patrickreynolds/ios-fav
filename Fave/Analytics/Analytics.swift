import Foundation
import UIKit

enum AnalyticsLogLevel: String {
    case Debug
    case Info
    case Warning
    case Error
    case Critical
}

struct Analytics {
    func logEvent(dependencyGraph: DependencyGraphType, title: String, info: [String: AnyObject]? = nil, level: AnalyticsLogLevel = .Debug) {
        print("\(title) – \(info?.description ?? "no info") – \(level.rawValue)")

        let event = AnalyticsEvent.init(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "", eventName: title)

        dependencyGraph.analyticsService.logEvent(event: event)
    }
}
