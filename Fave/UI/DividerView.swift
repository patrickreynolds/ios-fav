//
//  Divider.swift
//  Fave
//
//  Created by Patrick Reynolds on 3/21/19.
//  Copyright © 2019 Patrick Reynolds. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class DividerView: UIView {
    init(backgroundColor: UIColor = FaveColors.Black20, height: CGFloat = 1.0) {
        super.init(frame: CGRect.zero)

        let divider = UIView.init(frame: .zero)
        divider.backgroundColor = backgroundColor

        addSubview(divider)

        constrainToSuperview(divider)

        constrain(divider) { divider in
            divider.height == height
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
