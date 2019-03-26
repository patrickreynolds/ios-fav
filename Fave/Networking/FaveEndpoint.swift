import Foundation

enum FaveEndpoint {
    case flights(origin: String, destination: String)
    case authentication
    case user
    case getLists(userId: String)
    case getList(userId: String, listId: String)
    case createList(userId: String)
    case createListItem(userId: String, listId: String, type: String)
    case analytics

    var path: String {
        switch self {
        case .flights(let origin, let destination):
            return "api/v1/flights/quotes?origin=\(origin)&destination=\(destination)"
        case .authentication:
            return "auth/login/external"
        case .user:
            return "api/v1/users/me"
        case .getLists(let userId):
            return "api/v1/users/\(userId)/lists"
        case .getList(let userId, let listId):
            return "api/v1/users/\(userId)/lists/\(listId)"
        case .createList(let userId):
            return "api/v1/users/\(userId)/lists"
        case .createListItem(let userId, let listId, let type):
            return "api/v1/users/\(userId)/lists/\(listId)/type/\(type)"
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
