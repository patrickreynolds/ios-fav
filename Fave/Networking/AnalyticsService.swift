import Foundation

//http://localhost:3000/api/v1/analytics

struct AnalyticsEvent {
    let deviceId: String
    let eventName: String

    var dictionary: [String: String] {
        return [
            "deviceId": deviceId,
            "eventName": eventName
        ]
    }
}

protocol AnalyticsServiceType {
    func logEvent(event: AnalyticsEvent, completion: FaveAPICallResultCompletionBlock?)
}

struct AnalyticsService {
    private let networking: NetworkingType

    init(networking: NetworkingType) {
        self.networking = networking
    }

    func logEvent(event: AnalyticsEvent, completion: FaveAPICallResultCompletionBlock? = nil) {
        print("\n\(event.dictionary)\n")

        networking.sendPostRequest(endpoint: .analytics, data: event.dictionary) { response, error in
            completion?(response, error)
        }
    }
}

extension AnalyticsService: AnalyticsServiceType {}
