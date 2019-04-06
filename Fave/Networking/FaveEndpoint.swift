import Foundation

enum FaveEndpoint {
    case flights(origin: String, destination: String)
    case authentication
    case currentUser
    case user(userId: String)
    case getLists(userId: String)
    case getList(userId: String, listId: String)
    case createList(userId: String)
    case createListItem(userId: String, listId: String, type: String)
    case getListItems(userId: String, listId: String)
    case paginatedFeed(page: Int)
    case feed(from: Int, to: Int)
    case suggestions
    case analytics

    var path: String {
        switch self {
        case .flights(let origin, let destination):
            return "api/v1/flights/quotes?origin=\(origin)&destination=\(destination)"
        case .authentication:
            return "auth/login/external"
        case .currentUser:
            return "api/v1/users/me"
        case .user(let userId):
            return "api/v1/users/\(userId)"
        case .getLists(let userId):
            return "api/v1/users/\(userId)/lists"
        case .getList(let userId, let listId):
            return "api/v1/users/\(userId)/lists/\(listId)"
        case .createList(let userId):
            return "api/v1/users/\(userId)/lists"
        case .createListItem(let userId, let listId, let type):
            return "api/v1/users/\(userId)/lists/\(listId)/list-items/types/PLACE/\(type)"
        case .getListItems(let userId, let listId):
            return "api/v1/users/\(userId)/lists/\(listId)/list-items"
        case .paginatedFeed(let page):
            return "api/v1/feed?page=\(page)"
        case .feed(let from, let to):
            return "api/v1/feed?to=\(to)&from=\(from)"
        case .suggestions:
            return "api/v1/lists/suggestions"
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
