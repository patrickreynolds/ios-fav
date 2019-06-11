import UIKit
import Cartography

protocol ShareItemViewControllerDelegate {}

class ShareItemViewController: FaveVC {

    let user: User
    let item: Item

    var delegate: ShareItemViewControllerDelegate? {
        didSet {
            addToListActionView.delegate = self
            copyLinkActionView.delegate = self
            shareToActionView.delegate = self
        }
    }

    var shareActionHandler: (() -> ())?
    var copyLinkActionHandler: (() -> ())?
    var addToListHandler: (() -> ())?

    private lazy var addToListActionView: ShareItemActionView = {
        let actionView = ShareItemActionView.init(shareItemActionType: .addToList)

        return actionView
    }()

    private lazy var copyLinkActionView: ShareItemActionView = {
        let actionView = ShareItemActionView.init(shareItemActionType: .copyLink)

        return actionView
    }()

    private lazy var shareToActionView: ShareItemActionView = {
        let actionView = ShareItemActionView.init(shareItemActionType: .shareTo)

        return actionView
    }()

    private lazy var customShareSheet: UIStackView = {
        let stackView = UIStackView(frame: .zero)

        stackView.addArrangedSubview(addToListActionView)
        stackView.addArrangedSubview(copyLinkActionView)
        stackView.addArrangedSubview(shareToActionView)

        stackView.alignment = .fill
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.axis = .horizontal

        return stackView
    }()

    init(dependencyGraph: DependencyGraphType, user: User, item: Item) {
        self.user = user
        self.item = item

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .shareItemScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        let titleViewLabel = Label.init(text: "Share item", font: FaveFont(style: .h5, weight: .semiBold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))

        view.addSubview(customShareSheet)

        constrain(customShareSheet, view) { customShareSheet, view in
            customShareSheet.top == view.topMargin
            customShareSheet.right == view.right - 8
            customShareSheet.left == view.left + 8
        }
    }

    @objc func dismissView(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
}

extension ShareItemViewController: ShareItemActionViewDelegate {
    func addToListActionTapped() {
        addToListHandler?()
    }

    func shareToActionTapped() {
        shareActionHandler?()
    }

    func copyLinkActionTapped() {
        copyLinkActionHandler?()
    }
}
