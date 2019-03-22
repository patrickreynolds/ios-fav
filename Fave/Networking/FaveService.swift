import Foundation

protocol FaveServiceType {
    func authenticate(network: String, accessToken: String, completion: @escaping FaveAPICallResultCompletionBlock)
    func getCurrentUser(completion: @escaping FaveAPICallResultCompletionBlock)
    func createList(name: String, description: String, isPublic: Bool, completion: @escaping FaveAPICallResultCompletionBlock)
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

    func createList(name: String, description: String = "", isPublic: Bool = true, completion: @escaping FaveAPICallResultCompletionBlock) {
        let data: [String: String] = [
            "title": name,
            "description": description,
            "isPublic": isPublic ? "true" : "false"
            ]

        networking.sendPostRequest(endpoint: .list, data: data) { response, error in
            completion(response, error)
        }
    }
}

extension FaveService: FaveServiceType {}
