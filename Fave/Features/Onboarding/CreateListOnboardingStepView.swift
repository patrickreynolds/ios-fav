import UIKit

import Cartography

protocol CreateListOnboardingStepViewDelegate {
    func createList(title: String, completion: @escaping (_ listId: Int) -> ())
}

class CreateListOnboardingStepView: UIView {

    // MARK: - Properties

    private let step: OnboardingStepType
    var delegate: OnboardingViewControllerDelegate?
    var createListDelegate: CreateListOnboardingStepViewDelegate?
    private var createListOptionView: OnboardingCreationStackViewOptionView?
    private var creationListBottomLayoutConstraint: NSLayoutConstraint?
    private var createButtonRightMargin: NSLayoutConstraint?
    private var createButtonBottomMargin: NSLayoutConstraint?

    private var hasSeenTextView: Bool = false
    private var hasTappedActionButton: Bool = false
    private var createButtonOffset: CGFloat = 72

    private var hasValidListName: Bool = false {
        didSet {
            if oldValue == hasValidListName {
                return
            }

            if hasValidListName {
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                    self.createButton.backgroundColor = FaveColors.HJCerulean
                }) { completion in }
            } else {
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                    self.createButton.backgroundColor = FaveColors.Black30
                }) { completion in }
            }
        }
    }

    private var listName: String = "" {
        didSet {
            if listName.isEmpty {
                hasValidListName = false
            } else {
                hasValidListName = true
            }
        }
    }


    // MARK: - UI Properties

    private lazy var titleLabel: Label = {
        let label = Label(
            text: step.title,
            font: FaveFont(style: .h4, weight: .bold),
            textColor: FaveColors.Black100,
            textAlignment: .left,
            numberOfLines: 0)

        return label
    }()

    private lazy var listNameTextFieldView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.White
        view.layer.borderColor = FaveColors.Black30.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.alpha = 0

        view.addSubview(listNameTextField)

        constrain(listNameTextField, view) { textField, view in
            textField.top == view.top + 12
            textField.right == view.right - 16
            textField.bottom == view.bottom - 12
            textField.left == view.left + 16
        }

        return view
    }()

    private lazy var listNameTextField: UITextField = {
        let textField = UITextField.init(frame: .zero)

        textField.placeholder = "List name"
        textField.autocapitalizationType = .sentences
        textField.tintColor = FaveColors.HJCerulean
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        return textField
    }()

    private lazy var illustrationImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        imageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        imageView.image = UIImage(named: "illustration-onboarding-arrow")
        imageView.tintColor = FaveColors.HJLightningYellow

        return imageView
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.backgroundColor = FaveColors.HJCerulean
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "icon-onboarding-add"), for: .normal)
        button.tintColor = FaveColors.White

        button.addSubview(createButtonLoadingSpinner)

        constrain(createButtonLoadingSpinner, button) { createButtonLoadingSpinner, button in
            createButtonLoadingSpinner.centerX == button.centerX
            createButtonLoadingSpinner.centerY == button.centerY
        }

        button.bringSubviewToFront(createButtonLoadingSpinner)

        button.layer.masksToBounds = false

        return button
    }()

    private lazy var createButtonLoadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)

        indicator.style = .white
        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var creationStackView: UIView = {
        let shadowView = UIView.init(frame: .zero)

        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = FaveColors.Black100.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOpacity = 0.16


        let roundedView = UIView.init(frame: .zero)
        roundedView.layer.cornerRadius = 6
        roundedView.layer.masksToBounds = true
        roundedView.clipsToBounds = true


        let stackView = UIStackView(frame: .zero)

        let optionViews: [OnboardingCreationStackViewOptionView] = [
            OnboardingCreationStackViewOption(title: "Send a recommendation", primary: false, hasBorder: true),
            OnboardingCreationStackViewOption(title: "Create a list", primary: true, hasBorder: true),
            OnboardingCreationStackViewOption(title: "Add an entry", primary: false, hasBorder: false)
        ]
        .map { option in
            return OnboardingCreationStackViewOptionView(option: option)
        }

        for (index, view) in optionViews.enumerated() {
            if index == 1 {
                createListOptionView = view

                _ = createListOptionView?.tapped { gesture in
                    self.handleCreateListTapped()
                    self.createListOptionView?.performImpact(style: .light)
                }
            }

            stackView.addArrangedSubview(view)
        }

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.backgroundColor = FaveColors.White

        shadowView.addSubview(roundedView)
        roundedView.addSubview(stackView)

        constrainToSuperview(roundedView)
        constrainToSuperview(stackView)

        return shadowView
    }()


    // MARK: - Initializers

    init(step: OnboardingStepType) {
        self.step = step

        super.init(frame: .zero)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        addSubview(titleLabel)
        addSubview(illustrationImageView)
        addSubview(listNameTextFieldView)
        addSubview(creationStackView)
        addSubview(createButton)

        constrain(self) { view in
            view.width == UIScreen.main.bounds.width
        }

        constrain(titleLabel, self) { label, view in
            label.top == view.top + 24
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(listNameTextFieldView, titleLabel, self) { listNameTextFieldView, titleLabel, view in
            listNameTextFieldView.top == titleLabel.bottom + 24
            listNameTextFieldView.right == view.right - 16
            listNameTextFieldView.left == view.left + 16
        }

        constrain(illustrationImageView, self) { imageView, view in
            imageView.right == view.right
            imageView.left == view.left
            imageView.centerY == view.centerY
        }

        constrain(creationStackView, createButton, self) { stackView, createButton, view in
            stackView.right == view.right - 16
            stackView.left == view.left + 16
            creationListBottomLayoutConstraint = stackView.bottom == createButton.top - 16
        }

        constrain(createButton, self) { button, view in
            createButtonRightMargin = button.right == view.right - 24
            createButtonBottomMargin = button.bottom == view.bottom - createButtonOffset
            button.width == 56
            button.height == 56
        }

        createButton.setNeedsLayout()
        createButton.layoutIfNeeded()

        createButton.layer.shadowColor = FaveColors.White.cgColor
        createButton.layer.shadowPath = UIBezierPath(roundedRect: createButton.bounds, cornerRadius: createButton.layer.cornerRadius).cgPath
        createButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        createButton.layer.shadowOpacity = 1
        createButton.layer.shadowRadius = 24

        creationStackView.isHidden = true
        creationStackView.alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Button & Action Handlers

    @objc func createButtonTapped(sender: UIButton!) {

        if hasValidListName {
            let image = UIImage()
            UIView.transition(with: self.createButton, duration: 0.25, options: .curveLinear, animations: {
                self.createButton.setImage(image, for: .normal)
            }, completion: { _ in
                self.createButtonLoadingSpinner.startAnimating()
            })

            sender.performImpact(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
            createListDelegate?.createList(title: listName) { listId in
                self.delegate?.didAdvanceOnboarding()
            }

        } else if hasSeenTextView {

            // Button's disabled at this point

        } else if hasTappedActionButton {

//            if toolTipIsShowing {
//                // Nudge tooltip
//            } else {
//                // Show tooltip to press create list
//                // creationStackView.showTooltip
//            }

        } else {

            sender.performImpact(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
            hasTappedActionButton = true

            self.creationStackView.isHidden = false

            if let constant = creationListBottomLayoutConstraint?.constant {
                creationListBottomLayoutConstraint?.constant = constant - 8
            }

            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.creationStackView.alpha = 1
                self.layoutIfNeeded()
            }) { completion in }

            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.createButton.transform = CGAffineTransform(rotationAngle: (.pi / 4))
            }) { completion in }
        }
    }

    func handleCreateListTapped() {
        hasSeenTextView = true

        createListOptionView?.simulateTap {
            // animate away creation list
            // animate button color & icon
            // animate in textfield
            // animate in examples
            if let constant = self.creationListBottomLayoutConstraint?.constant {
                self.creationListBottomLayoutConstraint?.constant = constant - 16
            }

            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.creationStackView.alpha = 0
                self.layoutIfNeeded()
            }) { completion in }


            if let constant = self.createButtonRightMargin?.constant {
                self.createButtonRightMargin?.constant = constant + 8
            }

            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.createButton.backgroundColor = FaveColors.Black30
                self.createButton.transform = CGAffineTransform.identity
                self.layoutIfNeeded()
            }) { completion in }


            let image = UIImage(named: "icon-onboarding-chevron")
            UIView.transition(with: self.createButton, duration: 0.25, options: .curveLinear, animations: {
                self.createButton.setImage(image, for: .normal)
            }, completion: nil)


            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.illustrationImageView.alpha = 0
            }) { completion in }


            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.listNameTextFieldView.alpha = 1
            }) { completion in }

            self.listNameTextField.becomeFirstResponder()
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo,
            let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {

                return
        }

        let keyboardHeight = frameInfo.cgRectValue.height
        delegate?.keyboardHeight = keyboardHeight

        if let constant = self.createButtonBottomMargin?.constant {
            self.createButtonBottomMargin?.constant = constant - (keyboardHeight - (createButtonOffset + 16))
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }) { completion in }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let info = notification.userInfo,
            let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {

                return
        }

        let keyboardHeight = frameInfo.cgRectValue.height
        delegate?.keyboardHeight = keyboardHeight

        if let constant = self.createButtonBottomMargin?.constant {
            self.createButtonBottomMargin?.constant = constant + (keyboardHeight - (createButtonOffset + 16))
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }) { completion in }
    }

    @objc func textFieldDidChange(textField: UITextField!) {
        listName = textField.text ?? ""
    }
}
