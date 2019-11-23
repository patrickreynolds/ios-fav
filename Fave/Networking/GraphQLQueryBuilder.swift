import Foundation

struct GraphQLQueryBuilder {

    private static func userString(isPrivate: Bool = false) -> String {
        return """
            id
            firstName
            lastName
            \(isPrivate ? "email" : "")
            handle
            profilePic
            updatedAt
            createdAt
            bio
        """
    }

    private static func itemString() -> String {
        return """
            id
            dataId
            title
            type
            createdAt
            updatedAt
            note
            isRecommendation
            list {
                id
                title
            }
            recommendedBy {
                \(userString())
            }
            owner {
                \(userString())
            }
            numberOfFaves
            friendsWhoLikeItem {
                \(userString())
            }
            dataItem {
                connectorId
                connectorType
                content {
                    ... on GooglePlace {
                        name
                        vicinity
                        website
                        placeId
                        formattedAddress
                        internationalPhoneNumber
                        formattedPhoneNumber
                        rating
                        types
                        geometry {
                            location {
                                lat
                                lng
                            }
                        }
                        photos {
                            width
                            height
                            photoReference
                        }
                        savedPhotos
                    }
                }
            }
        """
    }

    static func listString(owner: Bool = true, followers: Bool = true, items: Bool = true) -> String {
        return """
            id
            title
            isPublic
            description
            \(owner ? "owner { \(userString()) }" : "")
            \(followers ? "followers { \(userString()) }" : "")
            \(items ? "items { \(itemString()) }" : "")
        """
    }

    static func externalLoginMutation(network: String, accessToken: String, handle: String = "") -> String {

        return """
            mutation {
                externalLogin(network: "\(network)", accessToken: "\(accessToken)", handle: "\(handle)") {
                    token,
                    user { \(userString(isPrivate: true)) }
                }
            }
        """
    }

    static func meQuery() -> String {

        return """
            query {
                me { \(userString(isPrivate: true)) }
            }
        """
    }

    static func userQuery(userId: Int) -> String {

        return """
            query {
                user(userId: \(userId)) { \(userString()) }
            }
        """
    }

    static func updateUserMutation(firstName: String, lastName: String, email: String, handle: String, bio: String) -> String {

        return """
            mutation {
                user: updateUser(input: { firstName: "\(firstName)", lastName: "\(lastName)", email: "\(email)", handle: "\(handle)", bio: "\(bio)"}) {
                    \(userString(isPrivate: true))
                }
            }
        """
    }

    static func listsQuery(userId: Int) -> String {

        return """
            query {
                lists(userId: \(userId)) {
                    \(listString())
                }
            }
        """
    }

    static func createListMutation(userId: Int, title: String, description: String, isPublic: Bool) -> String {

        return """
            mutation {
                list: addList(title: "\(title)", description: "\(description)", isPublic: \(isPublic)) {
                    \(listString(followers: false, items: false))
                }
            }
        """
    }

    static func createGooglePlacesItemMutation(userId: Int, listId: Int, googlePlacesId: String, note: String) -> String {
        return """
            mutation {
                placeItem: addGooglePlaceListItem(addedBy: \(userId), listId: \(listId), googlePlaceId: "\(googlePlacesId)", note: "\(note)") {
                    \(itemString())
                }
            }
        """
    }

    static func listQuery(listId: Int) -> String {

        return """
            query {
                list(listId: \(listId)) { \(listString()) }
            }
        """
    }

    static func removeListMutation(listId: Int) -> String {
        return """
            mutation {
                deleteList(listId: \(listId)) { id }
            }
        """
    }

    static func updateListMutation(listId: Int, title: String, description: String, isPublic: Bool) -> String {
        // TODO: Update the isPublic

        return """
            mutation {
                updateList(listId: \(listId), input: { title: "\(title)", description: "\(description)", isPublic: \(isPublic) }) { \(listString()) }
            }
        """
    }

