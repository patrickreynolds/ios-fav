import UIKit
import Nantes

import Cartography

protocol FeedEventTableViewCellDelegate {
    func userProfileSelected(user: User)
    func listItemSelected(item: Item, list: List)
}

class FeedEventTableViewCell: UITableViewCell {

    var delegate: FeedEventTableViewCellDelegate?
    var dependencyGraph: DependencyGraphType?

    private var hasNoteLabelConstraint: NSLayoutConstraint?
    private var noNoteLabelConstraint: NSLayoutConstraint?

    private var hasNoteTopLabelConstraint: NSLayoutConstraint?
    private var noNoteTopLabelConstraint: NSLayoutConstraint?

    var feedEvent: FeedEvent? {
        didSet {
            if let event = feedEvent, let dependencyGraph = self.dependencyGraph {
                eventItemView.update(dependencyGraph: dependencyGraph, withEvent: event)
            }
        }
    }

    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        let size: CGFloat = 48

        imageView.layer.cornerRadius = size / 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true

        imageView.isUserInteractionEnabled = true

        _ = imageView.tapped { tapped in

            guard let event = self.feedEvent else {
                return
            }

            self.delegate?.userProfileSelected(user: event.item.addedBy)
        }

        constrain(imageView) { imageView in
            imageView.height == size
            imageView.width == size
        }

