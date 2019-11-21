import Foundation

protocol SavedItemType {
    var dataId: Int { get }
    var listId: Int { get }
    var listTitle: String { get }
    var isRecommendation: Bool { get }
}

struct SavedItem {
    let dataId: Int
    let listId: Int
    let listTitle: String
    let isRecommendation: Bool

    init?(data: [String: AnyObject]) {

        guard let dataId = data["dataId"] as? Int else {
            return nil
        }

        guard let listData = data["list"] as? [String: AnyObject] else {
            return nil
        }

        guard let listId = listData["id"] as? Int else {
            return nil
        }

        guard let listTitle = listData["title"] as? String else {
            return nil
        }

        let isRecommendation = data["isRecommendation"] as? Bool ?? false

        self.dataId = dataId
        self.listId = listId
        self.listTitle = listTitle
        self.isRecommendation = isRecommendation

    }
}

extension SavedItem: SavedItemType {}
