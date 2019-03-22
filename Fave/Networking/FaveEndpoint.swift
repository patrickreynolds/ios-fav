import Foundation

enum FaveEndpoint {
    case flights(origin: String, destination: String)
    case authentication
    case user
    case list
    case analytics

    var path: String {
        switch self {
        case .flights(let origin, let destination):
            return "api/v1/flights/quotes?origin=\(origin)&destination=\(destination)"
        case .authentication:
            return "auth/login/external"
        case .user:
            return "api/v1/users/me"
        case .list:
            return "api/v1/lists"
        case .analytics:
            return "api/v1/analytics"
        }
    }
}

struct FaveEndpoints {
    static func flights(_ origin: String, _ destination: String) -> String {
        return FaveEndpoint.flights(origin: origin, destination: destination).path
    }
}
