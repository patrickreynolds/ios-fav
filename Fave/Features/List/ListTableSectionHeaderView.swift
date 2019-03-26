import Foundation
import UIKit
import Cartography

protocol ListTableSectionHeaderViewDelegate {
    func entriesButtonTapped()
    func recommendationsButtonTapped()
    func newEntryButtonTapped()
}

class ListTableSectionHeaderView: UIView {

    var delegate: ListTableSectionHeaderViewDelegate?
    let list: List

    private lazy var entriesButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(entriesButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        let attributedTitle = NSAttributedString(string: "\(self.list.items.count) Entries",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: UIColor.white)

        button.setAttributedTitle(attributedTitle, for: .normal)


        return button
    }()

    private lazy var recommendationsButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(recommendationsButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = FaveColors.White
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        let attributedTitle = NSAttributedString(string: "10 Recs",
            font: FaveFont(style: .small, weight: .semiBold).font,
            textColor: FaveColors.Accent)

        button.setAttributedTitle(attributedTitle, for: .normal)


        return button
    }()

    private lazy var newEntryButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(newEntryButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        let attributedTitle = NSAttributedString(string: "Add",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Accent)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    init(list: List) {
        self.list = list

        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.Black20

        addSubview(entriesButton)
        addSubview(recommendationsButton)
        addSubview(newEntryButton)

        constrain(entriesButton, self) { button, view in
            button.top == view.top + 8
            button.left == view.left + 16
            button.bottom == view.bottom - 8
        }

        constrain(recommendationsButton, entriesButton, self) { recommendationsButton, entriesButton, view in
            recommendationsButton.top == entriesButton.top
            recommendationsButton.left == entriesButton.right + 8
            recommendationsButton.bottom == entriesButton.bottom
        }

        constrain(newEntryButton, self) { button, view in
            button.top == view.top + 8
            button.right == view.right - 16
            button.bottom == view.bottom - 8
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func entriesButtonTapped(sender: UIButton!) {
        print("\n\nList Button Tapped\n\n")
        delegate?.entriesButtonTapped()
    }

    @objc func recommendationsButtonTapped(sender: UIButton!) {
        print("\nRecommendations Button Tapped\n")

        delegate?.entriesButtonTapped()
    }

    @objc func newEntryButtonTapped(sender: UIButton!) {
        print("\n\nNew Entry Button Tapped\n\n")

        delegate?.newEntryButtonTapped()
    }
}

