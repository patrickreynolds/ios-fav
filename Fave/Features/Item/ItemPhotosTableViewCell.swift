import Foundation
import UIKit

import Cartography

protocol ItemPhotosTableViewCellDelegate {
    func didSelectItemPhoto() // item: Item, photo: Photo
}


// Google Places API for photo references
// https://developers.google.com/places/web-service/photos

class ItemPhotosTableViewCell: UITableViewCell {

    var item: Item?
    var delegate: ItemPhotosTableViewCellDelegate?

    private lazy var titleLabel: Label = {
        let label = Label(text: "Photos",
                          font: FaveFont(style: .h4, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(dividerView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16
            label.bottom == view.bottom - 120
        }

        constrain(dividerView, self) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left
            dividerView.height == 4
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item) {
        self.item = item

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }
    }
    
}
