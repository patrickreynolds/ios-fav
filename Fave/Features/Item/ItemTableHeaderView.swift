import Foundation
import UIKit

import Cartography

protocol ItemTableHeaderViewDelegate {
    func faveItemTapped(item: Item)
}

class ItemTableHeaderView: UIView {

    var item: Item {
        didSet {

            // If item is on user's list
            guard let user = dependencyGraph.storage.getUser() else {
                return
            }
        }
    }

    var delegate: ItemTableHeaderViewDelegate?
    let dependencyGraph: DependencyGraphType

    private lazy var faveItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.addTarget(self, action: #selector(faveItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Faved",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var titleLabel: Label = {
        let label = Label(text: self.item.contextualItem.name,
                          font: FaveFont(style: .h3, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var itemNoteLabel: Label = {
        let label = Label(text: self.item.note,
                          font: FaveFont(style: .h5, weight: .regular) ,
                          textColor: FaveColors.Black70,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var favedByOthersLabel: Label = {
        let labelText = self.item.numberOfFaves == 1 ? "Faved by \(self.item.numberOfFaves) other" : "Faved by \(self.item.numberOfFaves) others"

        let label = Label(text: labelText,
                          font: FaveFont(style: .h5, weight: .regular) ,
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var dividerView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 4
        }

        return view
    }()

    init(dependencyGraph: DependencyGraphType, item: Item) {
        self.dependencyGraph = dependencyGraph
        self.item = item

        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.White

        isUserInteractionEnabled = true

        addSubview(titleLabel)
        addSubview(itemNoteLabel)
        addSubview(favedByOthersLabel)
        addSubview(faveItemButton)
        addSubview(dividerView)

        constrain(titleLabel, self) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(itemNoteLabel, titleLabel, self) { itemNoteLabel, titleLabel, view in
            itemNoteLabel.top == titleLabel.bottom + 8
            itemNoteLabel.right == titleLabel.right
            itemNoteLabel.left == titleLabel.left
        }

        constrain(itemNoteLabel, favedByOthersLabel, self) { noteLabel, favedByOthersLabel, view in
            favedByOthersLabel.top == noteLabel.bottom + 16
            favedByOthersLabel.right == view.right - 16
            favedByOthersLabel.left == view.left + 16
        }

        if let user = dependencyGraph.storage.getUser(), item.addedBy.id == user.id {
            constrain(favedByOthersLabel, dividerView) { favedByOthersLabel, dividerView in
                favedByOthersLabel.bottom == dividerView.top - 16
            }
        } else {
            constrain(faveItemButton, favedByOthersLabel, dividerView, self) { stackView, favedByOthersLabel, dividerView, view in
                stackView.top == favedByOthersLabel.bottom + 16
                stackView.right == view.right - 16
                stackView.bottom == dividerView.top - 16
                stackView.left == view.left + 16
            }
        }

        constrain(dividerView, self) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeader(item: Item) {
        self.item = item
    }

    @objc func faveItemButtonTapped(sender: UIButton!) {
        print("\n Follow Item Button Tapped \n")

        delegate?.faveItemTapped(item: item)
    }
}
