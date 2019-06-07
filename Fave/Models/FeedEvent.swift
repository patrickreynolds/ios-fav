import Foundation

struct EventUser {

    let id: Int
    let handle: String
    let firstName: String
    let lastName: String
    let profilePicture: String

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int,
              let handle = data["handle"] as? String,
              let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let profilePicture = data["profilePic"] as? String else {
                  return nil
        }

        self.id = id
        self.handle = handle
        self.firstName = firstName
        self.lastName = lastName
        self.profilePicture = profilePicture
    }
}

struct EventList {

    let id: Int
    let title: String
    let description: String

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int,
              let title = data["title"] as? String,
              let description = data["description"] as? String else {
                  return nil
        }

        self.id = id
        self.title = title
        self.description = description
    }
}

struct EventItem {

    let id: Int
    let dataId: Int
    let title: String
    let note: String
    let createdAt: Date

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int,
              let dataId = data["dataId"] as? Int,
              let title = data["title"] as? String,
              let note = data["note"] as? String,
              let createdAtString = data["createdAt"] as? String else {
                  return nil
        }

        let dateFormatter = DateFormatter()
        // "2019-04-03T13:57:03.000Z"
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"

        guard let createdAtDate = dateFormatter.date(from: createdAtString) else {
            return nil
        }

        self.id = id
        self.dataId = dataId
        self.title = title
        self.note = note
        self.createdAt = createdAtDate
    }
}

struct FeedEvent {
    let user: User
    let list: List
    let item: Item

    init?(data: [String: AnyObject]) {
        guard let userData = data["user"] as? [String: AnyObject],
              let listData = data["list"] as? [String: AnyObject],
              let itemData = data["item"] as? [String: AnyObject] else {
                return nil
        }

        guard let user = User(data: userData),
              let list = List(data: listData),
              let item = Item(data: itemData) else {
                return nil
        }

        self.user = user
        self.list = list
        self.item = item
    }
}
