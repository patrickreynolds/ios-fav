import Foundation

class List {
    let id: Int
    let title: String
    let description: String
    let isPublic: Bool
    let followers: Int
    let items: [Item]

    init(id: Int, title: String, description: String = "", isPublic: Bool = true, followers: Int = 0, items: [Item] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.isPublic = isPublic
        self.followers = followers
        self.items = items
    }

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int,
            let title = data["title"] as? String,
            let isPublic = data["isPublic"] as? Int else {
                return nil
        }

        var items: [Item] = []

        if let itemData = data["items"] as? [[String: AnyObject]] {
            items = itemData.map { data in
                return Item(data: data)
            }.compactMap({ $0 })
        }

        let description = data["description"] as? String ?? ""

        let followers = 0

        self.id = id
        self.title = title
        self.followers = followers
        self.items = items
        self.isPublic = isPublic == 1 ? true : false
        self.description = description
    }
}
