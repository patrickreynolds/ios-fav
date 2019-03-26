import Foundation
import UIKit

import Cartography
import MBProgressHUD
import GooglePlaces

protocol CreateItemViewControllerDelegate {
    func didCreateItem()
}

enum ListType: String {
    case place = "PLACE"
    case yelp
    case podcast
    case undefined
}

class CreateItemViewController: FaveVC {

    var delegate: CreateItemViewControllerDelegate?

    var listType: ListType = .undefined

    var place: GMSPlace? {
        didSet {
            if let place = place {
                createListEnabled = true

                nameLabelText = place.name ?? ""

                listType = .place
            } else {
                createListEnabled = false

                nameLabelText = "Name"
            }
        }
    }

    var nameLabelText: String = "Name" {
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

    var nameLabel: Label = Label(font: FaveFont(style: .h5, weight: .regular))
    var commentTextView: UITextView = UITextView(frame: .zero)

    var commentTextViewPlaceholder: Label = Label(font: FaveFont.init(style: .h5, weight: .regular))

    var createListEnabled: Bool = false {
        didSet {
            if createListEnabled {
                self.createButton.backgroundColor = FaveColors.Accent
            } else {
                self.createButton.backgroundColor = FaveColors.Accent.withAlphaComponent(0.56)
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

    private lazy var createButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(createItemButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        let attributedTitle = NSAttributedString(string: "Create",
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
        let commentInputView = UIView(frame: .zero)

        let commentInputIconImageView = UIImageView(frame: .zero)
        commentInputIconImageView.image = UIImage(named: "icon-comment")
        commentInputIconImageView.tintColor = FaveColors.Black50

        commentTextView = UITextView(frame: .zero)
        commentTextView.font = FaveFont(style: .h5, weight: .regular).font
        commentTextView.textColor = FaveColors.Black90
        commentTextView.delegate = self
        commentTextView.backgroundColor = FaveColors.Black20
        commentTextView.layer.cornerRadius = 6
        commentTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        commentTextViewPlaceholder = Label(text: "Comments or tips...", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black50, textAlignment: .left, numberOfLines: 1)
        commentTextViewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        commentTextViewPlaceholder.isHidden = false

        commentTextView.addSubview(commentTextViewPlaceholder)
        commentTextView.bringSubviewToFront(commentTextViewPlaceholder)

        constrain(commentTextViewPlaceholder, commentTextView) { placeholderLabel, textView in
            placeholderLabel.top == textView.top + 5
            placeholderLabel.left == textView.left + 12
        }

        let commentsDividerView = DividerView()

        commentInputView.addSubview(commentInputIconImageView)
        commentInputView.addSubview(commentsDividerView)
        commentInputView.addSubview(commentTextView)

        constrain(commentInputIconImageView, commentTextView, commentInputView) { imageView, textField, view in
            imageView.top == textField.top
            imageView.left == view.left + 16
        }

        constrain(commentTextView, commentInputIconImageView, commentInputView) { textView, imageView, view in
            textView.top == view.top + 20
            textView.right == view.right - 16
            textView.bottom == view.bottom - 20
            textView.left == imageView.right + 16
            textView.height == 88
        }

        constrain(commentsDividerView, commentInputView) { divider, view in
            divider.right == view.right - 16
            divider.bottom == view.bottom
            divider.left == view.left + 16
        }

        view.addSubview(commentInputView)


        // Wire everything together

        constrain(nameInputView, commentInputView, view) { nameView, commentView, view in
            nameView.left == view.left
            nameView.top == view.top
            nameView.right == view.right

            commentView.top == nameView.bottom
            commentView.right == view.right
            commentView.left == view.left
            commentView.bottom == view.bottom
        }

        return view
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .profileScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))

        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createButton)

        navigationController?.navigationBar.topItem?.title = "New list"

        createButton.layer.cornerRadius = 32 / 2

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

//    @objc func textFieldDidChange(_ textField: UITextField) {
//        if let text = textField.text, !text.isEmpty {
//            createListEnabled = true
//        } else {
//            createListEnabled = false
//        }
//    }

    @objc func createItemButtonTapped(sender: UIButton!) {
        print("\nCreate List Button Tapped\n")

        var userId = ""
        if let user = dependencyGraph.storage.getUser() {
            userId = "\(user.id)"
        }

        var placeId = ""
        if let place = self.place, let placeIdString = place.placeID {
            placeId = placeIdString
        }

        let type = listType.rawValue

        let description = self.commentTextView.text ?? ""


        isLoading = true

        dependencyGraph.faveService.createListItem(userId: userId, listId: "1", type: type, placeId: placeId, description: description) { response, error in
            if let responseData = response {
                print("Response Data: \(responseData.description)")

                self.delegate?.didCreateItem()
                self.dismiss(animated: true, completion: nil)
            }

            self.isLoading = false
        }
    }

    @objc func dismissView(sender: UIBarButtonItem!) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateItemViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        commentTextViewPlaceholder.isHidden = !textView.text.isEmpty
    }
}

extension CreateItemViewController: GMSAutocompleteViewControllerDelegate {
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


