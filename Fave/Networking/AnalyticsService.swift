import Foundation

//http://localhost:3000/api/v1/analytics

struct AnalyticsEvent {
    let deviceId: String
    let eventName: String
    let userId: String?

    var dictionary: [String: String] {
        let event = [
            "deviceId": deviceId,
            "eventName": eventName,
            "userId": userId ?? ""
        ]

        return event
    }
}

protocol AnalyticsServiceType {
    func logEvent(event: AnalyticsEvent, completion: @escaping (_ success: Bool?, _ error: Error?) -> ())
}

struct AnalyticsService {
    private let networking: NetworkingType

    init(networking: NetworkingType) {
        self.networking = networking
    }

    func logEvent(event: AnalyticsEvent, completion: @escaping (_ success: Bool?, _ error: Error?) -> ()) {
        print("\n\n\(event.dictionary)\n\n")

        let eventMutation = GraphQLQueryBuilder.eventMutation(event: event)

        networking.sendGraphqlRequest(query: eventMutation) { response, error in
            guard let eventResponse = response as? [String: AnyObject], let status = eventResponse["status"] as? Bool else {
                completion(false, error)

                return
            }

            completion(status, error)
        }
    }
}

extension AnalyticsService: AnalyticsServiceType {}
