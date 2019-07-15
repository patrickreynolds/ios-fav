import UIKit

import Cartography
import MBProgressHUD
import GooglePlaces

protocol CreateRecommendationViewControllerDelegate {
    func didSendRecommendations(selectedUsers: [User])
}

class CreateRecommendationViewController: FaveVC {

    var delegate: CreateRecommendationViewControllerDelegate?

    let creationType: ItemCreationType

    var listType: ListType = .undefined

    var place: GMSPlace? {
        didSet {
            if let place = place {
                createListEnabled = true

                nameLabelText = place.name ?? ""

                listType = .google
            } else {
                createListEnabled = false

                nameLabelText = "Location"
            }
        }
    }

    var nameLabelText: String = "Location" {
        didSet {
            if !nameLabelText.isEmpty {
                nameLabel.text = nameLabelText
                nameLabel.textColor = FaveColors.Black90
            } else {
                nameLabel.text = nameLabelText
                nameLabel.textColor = FaveColors.Black50
            }
        }
    }

    var userLabelText: String = "" {
        didSet {
            if !userLabelText.isEmpty {
                userLabel.text = userLabelText
                userLabel.textColor = FaveColors.Black90
            } else {
                userLabel.text = userLabelText
                userLabel.textColor = FaveColors.Black50
            }
        }
    }

    var selectedUsers: [User] = [] {
        didSet {
            var textString = selectedUsers.reduce("") { "\($0) \($1.handle), " }
            textString = String(textString.dropLast(2))
            userLabelText = textString
        }
    }

    var nameLabel: Label = Label(font: FaveFont(style: .h5, weight: .regular))
    var userLabel: Label = Label(font: FaveFont(style: .h5, weight: .regular))
    var noteTextView: UITextView = UITextView(frame: .zero)
    var noteTextViewCharacterCountLabel: Label = Label(font: FaveFont(style: .small, weight: .regular))

    var noteTextViewPlaceholder: Label = Label(font: FaveFont.init(style: .h5, weight: .regular))

    var createListEnabled: Bool = false {
        didSet {
            if createListEnabled {
                self.sendButton.backgroundColor = FaveColors.Accent
            } else {
                self.sendButton.backgroundColor = FaveColors.Accent.withAlphaComponent(0.56)
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                progressHud.show(animated: true)
            } else {
                progressHud.hide(animated: true)
            }
        }
    }

    public var heightConstraint: NSLayoutConstraint?

