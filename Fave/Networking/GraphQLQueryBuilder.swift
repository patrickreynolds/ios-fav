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

        // TODO: Add bio when I putt the latest from Albert

        return """
            mutation {
                user: updateUser(input: { firstName: "\(firstName)", lastName: "\(lastName)", email: "\(email)", handle: "\(handle)"}) {
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

    static func createGooglePlacesItemMutation(listId: Int, googlePlacesId: String, note: String) -> String {
        return """
            mutation {
                placeItem: addGooglePlaceListItem(listId: \(listId), googlePlaceId: "\(googlePlacesId)", note: "\(note)") {
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

    static func getItem(itemId: Int) -> String {

        return """
            query {
                item(itemId: \(itemId)) { \(itemString()) }
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

    static func followList(listId: Int) -> String {
        return """
            mutation {
                status: followList(listId: \(listId))
            }
        """
    }

    static func unfollowList(listId: Int) -> String {
        return """
            mutation {
                status: unfollowList(listId: \(listId))
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
}
