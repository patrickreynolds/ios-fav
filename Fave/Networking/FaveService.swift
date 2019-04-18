import Foundation

protocol FaveServiceType {
    func authenticate(network: String, accessToken: String, completion: @escaping FaveAPICallResultCompletionBlock)
    func getCurrentUser(completion: @escaping (_ user: User?, _ error: Error?) -> ())
    func getUser(userId: Int, completion: @escaping (_ user: User?, _ error: Error?) -> ())
    func getLists(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ())
    func getList(userId: Int, listId: Int, completion:  @escaping (_ lists: List?, _ error: Error?) -> ())
    func createList(userId: Int, name: String, description: String, isPublic: Bool, completion: @escaping (_ list: List?, _ error: Error?) -> ())
    func createListItem(userId: Int, listId: Int, type: String, placeId: String, note: String, completion: @escaping FaveAPICallResultCompletionBlock)
    func getListItems(userId: Int, listId: Int, completion: @escaping (_ items: [Item]?, _ error: Error?) -> ())
    func getPaginatedFeed(page: Int, completion: @escaping FaveAPICallResultCompletionBlock)
    func getFeed(from: Int, to: Int, completion: @escaping FaveAPICallResultCompletionBlock)
    func suggestions(completion: @escaping (_ lists: [List]?, _ error: Error?) -> ())
    func topLists(completion: @escaping (_ lists: [TopList]?, _ error: Error?) -> ())
}

struct FaveService {
    private let networking: NetworkingType

    init(networking: NetworkingType) {
        self.networking = networking
    }

    func getCurrentUser(completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .currentUser) { response, error in
            guard let userData = response as? [String: AnyObject], let user = User(data: userData) else {
                completion(nil, error)

                return
            }

            completion(user, error)
        }
    }

    func getUser(userId: Int, completion: @escaping (User?, Error?) -> ()) {
        networking.sendGetRequest(endpoint: .user(userId: userId)) { response, error in
            guard let userData = response as? [String: AnyObject], let user = User(data: userData) else {
                completion(nil, error)

                return
            }

            completion(user, error)
        }
    }

    func authenticate(network: String,   accessToken: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        // { "network" : "facebook", "accessToken": facebookAccessToken }

        let data: [String: String] = [
            "network": network,
            "accessToken": accessToken,
//            "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTU1NDIxMDMxNiwiZXhwIjo0Njk5MTcwMzE2fQ.aQRXkj8bkFidaPj_ThLhvj3whyDhjQuU9YGgW9MhoBg",
//            "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTU1NDIxMDQ4OCwiZXhwIjo0Njk5MTcwNDg4fQ.xXzGP3sZf7zWonrioUN1A6EQ6buYGIVbOVZGlyeOVAU",

        ]

        networking.sendPostRequest(endpoint: .authentication, data: data) { response, error in
            completion(response, error)
        }
    }

    func getLists(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .getLists(userId: userId)) { response, error in
            guard let unwrappedResponse = response, let listData = unwrappedResponse as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let faveLists = listData.map({ List(data: $0)}).compactMap({ $0 })

            completion(faveLists, error)
        }
    }

    func getList(userId: Int, listId: Int, completion:  @escaping (_ lists: List?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .getList(userId: userId, listId: listId)) { response, error in
            guard let listData = response as? [String: AnyObject], let list = List(data: listData) else {
                completion(nil, error)

                return
            }

            completion(list, error)
        }
    }

    func createList(userId: Int, name: String, description: String, isPublic: Bool, completion: @escaping (_ list: List?, _ error: Error?) -> ()) {
        let data: [String: String] = [
            "title": name,
            "description": description,
            "isPublic": isPublic ? "true" : "false"
        ]

        networking.sendPostRequest(endpoint: .createList(userId: userId), data: data) { response, error in
            guard let listData = response as? [String: AnyObject],
                  let list = List(data: listData) else {
                    completion(nil, error)

                    return
            }

            completion(list, error)
        }
    }

    func createListItem(userId: Int, listId: Int, type: String, placeId: String, note: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        let data: [String: String] = [
            "googlePlaceId": placeId,
            "note": note
        ]

        networking.sendPostRequest(endpoint: .createListItem(userId: userId, listId: listId, type: type), data: data) { response, error in
            completion(response, error)
        }
    }

    func getListItems(userId: Int, listId: Int, completion: @escaping (_ items: [Item]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .getListItems(userId: userId, listId: listId)) { response, error in
            guard let unwrappedResponse = response, let listItemData = unwrappedResponse as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let listItems = listItemData.map({ Item(data: $0)}).compactMap({ $0 })

            completion(listItems, error)
        }
    }

    func getPaginatedFeed(page: Int, completion: @escaping FaveAPICallResultCompletionBlock) {
        networking.sendGetRequest(endpoint: .paginatedFeed(page: page)) { response, error in
            completion(response, error)
        }
    }

    func getFeed(from: Int, to: Int, completion: @escaping FaveAPICallResultCompletionBlock) {
        networking.sendGetRequest(endpoint: .feed(from: from, to: to)) { response, error in
            completion(response, error)
        }
    }

    func suggestions(completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .suggestions) { response, error in
            guard let suggestionData = response as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let suggestions = suggestionData.map({ List(data: $0 )}).compactMap { $0 }

            completion(suggestions, error)
        }
    }

    func topLists(completion: @escaping (_ lists: [TopList]?, _ error: Error?) -> ()) {

        let list1Item1 = TopListItem.init(name: "Marufuku", type: "Ramen restaurnat")
        let list1Item2 = TopListItem.init(name: "Ippudo", type: "Ramen")
        let list1Item3 = TopListItem.init(name: "Waraku", type: "Japanese Cuisine")

        let list1 = TopList(name: "SF Ramen Shops", owner: "Albert", items: [list1Item1, list1Item2, list1Item3])
        let list2 = TopList(name: "Croissants", owner: "Patrick", items: [])
        let list3 = TopList(name: "Coffee Shops", owner: "Shelley", items: [])

        let topLists = [list1, list2, list3]

//        struct TopList {
//            let name: String
//            let owner: String
//            let items: [TopListItem]
//        }
//
//        struct TopListItem {
//            let name: String
//            let type: String
//        }

        completion(topLists, nil)
    }
}

extension FaveService: FaveServiceType {}
