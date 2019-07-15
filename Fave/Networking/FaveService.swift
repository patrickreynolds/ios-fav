import Foundation

struct AuthenticationInfo {
    let token: String
    let user: User
}

protocol FaveServiceType {
    func authenticate(network: String, accessToken: String, completion: @escaping (_ authenticationInfo: AuthenticationInfo?, _ error: Error?) -> ())
    func getCurrentUser(completion: @escaping (_ user: User?, _ error: Error?) -> ())
    func getUser(userId: Int, completion: @escaping (_ user: User?, _ error: Error?) -> ())
    func updateUser(firstName: String, lastName: String, email: String, handle: String, bio: String, completion: @escaping (_ user: User?, _ error: Error?) -> ())
    func getLists(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ())
    func getList(userId: Int, listId: Int, completion:  @escaping (_ lists: List?, _ error: Error?) -> ())
    func createList(userId: Int, name: String, description: String, isPublic: Bool, completion: @escaping (_ list: List?, _ error: Error?) -> ())
    func createListItem(userId: Int, listId: Int, type: String, placeId: String, note: String, completion: @escaping (_ item: Item?, _ error: Error?) -> ())
    func getListItem(userId: Int, listId: Int, itemId: Int, completion: @escaping (_ item: Item?, _ error: Error?) -> ())
    func getListItems(userId: Int, listId: Int, completion: @escaping (_ items: [Item]?, _ error: Error?) -> ())
    func deleteListItem(itemId: Int, completion: @escaping (_ item: Int?, _ error: Error?) -> ())
    func updateListItem(itemId: Int, listId: Int, isRecommendation: Bool, completion: @escaping (_ item: Item?, _ error: Error?) -> ())
    func getFeed(from: Int, to: Int, completion: @escaping (_ events: [FeedEvent]?, _ error: Error?) -> ())
    func suggestions(completion: @escaping (_ lists: [List]?, _ error: Error?) -> ())
    func topLists(completion: @escaping (_ lists: [List]?, _ error: Error?) -> ())
    func getUsers(completion: @escaping (_ lists: [User]?, _ error: Error?) -> ())
    func followersOfList(listId: Int, completion: @escaping (_ lists: [User]?, _ error: Error?) -> ())
    func listsUserFollows(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ())
    func followList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ())
    func unfollowList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ())
    func getFaves(userId: Int, completion: @escaping (_ faveIds: [Int]?, _ error: Error?) -> ())
    func addFave(userId: Int, listId: Int, itemId: Int, note: String, completion: @escaping (_ item: Item?, _ error: Error?) -> ())
    func removeFave(userId: Int, itemId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ())
    func myItems(completion: @escaping (_ items: [Item]?, _ error: Error?) -> ())
    func submitFeedback(feedback: String, completion: @escaping (_ success: Bool?, _ error: Error?) -> ())
}

