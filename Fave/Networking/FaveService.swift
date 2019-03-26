import Foundation

protocol FaveServiceType {
    func authenticate(network: String, accessToken: String, completion: @escaping FaveAPICallResultCompletionBlock)
    func getCurrentUser(completion: @escaping FaveAPICallResultCompletionBlock)
    func getLists(userId: String, completion: @escaping FaveAPICallResultCompletionBlock)
    func getList(userId: String, listId: String, completion: @escaping FaveAPICallResultCompletionBlock)
    func createList(userId: String, name: String, description: String, isPublic: Bool, completion: @escaping FaveAPICallResultCompletionBlock)
    func createListItem(userId: String, listId: String, type: String, placeId: String, description: String, completion: @escaping FaveAPICallResultCompletionBlock)
}

struct FaveService {
    private let networking: NetworkingType

    init(networking: NetworkingType) {
        self.networking = networking
    }

    func getFlights(origin: String, destination: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        networking.sendGetRequest(endpoint: .flights(origin: origin, destination: destination)) { response, error in
            completion(response, error)
        }
    }

    func getCurrentUser(completion: @escaping FaveAPICallResultCompletionBlock) {
        networking.sendGetRequest(endpoint: .user) { response, error in
            completion(response, error)
        }
    }

    func authenticate(network: String, accessToken: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        // { "network" : "facebook", "accessToken": facebookAccessToken }

        let data: [String: String] = [
            "network": network,
            "accessToken": accessToken,
        ]

        networking.sendPostRequest(endpoint: .authentication, data: data) { response, error in
            completion(response, error)
        }
    }

    func getLists(userId: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        networking.sendGetRequest(endpoint: .getLists(userId: userId)) { response, error in
            completion(response, error)
        }
    }

    func getList(userId: String, listId: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        networking.sendGetRequest(endpoint: .getList(userId: userId, listId: listId)) { response, error in
            completion(response, error)
        }
    }

    func createList(userId: String, name: String, description: String = "", isPublic: Bool = true, completion: @escaping FaveAPICallResultCompletionBlock) {
        let data: [String: String] = [
            "title": name,
            "description": description,
            "isPublic": isPublic ? "true" : "false"
        ]

        networking.sendPostRequest(endpoint: .createList(userId: userId), data: data) { response, error in
            completion(response, error)
        }
    }

    func createListItem(userId: String, listId: String, type: String, placeId: String, description: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        let data: [String: String] = [
            "googlePlaceId": placeId
        ]

//        "description": description

        networking.sendPostRequest(endpoint: .createListItem(userId: userId, listId: listId, type: type), data: data) { response, error in
            completion(response, error)
        }
    }
}

extension FaveService: FaveServiceType {}