        return imageView
    }()

    private lazy var titleLabel: NantesLabel = {

        let label: NantesLabel = NantesLabel.init(frame: .zero)

        label.delegate = self
        label.numberOfLines = 0

        label.text = ""
        label.textAlignment = .left
        label.textColor = FaveColors.Black90
        label.font = FaveFont(style: .h5, weight: .regular).font

        let primaryLinkAttributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: FaveFont(style: .h5, weight: .semiBold).font,
            NSAttributedString.Key.foregroundColor: FaveColors.Black90
        ]

        let activeLinkAttributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: FaveFont(style: .h5, weight: .semiBold).font,
            NSAttributedString.Key.foregroundColor: FaveColors.Black70
        ]

        label.linkAttributes = primaryLinkAttributes
        label.activeLinkAttributes = activeLinkAttributes

        return label
    }()

    private lazy var noteLabel: Label = {
        let label = Label(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

        return label
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black30

        return view
    }()

    private lazy var eventItemView: EventItemView = {
        let view = EventItemView(dependencyGraph: self.dependencyGraph)

        _ = view.tapped { tapped in
            guard let item = self.feedEvent?.item, let list = self.feedEvent?.list else {
                return
            }

            self.delegate?.listItemSelected(item: item, list: list)
        }

        return view
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)

        activityIndicatorView.hidesWhenStopped = true

        return activityIndicatorView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(userProfileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(noteLabel)
        contentView.addSubview(eventItemView)
        contentView.addSubview(borderView)
        contentView.addSubview(loadingIndicator)

        constrain(userProfileImageView, contentView) { imageView, view in
            imageView.top == view.top + 12
            imageView.left == view.left + 16
        }

        constrain(userProfileImageView, titleLabel, contentView) { imageView, label, view in
            label.top == view.top + 8
            label.right == view.right - 16
            label.left == imageView.right + 8
        }

        constrain(noteLabel, titleLabel) { noteLabel, titleLabel in
            noteLabel.left == titleLabel.left
            noteLabel.right == titleLabel.right

            hasNoteTopLabelConstraint = noteLabel.top == titleLabel.bottom + 6
            noNoteTopLabelConstraint = noteLabel.top == titleLabel.bottom + 4
        }

        constrain(eventItemView, titleLabel, noteLabel, contentView) { eventItemView, titleLabel, noteLabel, contentView in
            noNoteLabelConstraint = eventItemView.top == titleLabel.bottom + 20
            hasNoteLabelConstraint = eventItemView.top == noteLabel.bottom + 16

            eventItemView.right == contentView.right - 16
            eventItemView.bottom == contentView.bottom - 16
            eventItemView.left == titleLabel.left
        }

        constrain(borderView, contentView) { borderView, view in
            borderView.left == view.left + 16
            borderView.right == view.right - 16
            borderView.bottom == view.bottom
            borderView.height == 0.5
        }

        constrain(loadingIndicator, contentView) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        noteLabel.text = ""
        userProfileImageView.image = nil
        eventItemView.clearImage()

        setNeedsLayout()
        layoutIfNeeded()
    }

    func populate(dependencyGraph: DependencyGraphType, event: FeedEvent?) {
        if let event = event {
            loadingIndicator.stopAnimating()

            UIView.animate(withDuration: 0.15) {
                self.userProfileImageView.alpha = 1
                self.titleLabel.alpha = 1
                self.noteLabel.alpha = 1
                self.eventItemView.alpha = 1
            }

            self.feedEvent = event
            self.dependencyGraph = dependencyGraph

            let titleLabelText: NSMutableString = NSMutableString()

            if event.list.owner.id != event.item.addedBy.id {
                let handleText = "\(event.item.addedBy.firstName) \(event.item.addedBy.lastName)"
                let recommendationText = " recommended an item for "

                let lastOwnerCharacterString = String(event.list.owner.lastName.last ?? Character(""))
                let possessiveCharacter = lastOwnerCharacterString.lowercased() == "s" ? "'" : "'s"

                let ownerText = "\(event.list.owner.firstName) \(event.list.owner.lastName)\(possessiveCharacter)"
                let suffixText = " list. "
                let timeText = "\(event.item.createdAt.condensedTimeSinceString())"

                titleLabelText.append(handleText)
                titleLabelText.append(recommendationText)
                titleLabelText.append(ownerText)
                titleLabelText.append(suffixText)
                titleLabelText.append(timeText)

                titleLabel.text = titleLabelText as String

                titleLabel.addLink(to: URL(string: "item-added-by")!, withRange: (titleLabelText as NSString).range(of: handleText))
                titleLabel.addLink(to: URL(string: "item-owner")!, withRange: (titleLabelText as NSString).range(of: ownerText))
            } else {
                let handleText = "\(event.item.addedBy.firstName) \(event.item.addedBy.lastName)"
                let recommendationText = " added an item. "
                let timeText = "\(event.item.createdAt.condensedTimeSinceString())"

                titleLabelText.append(handleText)
                titleLabelText.append(recommendationText)
                titleLabelText.append(timeText)

                titleLabel.text = titleLabelText as String

                titleLabel.addLink(to: URL(string: "item-added-by")!, withRange: (titleLabelText as NSString).range(of: handleText))
            }

            noteLabel.text = event.item.note

            if !event.item.note.isEmpty {
                hasNoteLabelConstraint?.isActive = true
                noNoteTopLabelConstraint?.isActive = false

                hasNoteTopLabelConstraint?.isActive = true
                noNoteLabelConstraint?.isActive = false
            } else {
                hasNoteLabelConstraint?.isActive = false
                noNoteTopLabelConstraint?.isActive = true

                hasNoteTopLabelConstraint?.isActive = false
                noNoteLabelConstraint?.isActive = true
            }

            contentView.setNeedsLayout()
            contentView.layoutIfNeeded()

            userProfileImageView.image = UIImage(base64String: event.item.addedBy.profilePicture)

            eventItemView.update(dependencyGraph: dependencyGraph, withEvent: event)
        } else {

            loadingIndicator.startAnimating()

            UIView.animate(withDuration: 0.15) {
                self.userProfileImageView.alpha = 0
                self.titleLabel.alpha = 0
                self.noteLabel.alpha = 0
                self.eventItemView.alpha = 0
            }
        }
    }
}

extension FeedEventTableViewCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        guard let event = feedEvent else { return }

        if link.absoluteString == "item-added-by" {
            print("\(event.item.addedBy.firstName) \(event.item.addedBy.lastName)")

            delegate?.userProfileSelected(user: event.item.addedBy)

        } else if link.absoluteString == "item-owner" {
            let lastOwnerCharacterString = String(event.list.owner.lastName.last ?? Character(""))
            let possessiveCharacter = lastOwnerCharacterString.lowercased() == "s" ? "'" : "'s"

            print("\(event.list.owner.firstName) \(event.list.owner.lastName)\(possessiveCharacter)")

            delegate?.userProfileSelected(user: event.list.owner)
        }
    }
}
