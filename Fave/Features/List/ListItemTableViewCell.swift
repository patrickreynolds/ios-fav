import Foundation
import UIKit

import Cartography

protocol EntryTableViewCellDelegate {
    func faveItemButtonTapped(item: Item)
    func shareItemButtonTapped(item: Item)
}

class EntryTableViewCell: UITableViewCell {

    var item: Item?
    var delegate: EntryTableViewCellDelegate?

    var faveScoreLabel = Label(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.FaveOrange,
                               textAlignment: .left,
                               numberOfLines: 1)

    var googleScoreLabel = Label(text: "",
                                 font: FaveFont(style: .h5, weight: .regular),
                                 textColor: FaveColors.FaveOrange,
                                 textAlignment: .left,
                                 numberOfLines: 1)

    var yelpScoreLabel = Label(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.FaveOrange,
                               textAlignment: .left,
                               numberOfLines: 1)


    private lazy var titleLabel: Label = {
        let label = Label(text: "",
                           font: FaveFont(style: .h4, weight: .semiBold),
                           textColor: FaveColors.Black90,
                           textAlignment: .left,
                           numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "",
                          font: FaveFont(style: .h5, weight: .regular),
                          textColor: FaveColors.Black60,
                          textAlignment: .left,
                          numberOfLines: 0)

        return label
    }()

    private lazy var ratingsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        let faveScoreView = UIView(frame: .zero)

        let faveTitleLabel = Label(text: "Faves".uppercased(),
                              font: FaveFont(style: .small, weight: .semiBold),
                              textColor: FaveColors.Black40,
                              textAlignment: .left,
                              numberOfLines: 1)

        faveScoreView.addSubview(faveTitleLabel)
        faveScoreView.addSubview(faveScoreLabel)

        constrainToSuperview(faveTitleLabel, exceptEdges: [.bottom])
        constrainToSuperview(faveScoreLabel, exceptEdges: [.top])

        constrain(faveTitleLabel, faveScoreLabel, faveScoreView) { titleLabel, scoreLabel, view in
            scoreLabel.top == titleLabel.bottom + 4
        }

        stackView.addArrangedSubview(faveScoreView)



        let googleScoreView = UIView(frame: .zero)

        let googleScoreTitleLabel = Label(text: "Google score".uppercased(),
                                font: FaveFont(style: .small, weight: .semiBold),
                                textColor: FaveColors.Black40,
                                textAlignment: .left,
                                numberOfLines: 1)

        googleScoreView.addSubview(googleScoreTitleLabel)
        googleScoreView.addSubview(googleScoreLabel)

        constrainToSuperview(googleScoreTitleLabel, exceptEdges: [.bottom])
        constrainToSuperview(googleScoreLabel, exceptEdges: [.top])

        constrain(googleScoreTitleLabel, googleScoreLabel, googleScoreView) { titleLabel, scoreLabel, view in
            scoreLabel.top == titleLabel.bottom + 4
        }

        stackView.addArrangedSubview(googleScoreView)



        let yelpScoreView = UIView(frame: .zero)

        let yelpScoreTitleLabel = Label(text: "Yelp score".uppercased(),
                                        font: FaveFont(style: .small, weight: .semiBold),
                                        textColor: FaveColors.Black40,
                                        textAlignment: .left,
                                        numberOfLines: 1)

        yelpScoreView.addSubview(yelpScoreTitleLabel)
        yelpScoreView.addSubview(yelpScoreLabel)

        constrainToSuperview(yelpScoreTitleLabel, exceptEdges: [.bottom])
        constrainToSuperview(faveScoreLabel, exceptEdges: [.top])

        constrain(yelpScoreTitleLabel, yelpScoreLabel, yelpScoreView) { titleLabel, scoreLabel, view in
            scoreLabel.top == titleLabel.bottom + 4
        }

        stackView.addArrangedSubview(yelpScoreView)

        stackView.distribution = .equalCentering

        return stackView
    }()

    private lazy var navigationIndicatorImageView: UIView = {
        let imageView = UIImageView(frame: CGRect.zero)

        imageView.image = UIImage(named: "icon-small-chevron")
        imageView.tintColor = FaveColors.Black60

        return imageView
    }()

    private lazy var faveItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Black20
        button.addTarget(self, action: #selector(faveItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Fave",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Accent)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var shareItemButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Black20
        button.addTarget(self, action: #selector(shareItemButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let attributedTitle = NSAttributedString(string: "Share",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Accent)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)

        stackView.addArrangedSubview(faveItemButton)
        stackView.addArrangedSubview(shareItemButton)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 16.0

        return stackView
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(ratingsStackView)
        contentView.addSubview(actionStackView)

        contentView.addSubview(borderView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(subtitleLabel, titleLabel) { subtitleLabel, titleLabel in
            subtitleLabel.top == titleLabel.bottom + 4
            subtitleLabel.right == titleLabel.right
            subtitleLabel.left == titleLabel.left
        }

        constrain(ratingsStackView, subtitleLabel, borderView, contentView) { stackView, subtitleLabel, borderView, contentView in
            stackView.top == subtitleLabel.bottom + 16
            stackView.right == contentView.right - 16
            stackView.left == contentView.left + 16
        }

        constrain(actionStackView, ratingsStackView, borderView, contentView) { actionStackView, ratingsStackView, borderView, contentView in
            actionStackView.top == ratingsStackView.bottom + 16
            actionStackView.right == contentView.right - 16
            actionStackView.bottom == borderView.top - 16
            actionStackView.left == contentView.left + 16
        }

        constrain(borderView, contentView) { borderView, view in
            borderView.left == view.left
            borderView.right == view.right
            borderView.bottom == view.bottom
            borderView.height == 8
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item) {
        self.item = item

        titleLabel.text = item.contextualItem.name
        subtitleLabel.text = item.note
        faveScoreLabel.text = "\(item.numberOfFaves)"
        yelpScoreLabel.text = "3.999"

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        googleScoreLabel.text = "\(googleItem.rating)"

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

    @objc func faveItemButtonTapped(sender: UIButton!) {
        guard let item = item else {
            return
        }

        delegate?.faveItemButtonTapped(item: item)
    }

    @objc func shareItemButtonTapped(sender: UIButton!) {
        guard let item = item else {
            return
        }

        delegate?.shareItemButtonTapped(item: item)
    }
}
