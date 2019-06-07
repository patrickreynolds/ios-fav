import Foundation

class List {
    let id: Int
    let title: String
    let description: String
    let isPublic: Bool
    let numberOfFollowers: Int
    let numberOfItems: Int
    let numberOfRecommendations: Int
    let items: [Item]
    let followers: [User]
    let owner: User
    let url: String
    var isUserFollowing: Bool? = nil

    init(id: Int, title: String, description: String = "", isPublic: Bool = true, numberOfFollowers: Int = 0, numberOfItems: Int = 0, numberOfRecommendations: Int = 0, items: [Item] = [], followers: [User] = [], owner: User, url: String = "") {
        self.id = id
        self.title = title
        self.description = description
        self.isPublic = isPublic
        self.numberOfFollowers = numberOfFollowers
        self.numberOfItems = numberOfItems
        self.numberOfRecommendations = numberOfRecommendations
        self.items = items
        self.followers = followers
        self.owner = owner
        self.url = url
    }

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int,
            let title = data["title"] as? String,
            let isPublic = data["isPublic"] as? Bool,
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

        var followers: [User] = []

        if let followerData = data["followers"] as? [[String: AnyObject]] {
            followers = followerData.map { data in
                return User(data: data)
            }.compactMap({ $0 })
        }

        let recommendations: [Item] = items.filter { item in
            return item.isRecommendation
        }

        let description = data["description"] as? String ?? ""
        let url = ""

        self.id = id
        self.title = title
        self.followers = followers
        self.numberOfFollowers = followers.count
        self.numberOfItems = items.count
        self.numberOfRecommendations = recommendations.count
        self.items = items
        self.isPublic = isPublic
        self.description = description
        self.owner = owner
        self.url = url
    }
}
