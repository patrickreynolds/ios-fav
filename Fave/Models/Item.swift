//
//  Item.swift
//  Fave
//
//  Created by Patrick Reynolds on 3/18/19.
//  Copyright © 2019 Patrick Reynolds. All rights reserved.
//

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