//struct FaveService {
//    private let networking: NetworkingType
//
//    init(networking: NetworkingType) {
//        self.networking = networking
//    }
//
//    func getCurrentUser(completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .currentUser) { response, error in
//            guard let userData = response as? [String: AnyObject], let user = User(data: userData) else {
//                completion(nil, error)
//
//                return
//            }
//
//            completion(user, error)
//        }
//    }
//
//    func getUser(userId: Int, completion: @escaping (User?, Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .user(userId: userId)) { response, error in
//            guard let userData = response as? [String: AnyObject], let user = User(data: userData) else {
//                completion(nil, error)
//
//                return
//            }
//
//            completion(user, error)
//        }
//    }
//
//    func authenticate(network: String, accessToken: String, completion: @escaping (_ authenticationInfo: AuthenticationInfo?, _ error: Error?) -> ()) {
//        let data: [String: String] = [
//            "network": network,
//            "accessToken": accessToken,
//        ]
//
//        networking.sendPostRequest(endpoint: .authentication, data: data) { response, error in
//            guard let response = response,
//                let token = response["token"] as? String,
//                let userData = response["user"] as? [String: AnyObject],
//                let user = User(data: userData) else {
//
//                    completion(nil, error)
//
//                    return
//            }
//
//            print("\n\nToken: \(token)\n\n")
//
//            let authenticationInfo = AuthenticationInfo.init(token: token, user: user)
//
//            completion(authenticationInfo, error)
//        }
//    }
//
//    func getLists(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .getLists(userId: userId)) { response, error in
//            guard let unwrappedResponse = response, let listData = unwrappedResponse as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let faveLists = listData.map({ List(data: $0)}).compactMap({ $0 })
//
//            completion(faveLists, error)
//        }
//    }
//
//    func getList(userId: Int, listId: Int, completion:  @escaping (_ lists: List?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .getList(userId: userId, listId: listId)) { response, error in
//            guard let listData = response as? [String: AnyObject], let list = List(data: listData) else {
//                completion(nil, error)
//
//                return
//            }
//
//            completion(list, error)
//        }
//    }
//
//    func createList(userId: Int, name: String, description: String, isPublic: Bool, completion: @escaping (_ list: List?, _ error: Error?) -> ()) {
//        let data: [String: String] = [
//            "title": name,
//            "description": description,
//            "isPublic": isPublic ? "true" : "false"
//        ]
//
//        networking.sendPostRequest(endpoint: .createList(userId: userId), data: data) { response, error in
//            guard let listData = response as? [String: AnyObject],
//                  let list = List(data: listData) else {
//                    completion(nil, error)
//
//                    return
//            }
//
//            completion(list, error)
//        }
//    }
//
//    func createListItem(userId: Int, listId: Int, type: String, placeId: String, note: String, completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {
//        let data: [String: String] = [
//            "googlePlaceId": placeId,
//            "note": note
//        ]
//
//        networking.sendPostRequest(endpoint: .createListItem(userId: userId, listId: listId, type: type), data: data) { response, error in
//            guard let unwrappedResponse = response, let itemData = unwrappedResponse as? [String: AnyObject] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let item = Item(data: itemData)
//
//            completion(item, error)
//        }
//    }
//
//    func getListItems(userId: Int, listId: Int, completion: @escaping (_ items: [Item]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .getListItems(userId: userId, listId: listId)) { response, error in
//            guard let unwrappedResponse = response, let listItemData = unwrappedResponse as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let listItems = listItemData.map({ Item(data: $0)}).compactMap({ $0 })
//
//            completion(listItems, error)
//        }
//    }
//
//    func getListItem(userId: Int, listId: Int, itemId: Int, completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .getListItem(userId: userId, listId: listId, itemId: itemId)) { response, error in
//            guard let itemData = response as? [String: AnyObject] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let item = Item(data: itemData)
//
//            completion(item, nil)
//        }
//    }
//
//    func getFeed(from: Int, to: Int, completion: @escaping (_ events: [FeedEvent]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .feed(from: from, to: to)) { response, error in
//            guard let eventResponse = response, let eventData = eventResponse["events"] as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let feed = eventData.map({ FeedEvent(data: $0 )}).compactMap { $0 }
//
//            completion(feed, error)
//        }
//    }
//
//    func suggestions(completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .suggestions) { response, error in
//            guard let suggestionData = response as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let suggestions = suggestionData.map({ List(data: $0 )}).compactMap { $0 }
//
//            completion(suggestions, error)
//        }
//    }
//
//    func topLists(completion: @escaping (_ lists: [TopList]?, _ error: Error?) -> ()) {
//
//        let list1Item1 = TopListItem.init(name: "Marufuku", type: "Ramen restaurnat")
//        let list1Item2 = TopListItem.init(name: "Ippudo", type: "Ramen")
//        let list1Item3 = TopListItem.init(name: "Waraku", type: "Japanese Cuisine")
//
//        let list2Item1 = TopListItem.init(name: "Another Cafe", type: "Cafe")
//        let list2Item2 = TopListItem.init(name: "Reveille Coffee", type: "Cafe")
//        let list2Item3 = TopListItem.init(name: "Matching Half", type: "Coffee Shop")
//
//        let list3Item1 = TopListItem.init(name: "Arsicault Bakery", type: "Bakery")
//        let list3Item2 = TopListItem.init(name: "b. patisserie", type: "Bakery")
//        let list3Item3 = TopListItem.init(name: "Mr. Holmes Bakehouse", type: "Bakery")
//
//        let list1 = TopList(name: "SF Ramen Shops", owner: "Albert", items: [list1Item1, list1Item2, list1Item3])
//        let list2 = TopList(name: "Croissants", owner: "Patrick", items: [list2Item1, list2Item2, list2Item3])
//        let list3 = TopList(name: "Coffee Shops", owner: "Shelley", items: [list3Item1, list3Item2, list3Item3])
//
//        let topLists = [list1, list2, list3]
//
//        delay(3.0) {
//            completion(topLists, nil)
//        }
//    }
//
//    func getUsers(completion: @escaping (_ lists: [User]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .getUsers) { response, error in
//            guard let userData = response as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let users = userData.map({ User(data: $0 )}).compactMap { $0 }
//
//            completion(users, error)
//        }
//    }
//
//    func followersOfList(listId: Int, completion: @escaping (_ lists: [User]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .followersOfList(listId: listId)) { response, error in
//            guard let followersOfListData = response as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let followersOfList = followersOfListData.map({ User(data: $0 )}).compactMap { $0 }
//
//            completion(followersOfList, error)
//        }
//    }
//
//    func listsUserFollows(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .listsUserFollows(userId: userId)) { response, error in
//            guard let listsUserFollowsData = response as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let listsUserFollows = listsUserFollowsData.map({ List(data: $0 )}).compactMap { $0 }
//
//            completion(listsUserFollows, error)
//        }
//    }
//
//    func followList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
//
//        let data = [String: String]()
//
//        networking.sendPostRequest(endpoint: .followUnfollow(listId: listId), data: data) { response, error in
//            guard let followResponseData = response as? [String: AnyObject] else {
//                completion(false, error)
//
//                return
//            }
//
//            var success = true
//            if let message = followResponseData["message"] as? String, message == "ok" {
//                success = true
//            }
//
//            completion(success, error)
//        }
//    }
//
//    func unfollowList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
//
//        let data = [String: String]()
//
//        networking.sendDeleteRequest(endpoint: .followUnfollow(listId: listId), data: data) { response, error in
//            guard let unfollowResponseData = response as? [String: AnyObject] else {
//                completion(false, error)
//
//                return
//            }
//
//            var success = true
//            if let message = unfollowResponseData["message"] as? String, message == "ok" {
//                success = true
//            }
//
//            completion(success, error)
//        }
//    }
//
//    func getFaves(userId: Int, completion: @escaping (_ faveIds: [Int]?, _ error: Error?) -> ()) {
//        networking.sendGetRequest(endpoint: .faves(userId: userId)) { response, error in
//            guard let faves = response as? [Int] else {
//                completion(nil, error)
//
//                return
//            }
//
//            completion(faves, error)
//        }
//    }
//
//    func addFave(userId: Int, listId: Int, itemId: Int, note: String = "", completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {
//
//        let data: [String: String] = [
//            "listId": "\(listId)",
//            "itemId": "\(itemId)",
//            "note": note
//        ]
//
//        networking.sendPostRequest(endpoint: .faves(userId: userId), data: data) { response, error in
//            guard let itemData = response as? [String: AnyObject] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let item = Item(data: itemData)
//
//            completion(item, error)
//        }
//    }
//
//    func removeFave(userId: Int, itemId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
//
//        let data: [String: String] = [
//            "dataId": "\(itemId)"
//        ]
//
//        networking.sendDeleteRequest(endpoint: .faves(userId: userId), data: data) { response, error in
//            guard let responseData = response as? [String: AnyObject] else {
//                completion(false, error)
//
//                return
//            }
//
//            var success = false
//            if let message = responseData["message"] as? String, message == "ok" {
//                success = true
//            }
//
//            completion(success, error)
//        }
//    }
//
//    func myItems(completion: @escaping (_ items: [Item]?, _ error: Error?) -> ()) {
//
//        let myItemsQuery = GraphQLQueryBuilder.myItemsQuery()
//
//        networking.sendGraphqlRequest(query: myItemsQuery) { response, error in
//            guard let unwrappedResponse = response, let itemData = unwrappedResponse["items"] as? [[String: AnyObject]] else {
//                completion(nil, error)
//
//                return
//            }
//
//            let items = itemData.map({ Item(data: $0)}).compactMap({ $0 })
//
//            completion(items, error)
//        }
//
//    }
//
//    func updateUser(firstName: String, lastName: String, email: String, handle: String, bio: String, completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
//        let updateUserMutationString = GraphQLQueryBuilder.updateUserMutation(firstName: firstName, lastName: lastName, email: email, handle: handle, bio: bio)
//
//        networking.sendGraphqlRequest(query: updateUserMutationString) { response, error in
//            guard let unwrappedResponse = response, let userData = unwrappedResponse["user"] as? [String: AnyObject], let user = User.init(data: userData) else {
//                completion(nil, error)
//
//                return
//            }
//
//            completion(user, error)
//        }
//    }
//}
//
//extension FaveService: FaveServiceType {}
