import Foundation
import UIKit

import Cartography

class ListTableHeaderView: UIView {
    struct Constants {
        static let HorizontalSpacing: CGFloat = 0
    }

    var list: List
    let dependencyGraph: DependencyGraphType

    private lazy var followButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.addTarget(self, action: #selector(followList), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Follow",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.addTarget(self, action: #selector(editList), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Edit",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(shareList), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1.0
        button.layer.borderColor = FaveColors.Black30.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let attributedTitle = NSAttributedString(string: "Share",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Black90)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var titleLabel: Label = {
        let label = Label(text: self.list.title,
                          font: FaveFont(style: .h3, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var listDescriptionLabel: Label = {
        let label = Label(text: self.list.description,
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black70,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    init(dependencyGraph: DependencyGraphType, list: List) {
        self.dependencyGraph = dependencyGraph
        self.list = list

        super.init(frame: CGRect.zero)

        isUserInteractionEnabled = true

        addSubview(followButton)
        addSubview(shareButton)
        addSubview(titleLabel)
        addSubview(listDescriptionLabel)

        constrain(titleLabel, self) { label, view in
            label.left == view.left + 16
            label.top == view.top + 16
            label.right == view.right - 16
        }

        constrain(listDescriptionLabel, titleLabel) { descriptionLabel, titleLabel in
            descriptionLabel.left == titleLabel.left
            descriptionLabel.top == titleLabel.bottom
            descriptionLabel.right == titleLabel.right
        }

        constrain(followButton, listDescriptionLabel, self) { button, label, view in
            button.top == label.bottom + 16
            button.left == view.left + 16
            button.bottom == view.bottom - 16
        }

        constrain(shareButton, followButton, listDescriptionLabel, self) { button, followButton, label, view in
            button.top == followButton.top
            button.left == followButton.right + 16
            button.right == view.right - 16
            button.bottom == followButton.bottom

            button.width == followButton.width
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func followList(sender: UIButton!) {
        print("\nFollow List Button Tapped\n")
    }

    @objc func shareList(sender: UIButton!) {
        print("\nShare List Button Tapped\n")
    }

    @objc func editList(sender: UIButton!) {
        print("\nEdit List Button Tapped\n")
    }
}

