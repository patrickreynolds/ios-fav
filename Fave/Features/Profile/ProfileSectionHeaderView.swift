import Foundation
import UIKit
import Cartography

protocol ProfileTableSectionHeaderViewDelegate {
    func listsButtonTapped()
}

class ProfileTableSectionHeaderView: UIView {

    var delegate: ProfileTableSectionHeaderViewDelegate?
    var lists: [List] {
        didSet {
            let titleString = self.lists.count == 1 ? "\(self.lists.count) List" : "\(self.lists.count) Lists"
            let attributedTitle = NSAttributedString(string: titleString,
                font: FaveFont(style: .small, weight: .semiBold).font,
                textColor: FaveColors.Black70)

            listsButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }

    private lazy var listsButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = FaveColors.Black20

        let titleString = self.lists.count == 1 ? "\(self.lists.count) List" : "\(self.lists.count) Lists"

        let attributedTitle = NSAttributedString(string: titleString,
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Black70)

        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    init(lists: [List]) {
        self.lists = lists

        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.Black20

        addSubview(listsButton)

        constrain(listsButton, self) { button, view in
            button.top == view.top + 8
            button.left == view.left + 16
            button.bottom == view.bottom
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLists(lists: [List]) {
        self.lists = lists
    }

    @objc func listButtonTapped(sender: UIButton!) {
        print("\n\nList Button Tapped\n\n")
        delegate?.listsButtonTapped()
    }
}
