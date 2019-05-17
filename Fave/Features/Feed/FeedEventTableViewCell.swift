import Foundation
import UIKit

import Cartography

class FeedEventTableViewCell: UITableViewCell {
    private lazy var titleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 1)

        return label
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.White

        return view
    }()

    private lazy var eventItemView: EventItemView = {
        let view = EventItemView()

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(eventItemView)
        contentView.addSubview(borderView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 8
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(eventItemView, titleLabel, contentView) { eventItemView, titleLabel, contentView in
            eventItemView.top == titleLabel.bottom + 8
            eventItemView.right == contentView.right - 16
            eventItemView.bottom == contentView.bottom - 16
            eventItemView.left == titleLabel.left
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

    func populate(event: TempFeedEvent) {
        titleLabel.text = "\(event.user) added an item."

        eventItemView.update(withEvent: event)
    }
}
