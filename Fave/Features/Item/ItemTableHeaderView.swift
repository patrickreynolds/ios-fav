import Foundation
import UIKit

import Cartography

class ItemTableHeaderView: UIView {
    struct Constants {
        static let HorizontalSpacing: CGFloat = 0
    }

    var item: Item
    let dependencyGraph: DependencyGraphType

    private lazy var faveItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.addTarget(self, action: #selector(faveItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Fave",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var editItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.Black90, for: .normal)
        button.backgroundColor = FaveColors.White
        button.addTarget(self, action: #selector(editItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1.0
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Edit item",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.Black90)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var shareItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.backgroundColor = FaveColors.White
        button.addTarget(self, action: #selector(shareItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1.0
        button.layer.borderColor = FaveColors.Black20.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Share",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Black90)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)

        stackView.addArrangedSubview(faveItemButton)

//        if let user = dependencyGraph.storage.getUser() , user.id == item.owner.id {
        //        }
        stackView.addArrangedSubview(editItemButton)

        stackView.addArrangedSubview(shareItemButton)

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16.0

        return stackView
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

    private lazy var dividerView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 8
        }

        return view
    }()

    init(dependencyGraph: DependencyGraphType, item: Item) {
        self.dependencyGraph = dependencyGraph
        self.item = item

        super.init(frame: CGRect.zero)

        isUserInteractionEnabled = true

        addSubview(titleLabel)
        addSubview(itemNoteLabel)
        addSubview(actionStackView)
        addSubview(dividerView)

        constrain(titleLabel, self) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(itemNoteLabel, titleLabel, dividerView, self) { itemNoteLabel, titleLabel, dividerView, view in
            itemNoteLabel.left == titleLabel.left
            itemNoteLabel.top == titleLabel.bottom + 8
            itemNoteLabel.right == titleLabel.right
        }

        constrain(actionStackView, itemNoteLabel, dividerView, self) { stackView, noteLabel, dividerView, view in
            stackView.top == noteLabel.bottom + 16
            stackView.right == view.right - 16
            stackView.bottom == dividerView.top - 16
            stackView.left == view.left + 16
        }

//        constrain(faveItemButton, listDescriptionLabel, self) { button, label, view in
//            button.top == label.bottom + 16
//            button.left == view.left + 16
//            button.bottom == view.bottom - 16
//        }
//
//        constrain(faveItemButton, shareItemButton, listDescriptionLabel, self) { button, shareItemButton, label, view in
//            button.top == shareItemButton.top
//            button.left == shareItemButton.right + 16
//            button.right == view.right - 16
//            button.bottom == shareItemButton.bottom
//
//            button.width == shareItemButton.width
//        }

        constrain(dividerView, self) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func faveItemButtonTapped(sender: UIButton!) {
        print("\nFollow Item Button Tapped\n")
    }

    @objc func shareItemButtonTapped(sender: UIButton!) {
        print("\nShare Item Button Tapped\n")
    }

    @objc func editItemButtonTapped(sender: UIButton!) {
        print("\nEdit Item Button Tapped\n")
    }
}

