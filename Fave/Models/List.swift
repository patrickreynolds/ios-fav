import Foundation

class List {
    let id: Int
    let title: String
    let description: String
    let isPublic: Bool
    let numberOfFollowers: Int
    let numberOfItems: Int
    let numberOfSuggestions: Int
    let items: [Item]
    let owner: User
    let url: String

    init(id: Int, title: String, description: String = "", isPublic: Bool = true, numberOfFollowers: Int = 0, numberOfItems: Int = 0, numberOfSuggestions: Int = 0, items: [Item] = [], owner: User, url: String = "") {
        self.id = id
        self.title = title
        self.description = description
        self.isPublic = isPublic
        self.numberOfFollowers = numberOfFollowers
        self.numberOfItems = numberOfItems
        self.numberOfSuggestions = numberOfSuggestions
        self.items = items
        self.owner = owner
        self.url = url
    }

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int,
            let title = data["title"] as? String,
            let isPublic = data["isPublic"] as? Int,
            let userData = data["owner"] as? [String: AnyObject],
            let owner = User(data: userData) else {
                return nil
        }

        var items: [Item] = []

        if let itemData = data["items"] as? [[String: AnyObject]] {
            items = itemData.map { data in
                return Item(data: data)
            }.compactMap({ $0 })
        }

        let description = data["description"] as? String ?? ""

        var numberOfFollowers = 0
        if let followerCount = data["numberOfFollowers"] as? Int {
            numberOfFollowers = followerCount
        }

        var numberOfItems = 0
        if let itemCount = data["numberOfItems"] as? Int {
            numberOfItems = itemCount
        }

        var numberOfSuggestions = 0
        if let suggestionCount = data["numberOfSuggestions"] as? Int {
            numberOfSuggestions = suggestionCount
        }

        let url = ""

        self.id = id
        self.title = title
        self.numberOfFollowers = numberOfFollowers
        self.numberOfItems = numberOfItems
        self.numberOfSuggestions = numberOfSuggestions
        self.items = items
        self.isPublic = isPublic == 1 ? true : false
        self.description = description
        self.owner = owner
        self.url = url
    }
}
