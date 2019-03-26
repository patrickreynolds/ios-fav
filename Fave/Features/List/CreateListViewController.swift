import Foundation
import UIKit
import Cartography
import MBProgressHUD

protocol CreateListViewControllerDelegate {
    func didCreateList(list: List)
}

class CreateListViewController: FaveVC {

    var delegate: CreateListViewControllerDelegate?

    var nameTextField: UITextField = UITextField(frame: .zero)
    var commentTextView: UITextView = UITextView(frame: .zero)
    var publicSettingsSwitch: UISwitch = UISwitch(frame: .zero)

    var commentTextViewPlaceholder: Label = Label.init(font: FaveFont.init(style: .h5, weight: .regular))

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

        button.addTarget(self, action: #selector(createListButtonTapped), for: .touchUpInside)
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
        nameInputIconImageView.image = UIImage(named: "icon-star")
        nameInputIconImageView.tintColor = FaveColors.Black50

        nameTextField = UITextField(frame: .zero)
        nameTextField.font = FaveFont(style: .h5, weight: .regular).font
        nameTextField.placeholder = "Name"
        nameTextField.textColor = FaveColors.Black90
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        let nameDividerView = DividerView()

        nameInputView.addSubview(nameInputIconImageView)
        nameInputView.addSubview(nameTextField)
        nameInputView.addSubview(nameDividerView)

        constrain(nameInputIconImageView, nameTextField, nameInputView) { imageView, textField, view in
            imageView.centerY == textField.centerY
            imageView.left == view.left + 16
        }

        constrain(nameTextField, nameInputIconImageView, nameInputView) { textField, imageView, view in
            textField.top == view.top + 20
            textField.right == view.right - 16
            textField.left == imageView.right + 16
            textField.bottom == view.bottom - 20
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
        commentTextView.font = FaveFont(style: .h4, weight: .regular).font
        commentTextView.textColor = FaveColors.Black90
        commentTextView.delegate = self
        commentTextView.backgroundColor = FaveColors.Black20
        commentTextView.layer.cornerRadius = 6
        commentTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        commentTextViewPlaceholder = Label(text: "Description", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black50, textAlignment: .left, numberOfLines: 1)
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


        // Add public vs private view
        let publicInputView = UIView.init(frame: .zero)

        let privacyInputIconImageView = UIImageView(frame: .zero)
        privacyInputIconImageView.image = UIImage(named: "icon-privacy")
        privacyInputIconImageView.tintColor = FaveColors.Black50
        privacyInputIconImageView.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)

        let publicSettingsLabel = Label(text: "Public", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black70, textAlignment: .left, numberOfLines: 1)
        publicSettingsLabel.setContentHuggingPriority(.defaultLow, for: NSLayoutConstraint.Axis.horizontal)

        publicSettingsSwitch = UISwitch.init(frame: .zero)
        publicSettingsSwitch.onTintColor = FaveColors.Accent
        publicSettingsSwitch.isOn = true

        let publicDividerView = DividerView()

        publicInputView.addSubview(privacyInputIconImageView)
        publicInputView.addSubview(publicDividerView)
        publicInputView.addSubview(publicSettingsLabel)
        publicInputView.addSubview(publicSettingsSwitch)

        constrain(privacyInputIconImageView, publicSettingsLabel, publicInputView) { imageView, label, view in
            imageView.centerY == label.centerY
            imageView.left == view.left + 16
        }

        constrain(publicSettingsLabel, privacyInputIconImageView, publicInputView) { label, imageView, view in
            label.top == view.top + 20
            label.bottom == view.bottom - 20
            label.left == imageView.right + 16
        }

        constrain(publicSettingsSwitch, publicInputView) { publicSettingsSwitch, view in
            publicSettingsSwitch.centerY == view.centerY
            publicSettingsSwitch.right == view.right - 16
        }

        constrain(publicDividerView, publicInputView) { divider, view in
            divider.right == view.right - 16
            divider.bottom == view.bottom
            divider.left == view.left + 16
        }

        view.addSubview(publicInputView)


        // Wire everything together

        constrain(nameInputView, commentInputView, publicInputView, view) { nameView, commentView, publicView, view in
            nameView.left == view.left
            nameView.top == view.top
            nameView.right == view.right

            commentView.top == nameView.bottom
            commentView.right == view.right
            commentView.left == view.left

            publicView.top == commentView.bottom
            publicView.right == commentView.right
            publicView.left == commentView.left
            publicView.bottom == view.bottom
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
        createListEnabled = false

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

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            createListEnabled = true
        } else {
            createListEnabled = false
        }
    }

    @objc func createListButtonTapped(sender: UIButton!) {
        print("\nCreate List Button Tapped\n")

        let name = self.nameTextField.text ?? ""
        let description = self.commentTextView.text ?? ""
        let isPublic = self.publicSettingsSwitch.isOn

        var userId = ""
        if let user = dependencyGraph.storage.getUser() {
            userId = "\(user.id)"
        }

        isLoading = true
        dependencyGraph.faveService.createList(userId: userId, name: name, description: description, isPublic: isPublic) { response, error in
            if let unwrappedResponse = response, let listData = unwrappedResponse["data"] as? [String: AnyObject] {
                print("Response Data: \(listData.description)")

                if let list = List(data: listData) {
                    self.delegate?.didCreateList(list: list)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Oops, something went wrong. Try creating a list again.", preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style {
                        case .default, .cancel, .destructive:
                            alertController.dismiss(animated: true, completion: nil)
                        }}))

                    self.present(alertController, animated: true, completion: nil)
                }
            }

            self.isLoading = false
        }
    }

    @objc func dismissView(sender: UIBarButtonItem!) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateListViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        commentTextViewPlaceholder.isHidden = !textView.text.isEmpty
    }
}

