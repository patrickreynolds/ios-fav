import Foundation
import UIKit

import Cartography

class EntryTableViewCell: UITableViewCell {
    private lazy var titleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .semiBold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 1)

        return label
    }()

    private lazy var navigationIndicatorImageView: UIView = {
        let imageView = UIImageView(frame: CGRect.zero)

        imageView.image = UIImage(named: "icon-small-chevron")
        imageView.tintColor = FaveColors.Black60

        return imageView
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black10

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)

        contentView.addSubview(navigationIndicatorImageView)

        contentView.addSubview(borderView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 16
            label.bottom == view.bottom - 16
            label.left == view.left + 16
        }

        constrain(navigationIndicatorImageView, titleLabel, contentView) { imageView, titleLabel, view in
            imageView.left == titleLabel.right + 8
            imageView.right == view.right - 16
            imageView.centerY == titleLabel.centerY
            imageView.height == 16
            imageView.width == 16
        }

        constrain(borderView, contentView) { borderView, view in
            borderView.left == view.left + 16
            borderView.right == view.right - 16
            borderView.bottom == view.bottom
            borderView.height == 1
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item) {
        titleLabel.text = item.title
    }
}
