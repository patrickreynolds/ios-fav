import Foundation

struct TopList {
    let name: String
    let owner: String
    let items: [TopListItem]
}

struct TopListItem {
    let name: String
    let type: String
}
