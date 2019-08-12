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
                              font: FaveFont(style: .small, weight: .regular),
                              textColor: FaveColors.Black90,
                              textAlignment: .right,
                              numberOfLines: 1)

    let phoneNumberLabel = Label(text: "",
                              font: FaveFont(style: .small, weight: .regular),
                              textColor: FaveColors.Black90,
                              textAlignment: .right,
                              numberOfLines: 0)

    private lazy var dividerView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    private lazy var googleItemInfoRatingView: ItemInfoRatingView = {
        var rating: Double = 0

        if let item = item, let googleItem = item.contextualItem as? GoogleItemType {
            rating = googleItem.rating
        }

        let ratingView = ItemInfoRatingView(ratingType: .google, rating: rating)

        return ratingView
    }()

    private lazy var ratingStackView: UIStackView = {
        let ratingStackView = UIStackView(frame: .zero)

        ratingStackView.addArrangedSubview(googleItemInfoRatingView)
//        ratingStackView.addArrangedSubview(ItemInfoRatingView.init(ratingType: .yelp, rating: 3.14))

        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 24
        ratingStackView.distribution = .fillEqually

        return ratingStackView
    }()

    private lazy var websiteView: UIView = {
        let view = UIView(frame: CGRect.zero)

        let websiteTitleLabel = Label(text: "Visit website",
                                      font: FaveFont(style: .h5, weight: .semiBold),
                                      textColor: FaveColors.Accent,
                                      textAlignment: .left,
                                      numberOfLines: 0)

        let topDividerView = UIView(frame: .zero)
        topDividerView.backgroundColor = FaveColors.Black20

//        let dividerView = UIView(frame: .zero)
//        dividerView.backgroundColor = FaveColors.Black20

         _ = view.tapped { tapped in
            if let item = self.item {
                self.delegate?.visitWebsiteButtonTapped(item: item)
            }
        }

        view.addSubview(websiteTitleLabel)
        view.addSubview(websiteLabel)
        view.addSubview(topDividerView)

        constrain(websiteTitleLabel, websiteLabel, view) { websiteTitleLabel, websiteLabel, view in
            websiteTitleLabel.top == view.top + 16
            websiteTitleLabel.bottom == view.bottom - 16
            websiteTitleLabel.left == view.left + 16

            websiteLabel.centerY == websiteTitleLabel.centerY
            websiteLabel.left == websiteTitleLabel.right + 16
            websiteLabel.right == view.right - 16
        }

        constrain(topDividerView, view) { dividerView, view in
            dividerView.top == view.top
            dividerView.right == view.right
            dividerView.left == view.left + 16
            dividerView.height == 1
        }

        websiteTitleLabel.contentCompressionResistancePriority = .defaultHigh
        websiteLabel.contentCompressionResistancePriority = .defaultLow

        return view
    }()

    private lazy var callView: UIView = {
        let view = UIView(frame: CGRect.zero)

        let phoneNumberTitleLabel = Label(text: "Call",
                                      font: FaveFont(style: .h5, weight: .semiBold),
                                      textColor: FaveColors.Accent,
                                      textAlignment: .left,
                                      numberOfLines: 0)

        let dividerView = UIView(frame: .zero)
        dividerView.backgroundColor = FaveColors.Black20

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
            phoneNumberTitleLabel.bottom == view.bottom - 16
            phoneNumberTitleLabel.left == view.left + 16

            phoneNumberLabel.centerY == phoneNumberTitleLabel.centerY
            phoneNumberLabel.right == view.right - 16
            phoneNumberLabel.left == phoneNumberTitleLabel.right + 16
        }

        constrain(dividerView, view) { dividerView, view in
            dividerView.right == view.right
            dividerView.top == view.top
            dividerView.left == view.left + 16
            dividerView.height == 1
        }

        return view
    }()

    private lazy var infoActionsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

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
        contentView.addSubview(ratingStackView)
        contentView.addSubview(keywordsLabel)
        contentView.addSubview(infoActionsStackView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 24
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(keywordsLabel, titleLabel) { subtitleLabel, titleLabel in
            subtitleLabel.top == titleLabel.bottom + 8
            subtitleLabel.right == titleLabel.right
            subtitleLabel.left == titleLabel.left
        }

        constrain(ratingStackView, keywordsLabel) { ratingStackView, keywordsLabel in
            ratingStackView.top == keywordsLabel.bottom + 24
            ratingStackView.left == keywordsLabel.left
        }

        constrain(infoActionsStackView, ratingStackView, dividerView, contentView) { stackView, ratingStackView, borderView, view in
            stackView.top == ratingStackView.bottom + 24
            stackView.right == view.right
            stackView.bottom == borderView.top
            stackView.left == view.left
        }

        constrain(dividerView, contentView) { dividerView, view in
            dividerView.left == view.left
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.height == 8
        }
    }

    /* Convert to using actual Yelp and Google icons
    private lazy var ratingsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        let faveScoreView = UIView(frame: .zero)

        let faveTitleLabel = Label(text: "Faves".uppercased(),
                                   font: FaveFont(style: .small, weight: .semiBold),
                                   textColor: FaveColors.Black60,
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
                                          textColor: FaveColors.Black60,
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
                                        textColor: FaveColors.Black60,
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
    */

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

        websiteLabel.text = formattedWebsite.isEmpty ? "No website listed" : formattedWebsite

        googleItemInfoRatingView.rating = googleItem.rating
    }

    @objc func faveItemButtonTapped(sender: UIButton!) {
        guard let item = item, let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        guard !googleItem.website.isEmpty else {
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

