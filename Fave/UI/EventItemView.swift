//
//  EventItemView.swift
//  Fave
//
//  Created by Patrick Reynolds on 5/16/19.
//  Copyright © 2019 Patrick Reynolds. All rights reserved.
//

import Foundation
import UIKit

import Cartography

class EventItemView: UIView {

    private lazy var titleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .semiBold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

        return label
    }()


    private lazy var subtitleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black70,
                               textAlignment: .left,
                               numberOfLines: 0)

        return label
    }()

    init(item: String = "", list: String = "") {
        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.White
        layer.borderColor = FaveColors.Black20.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
        layer.masksToBounds = true
        clipsToBounds = true

        addSubview(titleLabel)
        addSubview(subtitleLabel)

        constrain(titleLabel, subtitleLabel, self) { titleLabel, subtitleLabel, view in
            titleLabel.top == view.top + 16
            titleLabel.right == view.right - 16
            titleLabel.left == view.left + 16

            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.right == titleLabel.right
            subtitleLabel.bottom == view.bottom - 16
            subtitleLabel.left == titleLabel.left
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withEvent event: TempFeedEvent) {
        titleLabel.text = event.item
        subtitleLabel.text = event.list
    }
}
