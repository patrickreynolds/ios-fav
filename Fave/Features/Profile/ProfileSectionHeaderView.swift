import Foundation
import UIKit
import Cartography

protocol ProfileTableSectionHeaderViewDelegate {
    func listsButtonTapped()
    func addItemButtonTapped()
}

class ProfileTableSectionHeaderView: UIView {

    var delegate: ProfileTableSectionHeaderViewDelegate?

    private lazy var listsButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        let attributedTitle = NSAttributedString(string: "Lists",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: UIColor.white)

        button.setAttributedTitle(attributedTitle, for: .normal)


        return button
    }()

    private lazy var newListButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(newListButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        let attributedTitle = NSAttributedString(string: "Add",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.Accent)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.Black20

        addSubview(listsButton)
        addSubview(newListButton)

        constrain(listsButton, self) { button, view in
            button.top == view.top + 16
            button.left == view.left + 16
            button.bottom == view.bottom - 8
        }

        constrain(newListButton, self) { button, view in
            button.top == view.top + 16
            button.right == view.right - 16
            button.bottom == view.bottom - 8
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func listButtonTapped(sender: UIButton!) {
        print("\n\nList Button Tapped\n\n")
        delegate?.listsButtonTapped()
    }

    @objc func newListButtonTapped(sender: UIButton!) {
        print("\n\nNew Entry Button Tapped\n\n")
        delegate?.addItemButtonTapped()
    }
}
