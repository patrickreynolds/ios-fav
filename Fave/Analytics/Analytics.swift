import UIKit

enum AnalyticsLogLevel: String {
    case Debug
    case Info
    case Warning
    case Error
    case Critical
}

struct Analytics {
    func logEvent(dependencyGraph: DependencyGraphType = UIApplication.shared.appDelegate.dependencyGraph, title: String, info: [String: AnyObject]? = nil, level: AnalyticsLogLevel = .Debug) {
        print("\(title) – \(info?.description ?? "no info") – \(level.rawValue)")

        var userId = ""

        if let userIdInt = dependencyGraph.storage.getUser()?.id {
            userId = "\(userIdInt)"
        }

        let event = AnalyticsEvent(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "", eventName: title, userId: userId)

        dependencyGraph.analyticsService.logEvent(event: event) { success, error in
            guard let success = success else {
                return
            }

            print(success ? "\nEvent logged: \(event.eventName)\n" : "\nEvent log failed: \(event.eventName)\n")
        }
    }
}
