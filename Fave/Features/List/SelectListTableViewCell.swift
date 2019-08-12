import UIKit

import Cartography

class SelectListTableViewCell: UITableViewCell {
    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                               font: FaveFont(style: .h5, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 1)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "",
                               font: FaveFont(style: .small, weight: .regular),
                               textColor: FaveColors.Black70,
                               textAlignment: .left,
                               numberOfLines: 1)

        return label
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(borderView)

        constrain(titleLabel, subtitleLabel, borderView, contentView) { titleLabel, subtitleLabel, borderView, view in
            titleLabel.top == view.top + 20
            titleLabel.right == view.right - 16
            titleLabel.left == view.left + 16

            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.left == titleLabel.left
            subtitleLabel.right == titleLabel.right
            subtitleLabel.bottom == borderView.top - 20

            borderView.left == view.left + 16
            borderView.right == view.right - 16
            borderView.bottom == view.bottom
            borderView.height == 1
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

    func populate(list: List) {
        titleLabel.text = list.title
        subtitleLabel.text = list.numberOfItems == 1 ? "\(list.numberOfItems) item" : "\(list.numberOfItems) items"
    }
}
