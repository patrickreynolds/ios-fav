//
//  Friend.swift
//  Fave
//
//  Created by Patrick Reynolds on 3/28/19.
//  Copyright © 2019 Patrick Reynolds. All rights reserved.
//

import Foundation

struct Friend {
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
