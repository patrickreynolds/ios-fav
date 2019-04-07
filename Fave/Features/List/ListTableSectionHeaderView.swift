import Foundation
import UIKit
import Cartography

protocol ListTableSectionHeaderViewDelegate {
    func entriesButtonTapped()
    func recommendationsButtonTapped()
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

        let attributedTitle = NSAttributedString(string: "\(self.list.numberOfItems) Entries",
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

        let attributedTitle = NSAttributedString(string: "\(self.list.numberOfSuggestions) Recs",
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

        constrain(entriesButton, self) { button, view in
            button.top == view.top + 16
            button.left == view.left + 16
            button.bottom == view.bottom - 8
        }

        constrain(recommendationsButton, entriesButton, self) { recommendationsButton, entriesButton, view in
            recommendationsButton.top == entriesButton.top
            recommendationsButton.left == entriesButton.right + 8
            recommendationsButton.bottom == entriesButton.bottom
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
}