    private lazy var progressHud: MBProgressHUD = {
        let hud = MBProgressHUD(frame: .zero)

        hud.animationType = .fade
        hud.contentColor = FaveColors.Accent

        return hud
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(createRecommendationButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.layer.cornerRadius = 16

        let attributedTitle = NSAttributedString(string: "Send",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: .zero)

        scrollView.addSubview(self.contentView)

        constrainToSuperview(self.contentView)

        constrain(self.contentView) { contentView in
            contentView.width == UIScreen.main.bounds.width
        }

        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView.init(frame: .zero)

        // Add name input view
        let nameInputView = UIView(frame: .zero)

        let nameInputIconImageView = UIImageView(frame: .zero)
        nameInputIconImageView.image = UIImage(named: "tab-icon-search")
        nameInputIconImageView.tintColor = FaveColors.Black50

        nameLabel = Label.init(text: "Name", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black50, textAlignment: .left, numberOfLines: 1)
        nameLabel.isUserInteractionEnabled = true

        _ = nameLabel.tapped { recognizer in
            self.nameLabelTapped()
        }

        let nameDividerView = DividerView()

        nameInputView.addSubview(nameInputIconImageView)
        nameInputView.addSubview(nameLabel)
        nameInputView.addSubview(nameDividerView)

        constrain(nameInputIconImageView, nameLabel, nameInputView) { imageView, label, view in
            imageView.centerY == label.centerY
            imageView.left == view.left + 16
        }

        constrain(nameLabel, nameInputIconImageView, nameInputView) { label, imageView, view in
            label.top == view.top + 20
            label.right == view.right - 16
            label.left == imageView.right + 16
            label.bottom == view.bottom - 20
        }

        constrain(nameDividerView, nameInputView) { divider, view in
            divider.right == view.right - 16
            divider.bottom == view.bottom
            divider.left == view.left + 16
        }

        view.addSubview(nameInputView)


        // Add comments or tips input view
        let noteInputView = UIView(frame: .zero)

        let noteInputIconImageView = UIImageView(frame: .zero)
        noteInputIconImageView.image = UIImage(named: "icon-comment")
        noteInputIconImageView.tintColor = FaveColors.Black50

        noteTextView = UITextView(frame: .zero)
        noteTextView.font = FaveFont(style: .h5, weight: .regular).font
        noteTextView.textColor = FaveColors.Black90
        noteTextView.delegate = self
        noteTextView.backgroundColor = FaveColors.Black20
        noteTextView.layer.cornerRadius = 6
        noteTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        noteTextViewPlaceholder = Label(text: "Leave a note...", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black50, textAlignment: .left, numberOfLines: 1)
        noteTextViewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        noteTextViewPlaceholder.isHidden = false

        noteTextView.addSubview(noteTextViewPlaceholder)
        noteTextView.bringSubviewToFront(noteTextViewPlaceholder)

        constrain(noteTextViewPlaceholder, noteTextView) { placeholderLabel, textView in
            placeholderLabel.top == textView.top + 5
            placeholderLabel.left == textView.left + 12
        }

        noteTextViewCharacterCountLabel = Label(text: "0/280", font: FaveFont(style: .small, weight: .regular), textColor: FaveColors.Black50, textAlignment: .right, numberOfLines: 1)

        let noteDividerView = DividerView()

        noteInputView.addSubview(noteInputIconImageView)
        noteInputView.addSubview(noteDividerView)
        noteInputView.addSubview(noteTextView)
        noteInputView.addSubview(noteTextViewCharacterCountLabel)

        constrain(noteInputIconImageView, noteTextView, noteInputView) { imageView, textView, view in
            imageView.top == textView.top
            imageView.left == view.left + 16
        }

        constrain(noteTextView, noteInputIconImageView, noteInputView) { textView, imageView, view in
            textView.top == view.top + 20
            textView.right == view.right - 16
            textView.left == imageView.right + 16
            textView.height == 88
        }

        constrain(noteTextViewCharacterCountLabel, noteTextView, noteInputView) { label, textView, view in
            label.top == textView.bottom + 4
            label.right == view.right - 16
            label.bottom == view.bottom - 8
        }

        constrain(noteDividerView, noteInputView) { divider, view in
            divider.right == view.right - 16
            divider.bottom == view.bottom
            divider.left == view.left + 16
        }

        view.addSubview(noteInputView)


        // Add list input view
        let userInputView = UIView(frame: .zero)

        let userInputIconImageView = UIImageView(frame: .zero)
        userInputIconImageView.image = UIImage(named: "tab-icon-search")
        userInputIconImageView.tintColor = FaveColors.Black50
        userInputIconImageView.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)

        userLabel = Label(text: "Select a user", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black50, textAlignment: .left, numberOfLines: 0)
        userLabel.isUserInteractionEnabled = true
        userLabel.setContentHuggingPriority(.defaultLow, for: NSLayoutConstraint.Axis.horizontal)

        _ = userLabel.tapped { recognizer in
            self.userLabelTapped()
        }

        let userDividerView = DividerView()

        userInputView.addSubview(userInputIconImageView)
        userInputView.addSubview(userLabel)
        userInputView.addSubview(userDividerView)

        constrain(userInputIconImageView, userLabel, userInputView) { imageView, label, view in
            imageView.centerY == label.centerY
            imageView.left == view.left + 16
        }

        constrain(userLabel, userInputIconImageView, userInputView) { label, imageView, view in
            label.top == view.top + 20
            label.right == view.right - 16
            label.left == imageView.right + 16
            label.bottom == view.bottom - 20
        }

        constrain(userDividerView, userInputView) { divider, view in
            divider.right == view.right - 16
            divider.bottom == view.bottom
            divider.left == view.left + 16
        }

        view.addSubview(userInputView)

        // Wire everything together

        constrain(nameInputView, noteInputView, userInputView, view) { nameView, commentView, listView, view in
            nameView.left == view.left
            nameView.top == view.top
            nameView.right == view.right

            commentView.top == nameView.bottom
            commentView.right == view.right
            commentView.left == view.left

            listView.top == commentView.bottom
            listView.right == view.right
            listView.left == view.left
            listView.bottom == view.bottom
        }

        return view
    }()

    private var titleViewLabelText: String {
        switch creationType {
        case .addition:
            return "New entry"
        case .recommendation:
            return "Recommendation"
        }
    }

