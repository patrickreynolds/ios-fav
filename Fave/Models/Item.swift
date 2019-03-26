import Foundation

struct Item {
    let id: Int
    let title: String
    let description: String

    init(id: Int, title: String, description: String = "") {
        self.id = id
        self.title = title
        self.description = description
    }

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int,
            let title = data["title"] as? String else {
                return nil
        }

        let description = data["description"] as? String ?? ""

        self.id = id
        self.title = title
        self.description = description
    }
}
