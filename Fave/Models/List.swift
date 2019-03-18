//
//  List.swift
//  Fave
//
//  Created by Patrick Reynolds on 3/18/19.
//  Copyright © 2019 Patrick Reynolds. All rights reserved.
//

import Foundation

struct List {
    let title: String
    let followers: Int
    let items: [Item]

    init(title: String, followers: Int, items: [Item] = []) {
        self.title = title
        self.followers = followers
        self.items = items
    }
}