    init(dependencyGraph: DependencyGraphType) {
        self.creationType = .recommendation

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .createItemScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))

        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.sendButton)


        let titleViewLabel = Label.init(text: self.titleViewLabelText, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        sendButton.layer.cornerRadius = 32 / 2

        view.addSubview(progressHud)
        view.addSubview(scrollView)

        constrainToSuperview(scrollView, exceptEdges: [.top])

        constrain(scrollView, view) { scrollView, view in
            scrollView.top == view.topMargin
        }

        constrain(progressHud, view) { hud, view in
            hud.centerX == view.centerX
            hud.centerY == view.centerY
        }
    }

    func nameLabelTapped() {
        // Show google search view controller
        let autocompleteViewController = GMSAutocompleteViewController()

        autocompleteViewController.delegate = self

        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteViewController.placeFields = fields

        let filter = GMSAutocompleteFilter()
        filter.country = "US"
        filter.type = .establishment
        autocompleteViewController.autocompleteFilter = filter

        present(autocompleteViewController, animated: true, completion: nil)
    }

    func userLabelTapped() {
        let selectUserViewController = SelectUserViewController(dependencyGraph: dependencyGraph, selectedUsers: selectedUsers)
        let selectUserNavigationController = UINavigationController(rootViewController: selectUserViewController)

        selectUserViewController.delegate = self

        selectUserViewController.modalPresentationStyle = .overFullScreen

        present(selectUserNavigationController, animated: true)
    }

    @objc func createRecommendationButtonTapped(sender: UIButton!) {
        print("\nCreate List Button Tapped\n")


        guard let currentUser = dependencyGraph.storage.getUser() else {
            return
        }

        var placeId = ""
        if let place = self.place, let placeIdString = place.placeID {
            placeId = placeIdString
        }

        guard !selectedUsers.isEmpty else {
            let alertController = UIAlertController(title: "No user selected", message: "Select a user to send your recommendation.", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                switch action.style {
                case .default, .cancel, .destructive:
                    alertController.dismiss(animated: true, completion: nil)
                }}))

            self.present(alertController, animated: true, completion: nil)

            return
        }

        let type = listType.rawValue

        let note = self.noteTextView.text ?? ""

        guard !placeId.isEmpty else {
            return
        }

        isLoading = true

        //////// ___________________________

        var completedRequests = 0

        for selectedUser in selectedUsers {
            self.dependencyGraph.faveService.getLists(userId: selectedUser.id) { lists, error in
                guard let lists = lists else {
                    return
                }

                guard let recommendationsList = lists.filter({ list in
                    return list.title.lowercased() == "recommendations"
                }).first else {
                    return
                }

                self.dependencyGraph.faveService.createListItem(userId: currentUser.id, listId: recommendationsList.id, type: type, placeId: placeId, note: note) { item, error in

                    self.dependencyGraph.analytics.logEvent(dependencyGraph: self.dependencyGraph, title: AnalyticsEvents.recommendationSent.rawValue)

                    completedRequests += 1

                    guard let _ = item else {
                        let alertController = UIAlertController(title: "Error", message: "Oops, something went wrong. Try creating an entry again.", preferredStyle: .alert)

                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            switch action.style {
                            case .default, .cancel, .destructive:
                                alertController.dismiss(animated: true, completion: nil)
                            }}))

                        self.present(alertController, animated: true, completion: nil)

                        return
                    }


                    if completedRequests == self.selectedUsers.count {
                        self.isLoading = false

                        self.dismiss(animated: true, completion: {
                            self.delegate?.didSendRecommendations(selectedUsers: self.selectedUsers)
                        })
                    }
                }
            }
        }
        //// ________________________________________________
    }

    @objc func dismissView(sender: UIBarButtonItem!) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateRecommendationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        noteTextViewPlaceholder.isHidden = !textView.text.isEmpty
        noteTextViewCharacterCountLabel.text = "\(textView.text.count)/280"
        noteTextViewCharacterCountLabel.textColor = textView.text.count > 280 ? UIColor.red : FaveColors.Black50
    }
}

extension CreateRecommendationViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.place = place

        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension CreateRecommendationViewController: SelectUserViewControllerDelegate {
    func selectUsersButtonTapped(selectedUsers: [User]) {
        self.selectedUsers = selectedUsers
    }
}
