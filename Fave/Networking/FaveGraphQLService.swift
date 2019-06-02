import Foundation
import Chester
import GraphQLicious

struct FaveGraphQLService {
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

//        let userQuery = Query.init(request: Request(withAlias: "",
//                                                name: "user",
//                                                arguments: [Argument(key: "userId", value: userId)],
//                                                fields: [
//                                                    "id",
//                                                    "firstName",
//                                                    "lastName",
//                                                    "handle",
//                                                    "profilePic",
////                                                    "createdAt",
////                                                    "updatedAt",
//                                                    ]))
//
//        print(userQuery.create())
//
//        let queryString = userQuery.create()

        let userQuery = GraphQLQueryBuilder.userQuery(userId: userId)

        networking.sendGraphqlRequest(query: userQuery) { response, error in
            guard let unwrappedResponse = response as? [String: AnyObject], let userData = unwrappedResponse["user"] as? [String: AnyObject], let user = User(data: userData) else {
                completion(nil, error)

                return
            }

            completion(user, error)
        }
    }

    func authenticate(network: String, accessToken: String, completion: @escaping (_ authenticationInfo: AuthenticationInfo?, _ error: Error?) -> ()) {

    /*
        let userContentRequest = Request(
            withAlias: "user",
            name: "user",
            fields: [
                "id",
                "firstName",
                "lastName",
                "email",
                "handle",
                "profilePic",
//                "createdAt",
//                "updatedAt",
            ]
        )

        let authenticateMutationRequest = Request(withAlias: "authenticate",
                                           name: "externalLogin",
                                           arguments: [
                                            Argument(key: "network", value: network),
                                            Argument.init(key: "accessToken", value: accessToken),
                                            Argument.init(key: "handle", value: "")
            ], fields: [
            "token",
            userContentRequest
            ])

        let authenticationMutation = Mutation.init(mutatingRequest: authenticateMutationRequest)

        let mutationStringFromBuilder = authenticationMutation.create()
     */

        let mutationString = GraphQLQueryBuilder.externalLoginMutation(network: network, accessToken: accessToken, handle: "")

        networking.sendGraphqlRequest(query: mutationString) { response, error in
            guard let response = response,
                let authenticationResponse = response["externalLogin"] as? [String: AnyObject],
                let token = authenticationResponse["token"] as? String,
                let userData = authenticationResponse["user"] as? [String: AnyObject],
                let user = User(data: userData) else {

                    completion(nil, error)

                    return
            }

            print("\n\nToken: \(token)\n\n")

            let authenticationInfo = AuthenticationInfo(token: token, user: user)

            completion(authenticationInfo, error)
        }
    }

    //        let id: Int
    //        let dataId: Int
    //        let type: String
    //        let updatedAt: Date
    //        let createdAt: Date
    //        let connectorType: String
    //        let connectorId: String
    //        let note: String
    //        let contextualItem: ItemType
    //        let content: [String: AnyObject]
    //        let numberOfFaves: Int
    //        let listId: Int
    //        let addedBy: User
    //        var isFaved: Bool? = nil

    func getLists(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {

        /*
        let followersRequest = Request(
            withAlias: "followers",
            name: "followers",
            fields: [
                "id",
                "firstName",
                "lastName",
                "handle",
                "profilePic",
            ]
        )

        let ownerReqeust = Request(
            withAlias: "owner",
            name: "owner",
            fields: [
                "id",
                "firstName",
                "lastName",
                "handle",
                "profilePic",
            ])

        let addedByRequest = Request(
            withAlias: "addedBy",
            name: "addedBy",
            fields: [
                "id",
                "firstName",
                "lastName",
                "handle",
                "profilePic",
            ])

        let itemsRequest = Request(
            withAlias: "items",
            name: "items",
            fields: [
                "id",
                "dataId",
                "type",
                "updatedAt",
                "createdAt",
//                "connectorType",
//                "connectorId",
                "note",
                "content",
                "numberOfFaves",
                "listId",
//                addedByRequest
            ])

        let myListsRequest = Request(
            withAlias: "myLists",
            name: "myLists",
            fields: [
                "id",
                "title",
                "description",
                "isPublic",
                "createdAt",
                "updatedAt",
                followersRequest,
                ownerReqeust,
                itemsRequest
            ]
        )

        let myListsQuery = Query(request: myListsRequest)
        */

        let listsQueryString = GraphQLQueryBuilder.listsQuery(userId: userId)

        networking.sendGraphqlRequest(query: listsQueryString) { response, error in
            guard let unwrappedResponse = response, let listData = unwrappedResponse["lists"] as? [[String: AnyObject]] else {
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

        let createListMutation = GraphQLQueryBuilder.createListMutation(userId: userId, title: name, description: description, isPublic: isPublic)

        networking.sendGraphqlRequest(query: createListMutation) { (response, error) in
            guard let listResponse = response as? [String: AnyObject], let listData = listResponse["list"] as? [String: AnyObject],
                let list = List(data: listData) else {
                    completion(nil, error)

                    return
            }

            completion(list, error)
        }
    }

    func createListItem(userId: Int, listId: Int, type: String, placeId: String, note: String, completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {
//        let data: [String: String] = [
//            "googlePlaceId": placeId,
//            "note": note
//        ]

        let createGooglePlacesItemQuery = GraphQLQueryBuilder.createGooglePlacesItem(listId: listId, googlePlacesId: placeId, note: note)

        networking.sendGraphqlRequest(query: createGooglePlacesItemQuery) { (response, error) in
            guard let itemResponse = response as? [String: AnyObject], let itemData = itemResponse["placeItem"] as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let item = Item(data: itemData)

            completion(item, error)
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

    func getListItem(userId: Int, listId: Int, itemId: Int, completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .getListItem(userId: userId, listId: listId, itemId: itemId)) { response, error in
            guard let itemData = response as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let item = Item(data: itemData)

            completion(item, nil)
        }
    }

    func getPaginatedFeed(page: Int, completion: @escaping FaveAPICallResultCompletionBlock) {
        networking.sendGetRequest(endpoint: .paginatedFeed(page: page)) { response, error in
            completion(response, error)
        }
    }

    func getFeed(from: Int, to: Int, completion: @escaping (_ events: [TempFeedEvent]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .feed(from: from, to: to)) { response, error in
            guard let eventResponse = response, let eventData = eventResponse["events"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let feed = eventData.map({ TempFeedEvent(data: $0 )}).compactMap { $0 }

            completion(feed, error)
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

        let list2Item1 = TopListItem.init(name: "Another Cafe", type: "Cafe")
        let list2Item2 = TopListItem.init(name: "Reveille Coffee", type: "Cafe")
        let list2Item3 = TopListItem.init(name: "Matching Half", type: "Coffee Shop")

        let list3Item1 = TopListItem.init(name: "Arsicault Bakery", type: "Bakery")
        let list3Item2 = TopListItem.init(name: "b. patisserie", type: "Bakery")
        let list3Item3 = TopListItem.init(name: "Mr. Holmes Bakehouse", type: "Bakery")

        let list1 = TopList(name: "SF Ramen Shops", owner: "Albert", items: [list1Item1, list1Item2, list1Item3])
        let list2 = TopList(name: "Croissants", owner: "Patrick", items: [list2Item1, list2Item2, list2Item3])
        let list3 = TopList(name: "Coffee Shops", owner: "Shelley", items: [list3Item1, list3Item2, list3Item3])

        let topLists = [list1, list2, list3]

        delay(3.0) {
            completion(topLists, nil)
        }
    }

    func getUsers(completion: @escaping (_ lists: [User]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .getUsers) { response, error in
            guard let userData = response as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let users = userData.map({ User(data: $0 )}).compactMap { $0 }

            completion(users, error)
        }
    }

    func followersOfList(listId: Int, completion: @escaping (_ lists: [User]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .followersOfList(listId: listId)) { response, error in
            guard let followersOfListData = response as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let followersOfList = followersOfListData.map({ User(data: $0 )}).compactMap { $0 }

            completion(followersOfList, error)
        }
    }

    func listsUserFollows(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .listsUserFollows(userId: userId)) { response, error in
            guard let listsUserFollowsData = response as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let listsUserFollows = listsUserFollowsData.map({ List(data: $0 )}).compactMap { $0 }

            completion(listsUserFollows, error)
        }
    }

    func followList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {

        let data = [String: String]()

        networking.sendPostRequest(endpoint: .followUnfollow(listId: listId), data: data) { response, error in
            guard let followResponseData = response as? [String: AnyObject] else {
                completion(false, error)

                return
            }

            var success = true
            if let message = followResponseData["message"] as? String, message == "ok" {
                success = true
            }

            completion(success, error)
        }
    }

    func unfollowList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {

        let data = [String: String]()

        networking.sendDeleteRequest(endpoint: .followUnfollow(listId: listId), data: data) { response, error in
            guard let unfollowResponseData = response as? [String: AnyObject] else {
                completion(false, error)

                return
            }

            var success = true
            if let message = unfollowResponseData["message"] as? String, message == "ok" {
                success = true
            }

            completion(success, error)
        }
    }

    func getFaves(userId: Int, completion: @escaping (_ faveIds: [Int]?, _ error: Error?) -> ()) {
        networking.sendGetRequest(endpoint: .faves(userId: userId)) { response, error in
            guard let faves = response as? [Int] else {
                completion(nil, error)

                return
            }

            completion(faves, error)
        }
    }

    func addFave(userId: Int, listId: Int, itemId: Int, note: String = "", completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {

        let data: [String: String] = [
            "listId": "\(listId)",
            "itemId": "\(itemId)",
            "note": note
        ]

        networking.sendPostRequest(endpoint: .faves(userId: userId), data: data) { response, error in
            guard let itemData = response as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let item = Item(data: itemData)

            completion(item, error)
        }
    }

    func removeFave(userId: Int, itemId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {

        let data: [String: String] = [
            "dataId": "\(itemId)"
        ]

        networking.sendDeleteRequest(endpoint: .faves(userId: userId), data: data) { response, error in
            guard let responseData = response as? [String: AnyObject] else {
                completion(false, error)

                return
            }

            var success = false
            if let message = responseData["message"] as? String, message == "ok" {
                success = true
            }

            completion(success, error)
        }
    }
}

extension FaveGraphQLService: FaveServiceType {}
