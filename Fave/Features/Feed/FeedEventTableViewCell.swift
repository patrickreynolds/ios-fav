import UIKit

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

    var feedEvent: FeedEvent?

    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

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

    private lazy var titleLabel: Label = {
        let label = Label.init(text: "",
                               font: FaveFont(style: .h5, weight: .regular),
                               textColor: FaveColors.Black90,
                               textAlignment: .left,
                               numberOfLines: 0)

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(userProfileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(noteLabel)
        contentView.addSubview(eventItemView)
        contentView.addSubview(borderView)

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

            hasNoteTopLabelConstraint = noteLabel.top == titleLabel.bottom + 4
            noNoteTopLabelConstraint = noteLabel.top == titleLabel.bottom + 4
        }

        constrain(eventItemView, titleLabel, noteLabel, contentView) { eventItemView, titleLabel, noteLabel, contentView in
            noNoteLabelConstraint = eventItemView.top == titleLabel.bottom + 24
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.attributedText = NSMutableAttributedString(string: "")
        noteLabel.text = ""
        userProfileImageView.image = nil

        if let event = feedEvent, let dependencyGraph = self.dependencyGraph {
            eventItemView.update(dependencyGraph: dependencyGraph, withEvent: event)
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    func populate(dependencyGraph: DependencyGraphType, event: FeedEvent) {
        self.feedEvent = event
        self.dependencyGraph = dependencyGraph

        let titleLabelAttributedText: NSMutableAttributedString = NSMutableAttributedString()

        let primaryAttributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: FaveFont(style: .h5, weight: .semiBold).font,
            NSAttributedString.Key.foregroundColor: FaveColors.Black90
        ]

        let standardAttributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: FaveFont(style: .h5, weight: .regular).font,
            NSAttributedString.Key.foregroundColor: FaveColors.Black90
        ]

        let subtleAttributes: [NSAttributedString.Key : Any]? = [
            NSAttributedString.Key.font: FaveFont(style: .small, weight: .regular).font,
            NSAttributedString.Key.foregroundColor: FaveColors.Black70
        ]

        if event.list.owner.id != event.item.addedBy.id {
            let handleText = NSAttributedString.init(string: "\(event.item.addedBy.firstName) \(event.item.addedBy.lastName)", attributes: primaryAttributes)
            let recommendationText = NSAttributedString.init(string: " recommended an item for ", attributes: standardAttributes)
            
            let lastOwnerCharacterString = String(event.list.owner.lastName.last ?? Character.init(""))
            let possessiveCharacter = lastOwnerCharacterString.lowercased() == "s" ? "'" : "'s"
            
            let ownerText = NSAttributedString.init(string: "\(event.list.owner.firstName) \(event.list.owner.lastName)\(possessiveCharacter)", attributes: primaryAttributes)
            let suffixText = NSAttributedString.init(string: " list. ", attributes: standardAttributes)
            let timeText = NSAttributedString.init(string: "\(event.item.createdAt.condensedTimeSinceString())", attributes: subtleAttributes)

            titleLabelAttributedText.append(handleText)
            titleLabelAttributedText.append(recommendationText)
            titleLabelAttributedText.append(ownerText)
            titleLabelAttributedText.append(suffixText)
            titleLabelAttributedText.append(timeText)
        } else {
            let handleText = NSAttributedString.init(string: "\(event.item.addedBy.firstName) \(event.item.addedBy.lastName)", attributes: primaryAttributes)
            let recommendationText = NSAttributedString.init(string: " added an item. ", attributes: standardAttributes)
            let timeText = NSAttributedString.init(string: "\(event.item.createdAt.condensedTimeSinceString())", attributes: subtleAttributes)

            titleLabelAttributedText.append(handleText)
            titleLabelAttributedText.append(recommendationText)
            titleLabelAttributedText.append(timeText)
        }

        titleLabel.attributedText = titleLabelAttributedText

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
    }
}
