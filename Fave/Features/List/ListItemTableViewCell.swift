import Foundation
import UIKit

import Cartography

class EntryTableViewCell: UITableViewCell {
    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                           font: FaveFont(style: .h5, weight: .semiBold),
                           textColor: FaveColors.Black90,
                           textAlignment: .left,
                           numberOfLines: 1)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .small, weight: .regular),
                          textColor: FaveColors.Black60,
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
        contentView.addSubview(subtitleLabel)

//        contentView.addSubview(navigationIndicatorImageView)

        contentView.addSubview(borderView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16

        }

        constrain(subtitleLabel, titleLabel, borderView) { subtitleLabel, titleLabel, view in
            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.right == titleLabel.right
            subtitleLabel.left == titleLabel.left
            subtitleLabel.bottom == view.bottom - 16
        }

        constrain(borderView, contentView) { borderView, view in
            borderView.left == view.left
            borderView.right == view.right
            borderView.bottom == view.bottom
            borderView.height == 4
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item) {
        titleLabel.text = item.contextualItem.name
        subtitleLabel.text = item.note

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

//        var keywords = ""
//        var counter = 0
//        googleItem.keywords?.forEach { keyword in
//            if counter < 2 {
//                keywords += "\(keyword), "
//                counter += 1
//            }
//        }
//
//        subtitleLabel.text = keywords
    }
}
