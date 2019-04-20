import Foundation
import UIKit

import Cartography

protocol DiscoverUserTableViewCellDelegate {
//    func faveItemButtonTapped(item: Item)
//    func shareItemButtonTapped(item: Item)
}

class DiscoverUserTableViewCell: UITableViewCell {

    var item: Item?
    var delegate: DiscoverUserTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item) {

    }
}

