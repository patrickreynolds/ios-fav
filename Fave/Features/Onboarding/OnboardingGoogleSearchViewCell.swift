import UIKit

import Cartography
import GooglePlaces

protocol OnboardingGoogleSearchViewCellDelegate {
    func didTapAddButton(place: GoogleItemType)
}

class OnboardingGoogleSearchViewCell: UITableViewCell {

    var prediction: GMSAutocompletePrediction?
    var delegate: OnboardingGoogleSearchViewCellDelegate?

    private lazy var titleLabel: Label = {
        let label = Label(text: prediction?.attributedFullText.string ?? "",
                          font: FaveFont(style: .h5, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: prediction?.attributedSecondaryText?.string ?? "",
                          font: FaveFont(style: .small, weight: .regular),
                          textColor: FaveColors.Black70,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var addItemLoadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)

        indicator.style = .white
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.backgroundColor = FaveColors.HJLightningYellow
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        button.contentHorizontalAlignment = .center
//        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        let attributedTitle = NSAttributedString(string: "Add",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)

        button.setAttributedTitle(attributedTitle, for: .normal)

        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        button.addSubview(addItemLoadingSpinner)

        constrain(addItemLoadingSpinner, button) { addItemLoadingSpinner, button in
            addItemLoadingSpinner.centerX == button.centerX
            addItemLoadingSpinner.centerY == button.centerY
        }

        constrain(button) { button in
            button.width == 56
        }

        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(actionButton)

        constrain(titleLabel, contentView) { titleLabel, contentView in
            titleLabel.top == contentView.top + 8
            titleLabel.left == contentView.left
        }

        constrain(subtitleLabel, titleLabel, contentView) { subtitleLabel, titleLabel, contentView in
            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.left == contentView.left
            subtitleLabel.bottom == contentView.bottom - 8
        }

        constrain(titleLabel, subtitleLabel, actionButton, contentView) { titleLabel, subtitleLabel, actionButton, contentView in
            actionButton.centerY == contentView.centerY
            actionButton.right == contentView.right

            titleLabel.right == actionButton.left - 8
            subtitleLabel.right == actionButton.left - 8
        }

        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(prediction: GMSAutocompletePrediction) {
        self.prediction = prediction

        self.titleLabel.text = prediction.attributedPrimaryText.string
        self.subtitleLabel.text = prediction.attributedSecondaryText?.string
    }

    func addButtonTapped() {
        UIView.transition(with: self.actionButton, duration: 0.25, options: .curveLinear, animations: {
            self.actionButton.setAttributedTitle(NSAttributedString(), for: .normal)
        }, completion: { _ in
            self.addItemLoadingSpinner.startAnimating()
        })
    }
}
