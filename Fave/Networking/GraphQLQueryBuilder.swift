import Foundation

struct GraphQLQueryBuilder {

    static func externalLoginMutation(network: String, accessToken: String, handle: String = "") -> String {

        return """
            mutation {
                externalLogin(network: "\(network)", accessToken: "\(accessToken)", handle: "\(handle)") {
                    token,
                    user { id, firstName, lastName, email, handle, profilePic }
                }
            }
        """
    }

    static func userQuery(userId: Int) -> String {

        return """
            query {
                user(userId: \(userId)) {
                    id, firstName, lastName, handle, profilePic
                }
            }
        """
    }

    static func listsQuery(userId: Int) -> String {

        return """
            query {
                lists(userId: \(userId)) {
                    id,
                    title,
                    isPublic,
                    description,
                    owner { id, firstName, lastName, handle, profilePic },
                    followers { id, firstName, lastName, handle, profilePic }
                    items { id, dataId, type, updatedAt, createdAt, listId, createdAt, updatedAt, note }
                }
            }
        """
    }

    static func createListMutation(userId: Int, title: String, description: String, isPublic: Bool) -> String {

        return """
            mutation {
                list: addList(title: "\(title)", description: "\(description)", isPublic: \(isPublic)) {
                    id
                    title
                    isPublic
                    description
                    owner { id, firstName, lastName, handle, profilePic }
                }
            }
        """
    }

    static func createGooglePlacesItem(listId: Int, googlePlacesId: String, note: String) -> String {
        return """
        mutation {
        addGooglePlaceListItem(listId: \(listId), googlePlaceId: "\(googlePlacesId)", note: "\(note)") {
        id
        dataId
        type
        updatedAt
        createdAt
        listId
        createdAt
        updatedAt
        note
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
        types
        }
        }
        }
        }
        }
            """
    }
}