    static func getItem(itemId: Int) -> String {

        return """
            query {
                item(itemId: \(itemId)) { \(itemString()) }
            }
        """
    }

    static func updateItemMutation(itemId: Int, listId: Int, note: String, isRecommendation: Bool) -> String {

        // TODO: Update the placeId

        return """
            mutation {
                updateItem(itemId: \(itemId), listId: \(listId), input: { note: "\(note)", isRecommendation: \(isRecommendation) }) { \(itemString()) }
            }
        """
    }

    static func removeItem(itemId: Int) -> String {
        return """
            mutation {
                deleteItem(itemId: \(itemId)) { id }
            }
        """
    }

    static func getUsers() -> String {
        return """
            query {
                users { \(userString()) }
            }
        """
    }

    static func listsUserFollows(userId: Int) -> String {
        return """
            query {
                lists: listsUserFollows(userId: \(userId)) {
                    \(listString())
                }
            }
        """
    }

    static func listSuggestions() -> String {
        return """
            query {
                suggestions: listSuggestions {
                    \(listString(owner: true, followers: true, items: true))
                }
            }
        """
    }

    static func faveItemMutation(listId: Int, itemId: Int, note: String) -> String {
        return """
            mutation {
                item: fave(listId: \(listId), itemId: \(itemId), note: "\(note)") {
                    \(itemString())
                }
            }
        """
    }

    static func unFaveMutation(itemId: Int) -> String {
        return """
            mutation {
                status: unfave(itemId: \(itemId))
            }
        """
    }

    static func myFavesQuery() -> String {
        return """
            query {
                faves: myFaves
            }
        """
    }

    static func feedQuery(from: Int, to: Int) -> String {
        return """
            query {
                feed(from: \(from), to: \(to)) {
                    ... on FeedEvent {
                        item {
                            \(itemString())
                        }
                        list {
                            \(listString(owner: true, followers: true, items: false))
                        }
                        user {
                            \(userString())
                        }
                    }
                }
            }
        """
    }

    static func myItemsQuery() -> String {
        return """
            query {
                items: myItems {
                    \(itemString())
                }
            }
        """
    }

    static func mySavedItems() -> String {
        return """
            query {
                savedItems: myItems {
                    dataId
                    isRecommendation
                    list {
                        id
                        title
                    }
                }
            }
        """
    }

    static func getTopLists() -> String {
        return """
            query {
                topTenLists {
                    \(listString(owner: true, followers: false, items: true))
                }
            }
        """
    }

    static func eventMutation(event: AnalyticsEvent) -> String {
        var userId: Int?

        if let eventUserId = event.userId, let userIdInt = Int(eventUserId) {
            userId = userIdInt
        }

        if let userId = userId {
            return """
                mutation {
                    status: logEvent(userId: \(userId), type: "\(event.eventName)", data: {deviceId: "\(event.deviceId)"})
                }
            """
        } else {
            return """
                mutation {
                    status: logEvent(type: "\(event.eventName)", data: {deviceId: "\(event.deviceId)"})
                }
            """
        }
    }

    static func submitFeedbackMutation(feedback: String) -> String {
        return """
            mutation {
                success: submitFeedback(feedback: "\(feedback)")
            }
        """
    }

    static func addDeviceTokenMutation(deviceToken: String, uuid: String) -> String {
        // success: addDeviceToken(deviceToken: "\(deviceToken)", uuid: "\(uuid)")

        return """
            mutation {
                success: addDeviceToken(deviceToken: "\(deviceToken)")
            }
        """
    }

    static func followUserMutation(userId: Int) -> String {

        return """
            mutation {
                success: followUser(userId: \(userId))
            }
        """
    }

    static func unfollowUserMutation(userId: Int) -> String {

        return """
            mutation {
                success: unfollowUser(userId: \(userId))
            }
        """
    }

    static func usersUserFollows(userId: Int) -> String {
        return """
            query {
                following: usersUserFollows(userId: \(userId)) {
                    id
                }
            }
        """
    }

}
