import Foundation
import UIKit

import Cartography

protocol ItemInfoTableViewCellDelegate {
    func visitWebsiteButtonTapped(item: Item)
    func callButtonTapped(item: Item)
}

class ItemInfoTableViewCell: UITableViewCell {

    var item: Item?
    var delegate: ItemInfoTableViewCellDelegate?

    private lazy var titleLabel: Label = {
        let label = Label(text: "Info",
                               font: FaveFont(style: .h4, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 1)

        return label
    }()

    let keywordsLabel = Label(text: "",
                              font: FaveFont(style: .h5, weight: .regular),
                              textColor: FaveColors.Black70,
                              textAlignment: .left,
                              numberOfLines: 0)

    let websiteLabel = Label(text: "",
                              font: FaveFont(style: .h5, weight: .regular),
                              textColor: FaveColors.Black90,
                              textAlignment: .left,
                              numberOfLines: 0)

    let phoneNumberLabel = Label(text: "",
                              font: FaveFont(style: .h5, weight: .regular),
                              textColor: FaveColors.Black90,
                              textAlignment: .left,
                              numberOfLines: 0)

    private lazy var dividerView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    private lazy var websiteView: UIView = {
        let view = UIView(frame: CGRect.zero)

        let websiteTitleLabel = Label(text: "Website",
                                      font: FaveFont(style: .h5, weight: .semiBold),
                                      textColor: FaveColors.Black90,
                                      textAlignment: .left,
                                      numberOfLines: 0)

        let topDividerView = UIView.init(frame: .zero)
        topDividerView.backgroundColor = FaveColors.Black10

        let dividerView = UIView.init(frame: .zero)
        dividerView.backgroundColor = FaveColors.Black10

         _ = view.tapped { tapped in
            if let item = self.item {
                self.delegate?.visitWebsiteButtonTapped(item: item)
            }
        }

        view.addSubview(websiteTitleLabel)
        view.addSubview(websiteLabel)
        view.addSubview(topDividerView)
        view.addSubview(dividerView)

        constrain(websiteTitleLabel, websiteLabel, view) { websiteTitleLabel, websiteLabel, view in
            websiteTitleLabel.top == view.top + 16
            websiteTitleLabel.right == view.right
            websiteTitleLabel.left == view.left + 16

            websiteLabel.top == websiteTitleLabel.bottom + 4
            websiteLabel.right == view.right
            websiteLabel.left == view.left + 16
            websiteLabel.bottom == view.bottom - 16
        }

        constrain(topDividerView, view) { dividerView, view in
            dividerView.top == view.top
            dividerView.right == view.right
            dividerView.left == view.left
            dividerView.height == 4
        }

        constrain(dividerView, view) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left + 16
            dividerView.height == 4
        }

        return view
    }()

    private lazy var callView: UIView = {
        let view = UIView(frame: CGRect.zero)

        let phoneNumberTitleLabel = Label(text: "Call",
                                      font: FaveFont(style: .h5, weight: .semiBold),
                                      textColor: FaveColors.Black90,
                                      textAlignment: .left,
                                      numberOfLines: 0)

        let dividerView = UIView.init(frame: .zero)
        dividerView.backgroundColor = FaveColors.Black10

        _ = view.tapped { tapped in
            if let item = self.item {
                self.delegate?.callButtonTapped(item: item)
            }
        }

        view.addSubview(phoneNumberTitleLabel)
        view.addSubview(phoneNumberLabel)
        view.addSubview(dividerView)

        constrain(phoneNumberTitleLabel, phoneNumberLabel, view) { phoneNumberTitleLabel, phoneNumberLabel, view in
            phoneNumberTitleLabel.top == view.top + 16
            phoneNumberTitleLabel.right == view.right
            phoneNumberTitleLabel.left == view.left + 16

            phoneNumberLabel.top == phoneNumberTitleLabel.bottom + 4
            phoneNumberLabel.right == view.right
            phoneNumberLabel.left == view.left + 16
            phoneNumberLabel.bottom == view.bottom - 16
        }

        constrain(dividerView, view) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left
            dividerView.height == 4
        }

        return view
    }()

    private lazy var infoActionsStackView: UIStackView = {
        let stackView = UIStackView.init(frame: .zero)

        // Add website and phone number views

        stackView.addArrangedSubview(websiteView)
        stackView.addArrangedSubview(callView)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0

        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(dividerView)

        contentView.addSubview(keywordsLabel)
        contentView.addSubview(infoActionsStackView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(keywordsLabel, titleLabel, dividerView) { subtitleLabel, titleLabel, borderView in
            subtitleLabel.top == titleLabel.bottom + 8
            subtitleLabel.right == titleLabel.right
            subtitleLabel.left == titleLabel.left
        }

        constrain(infoActionsStackView, keywordsLabel, dividerView, contentView) { stackView, keywordsLabel, borderView, view in
            stackView.top == keywordsLabel.bottom + 16
            stackView.right == view.right
            stackView.bottom == borderView.top
            stackView.left == view.left
        }

        constrain(dividerView, contentView) { dividerView, view in
            dividerView.left == view.left
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.height == 4
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item) {
        self.item = item

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        var keywordsString = ""
        var counter = 0
        googleItem.keywords?.forEach { keyword in
            if counter < 2 {
                keywordsString += "\(keyword), "
                counter += 1
            }
        }

        _ = keywordsString.removeLast()
        _ = keywordsString.removeLast()

        keywordsLabel.text = keywordsString

        phoneNumberLabel.text = googleItem.formattedPhoneNumber

        var formattedWebsite = googleItem.website

        if formattedWebsite.hasSuffix("/") {
            _ = formattedWebsite.removeLast()
        }

        if formattedWebsite.hasPrefix("http://") {
            formattedWebsite = String(formattedWebsite.dropFirst(7))
        } else if formattedWebsite.hasPrefix("https://") {
            formattedWebsite = String(formattedWebsite.dropFirst(8))
        }

        websiteLabel.text = formattedWebsite
    }

    @objc func faveItemButtonTapped(sender: UIButton!) {
        guard let item = item else {
            return
        }

        delegate?.visitWebsiteButtonTapped(item: item)
    }

    @objc func shareItemButtonTapped(sender: UIButton!) {
        guard let item = item else {
            return
        }

        delegate?.callButtonTapped(item: item)
    }
}

