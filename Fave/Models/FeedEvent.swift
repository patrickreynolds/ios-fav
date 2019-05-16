import Foundation

struct FeedEvent {
    let user: User
    let list: List
    let item: Item

    init(user: User, list: List, item: Item) {
        self.user = user
        self.list = list
        self.item = item
    }

    init?(data: [String: AnyObject]) {
        guard let userData = data["user"] as? [String: AnyObject],
              let listData = data["list"] as? [String: AnyObject],
              let itemData = data["item"] as? [String: AnyObject] else {
                return nil
        }

        guard let user = User.init(data: userData),
              let list = List.init(data: listData),
              let item = Item.init(data: itemData) else {
                return nil
        }

        self.user = user
        self.list = list
        self.item = item
    }
}

struct TempFeedEvent {
    let item: String
    let user: String
    let list: String

    init?(data: [String: AnyObject]) {
        guard let user = data["user"] as? String,
              let list = data["list"] as? String,
              let item = data["item"] as? String else {
                  return nil
        }

        self.user = user
        self.list = list
        self.item = item
    }
}
