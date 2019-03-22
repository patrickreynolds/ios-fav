import Foundation

struct Item {
    let name: String
    let description: String
    let followers: [User]

    init(name: String, description: String = "", followers: [User] = []) {
        self.name = name
        self.description = description
        self.followers = followers
    }
}
