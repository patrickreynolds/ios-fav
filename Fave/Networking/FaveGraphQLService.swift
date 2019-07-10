import Foundation

struct FaveGraphQLService {
    private let networking: NetworkingType

    init(networking: NetworkingType) {
        self.networking = networking
    }

    func getCurrentUser(completion: @escaping (_ user: User?, _ error: Error?) -> ()) {

        let meQuery = GraphQLQueryBuilder.meQuery()

        networking.sendGraphqlRequest(query: meQuery) { response, error in
            guard let userResponse = response as? [String: AnyObject], let userData = userResponse["me"] as? [String: AnyObject], let user = User(data: userData) else {
                completion(nil, error)

                return
            }

            completion(user, error)
        }
    }

    func getUser(userId: Int, completion: @escaping (User?, Error?) -> ()) {

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

    func updateUser(firstName: String, lastName: String, email: String, handle: String, bio: String, completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
        let updateUserMutationString = GraphQLQueryBuilder.updateUserMutation(firstName: firstName, lastName: lastName, email: email, handle: handle, bio: bio)

        networking.sendGraphqlRequest(query: updateUserMutationString) { response, error in
            guard let unwrappedResponse = response, let userData = unwrappedResponse["user"] as? [String: AnyObject], let user = User(data: userData) else {
                completion(nil, error)

                return
            }

            completion(user, error)
        }
    }

    func getLists(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {

        let listsQueryString = GraphQLQueryBuilder.listsQuery(userId: userId)

        networking.sendGraphqlRequest(query: listsQueryString) { response, error in
            guard let unwrappedResponse = response, let listData = unwrappedResponse["lists"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let faveLists = listData.map({ List(data: $0)}).compactMap({ $0 })

            let filteredLists = faveLists.filter({ $0.title.lowercased() != "recommendations" && $0.title.lowercased() != "saved for later" })

            completion(faveLists, error)
        }
    }

    func getList(userId: Int, listId: Int, completion:  @escaping (_ lists: List?, _ error: Error?) -> ()) {

        let listQueryString = GraphQLQueryBuilder.listQuery(listId: listId)

        networking.sendGraphqlRequest(query: listQueryString) { response, error in
            guard let listResponse = response as? [String: AnyObject], let listData = listResponse["list"] as? [String: AnyObject], let list = List(data: listData) else {
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

        let createGooglePlacesItemMutation = GraphQLQueryBuilder.createGooglePlacesItemMutation(userId: userId, listId: listId, googlePlacesId: placeId, note: note)

        networking.sendGraphqlRequest(query: createGooglePlacesItemMutation) { (response, error) in
            guard let itemResponse = response as? [String: AnyObject], let itemData = itemResponse["placeItem"] as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let item = Item(data: itemData)

            completion(item, error)
        }
    }

    func getListItems(userId: Int, listId: Int, completion: @escaping (_ items: [Item]?, _ error: Error?) -> ()) {

        let listQueryString = GraphQLQueryBuilder.listQuery(listId: listId)

        networking.sendGraphqlRequest(query: listQueryString) { response, error in
            guard let listResponse = response as? [String: AnyObject], let listData = listResponse["list"] as? [String: AnyObject], let list = List(data: listData) else {
                completion(nil, error)

                return
            }

            completion(list.items, error)
        }
    }

    func getListItem(userId: Int, listId: Int, itemId: Int, completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {

        let itemQuery = GraphQLQueryBuilder.getItem(itemId: itemId)

        networking.sendGraphqlRequest(query: itemQuery) { response, error in
            guard let itemResponse = response as? [String: AnyObject], let itemData = itemResponse["item"] as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let item = Item(data: itemData)

            completion(item, nil)
        }
    }

    func deleteListItem(itemId: Int, completion: @escaping (_ itemId: Int?, _ error: Error?) -> ()) {

        let itemMutation = GraphQLQueryBuilder.deleteItem(itemId: itemId)

        networking.sendGraphqlRequest(query: itemMutation) { response, error in
            guard let itemResponse = response as? [String: AnyObject], let itemData = itemResponse["deleteItem"] as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let itemId = itemData["id"] as? Int

            completion(itemId, nil)
        }
    }

    func updateListItem(itemId: Int, listId: Int, isRecommendation: Bool, completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {

        let updateListItemMutation = GraphQLQueryBuilder.updateItemMutation(itemId: itemId, listId: listId, isRecommendation: isRecommendation)

        networking.sendGraphqlRequest(query: updateListItemMutation) { response, error in
            guard let itemResponse = response as? [String: AnyObject], let itemData = itemResponse["deleteItem"] as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let item = Item(data: itemData)

            completion(item, nil)
        }
    }

    func getFeed(from: Int, to: Int, completion: @escaping (_ events: [FeedEvent]?, _ error: Error?) -> ()) {

        let feedQuery = GraphQLQueryBuilder.feedQuery(from: from, to: to)

        networking.sendGraphqlRequest(query: feedQuery) { response, error in
            guard let eventResponse = response, let eventData = eventResponse["feed"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let feedEvents = eventData.map({ FeedEvent(data: $0 )}).compactMap { $0 }

            completion(feedEvents, error)
        }
    }

    func suggestions(completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
        let suggestionsQuery = GraphQLQueryBuilder.listSuggestions()

        networking.sendGraphqlRequest(query: suggestionsQuery) { response, error in
            guard let suggestionResponse = response as? [String: AnyObject], let suggestionData = suggestionResponse["suggestions"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let suggestions = suggestionData.map({ List(data: $0 )}).compactMap { $0 }

            completion(suggestions, error)
        }
    }

    /*
     TODO: Skipping for now
     */
    func topLists(completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {

        let topListsQuery = GraphQLQueryBuilder.getTopLists()

        networking.sendGraphqlRequest(query: topListsQuery) { response, error in
            guard let listResponse = response, let listData = listResponse["topTenLists"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let lists = listData.map({ List(data: $0 )}).compactMap { $0 }

            completion(lists, error)
        }

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

//        delay(3.0) {
//            completion(topLists, nil)
//        }
    }

    func getUsers(completion: @escaping (_ lists: [User]?, _ error: Error?) -> ()) {

        let usersQuery = GraphQLQueryBuilder.getUsers()

        networking.sendGraphqlRequest(query: usersQuery) { response, error in
            guard let userResponse = response, let userData = userResponse["users"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let users = userData.map({ User(data: $0 )}).compactMap { $0 }

            completion(users, error)
        }
    }

    func followersOfList(listId: Int, completion: @escaping (_ lists: [User]?, _ error: Error?) -> ()) {
        let listQueryString = GraphQLQueryBuilder.listQuery(listId: listId)

        networking.sendGraphqlRequest(query: listQueryString) { response, error in
            guard let listResponse = response as? [String: AnyObject], let listData = listResponse["list"] as? [String: AnyObject], let list = List(data: listData) else {
                completion(nil, error)

                return
            }

            completion(list.followers, error)
        }
    }

    func listsUserFollows(userId: Int, completion: @escaping (_ lists: [List]?, _ error: Error?) -> ()) {
        let listsUserFollowsQuery = GraphQLQueryBuilder.listsUserFollows(userId: userId)

        networking.sendGraphqlRequest(query: listsUserFollowsQuery) { response, error in
            guard let listsResponse = response, let listsUserFollowsData = listsResponse["lists"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let listsUserFollows = listsUserFollowsData.map({ List(data: $0 )}).compactMap { $0 }

            completion(listsUserFollows, error)
        }
    }

    func followList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {

        let followListQuery = GraphQLQueryBuilder.followList(listId: listId)

        networking.sendGraphqlRequest(query: followListQuery) { response, error in
            guard let statusResponse = response as? [String: AnyObject], let status = statusResponse["status"] as? Bool else {
                completion(false, error)

                return
            }

            completion(status, error)
        }
    }

    func unfollowList(listId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {

        let unfollowListQuery = GraphQLQueryBuilder.unfollowList(listId: listId)

        networking.sendGraphqlRequest(query: unfollowListQuery) { response, error in
            guard let statusResponse = response as? [String: AnyObject], let status = statusResponse["status"] as? Bool else {
                completion(false, error)

                return
            }

            completion(status, error)
        }
    }

    func getFaves(userId: Int, completion: @escaping (_ faveIds: [Int]?, _ error: Error?) -> ()) {

        let myFavesQuery = GraphQLQueryBuilder.myFavesQuery()

        networking.sendGraphqlRequest(query: myFavesQuery) { response, error in
            guard let faveResponse = response as? [String: AnyObject], let faves = faveResponse["faves"] as? [Int] else {
                completion(nil, error)

                return
            }

            completion(faves, error)
        }
    }

    /*
        TODO: Double check that this works after the myFaves is updated
     */
    func addFave(userId: Int, listId: Int, itemId: Int, note: String = "", completion: @escaping (_ item: Item?, _ error: Error?) -> ()) {

        let faveItemQuery = GraphQLQueryBuilder.faveItemMutation(listId: listId, itemId: itemId, note: note)

        networking.sendGraphqlRequest(query: faveItemQuery) { response, error in
            guard let itemResponse = response as? [String: AnyObject], let itemData = itemResponse["item"] as? [String: AnyObject] else {
                completion(nil, error)

                return
            }

            let item = Item(data: itemData)

            completion(item, error)
        }
    }

    /*
     TODO: Double check that this works after the myFaves is updated
     */
    func removeFave(userId: Int, itemId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {

        let unFaveMutationString = GraphQLQueryBuilder.unFaveMutation(itemId: itemId)

        networking.sendGraphqlRequest(query: unFaveMutationString) { response, error in
            guard let statusResponse = response as? [String: AnyObject], let status = statusResponse["status"] as? Bool else {
                completion(false, error)

                return
            }

            completion(status, error)
        }
    }

    func myItems(completion: @escaping (_ items: [Item]?, _ error: Error?) -> ()) {

        let myItemsQuery = GraphQLQueryBuilder.myItemsQuery()

        networking.sendGraphqlRequest(query: myItemsQuery) { response, error in
            guard let unwrappedResponse = response, let itemData = unwrappedResponse["items"] as? [[String: AnyObject]] else {
                completion(nil, error)

                return
            }

            let items = itemData.map({ Item(data: $0)}).compactMap({ $0 })

            completion(items, error)
        }

    }
}

extension FaveGraphQLService: FaveServiceType {}
