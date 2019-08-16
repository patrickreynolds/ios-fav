import UIKit

import Cartography
import MBProgressHUD

protocol ShareItemViewControllerDelegate {}

class ShareItemViewController: FaveVC {

    let user: User
    let item: Item

    var searchExperienceExpandedConstraint: NSLayoutConstraint?
    var searchExperienceConstraint: NSLayoutConstraint?

    var delegate: ShareItemViewControllerDelegate? {
        didSet {
            addToListActionView.delegate = self
            copyLinkActionView.delegate = self
            shareToActionView.delegate = self
        }
    }

    var searchExperienceExpanded: Bool = false {
        didSet {
            if searchExperienceExpanded {
                searchExperienceExpandedConstraint?.isActive = true
                searchExperienceConstraint?.isActive = false

                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.customShareSheet.alpha = 0
                    self.view.layoutIfNeeded()
                }) { _ in

                }
            } else {
                searchExperienceExpandedConstraint?.isActive = false
                searchExperienceConstraint?.isActive = true

                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.customShareSheet.alpha = 1
                    self.view.layoutIfNeeded()
                }) { _ in

                }
            }
        }
    }

    var isSearching: Bool = false {
        didSet {
            searchExperienceExpanded = isSearching
        }
    }

    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                progressHUD.show(animated: true)
            } else {
                progressHUD.show(animated: false)
            }
        }
    }

    var sendButtonEnabled: Bool = false {
        didSet {
            if sendButtonEnabled {
                sendButton.isEnabled = true
                sendButton.backgroundColor = FaveColors.Accent
                let attributedTitle = NSAttributedString(string: "Send recommendation",
                                                         font: FaveFont(style: .h5, weight: .semiBold).font,
                                                         textColor: FaveColors.White)

                sendButton.setAttributedTitle(attributedTitle, for: .normal)
            } else {
                sendButton.isEnabled = false
                sendButton.backgroundColor = FaveColors.Black20
                let attributedTitle = NSAttributedString(string: "Send recommendation",
                                                         font: FaveFont(style: .h5, weight: .semiBold).font,
                                                         textColor: FaveColors.Black60)

                sendButton.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
    }

    var selectedUsers: [User] = [] {
        didSet {
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
            isSearching = false

            sendButtonEnabled = selectedUsers.isEmpty ? false : true

            usersTableView.reloadData()
        }
    }

    var currentSearchInput: String = "" {
        didSet {
            computeUserResults()
            usersTableView.reloadData()
        }
    }

    var users: [User] = [] {
        didSet {
            computeUserResults()
            usersTableView.reloadData()
        }
    }

    var computedUserResults: [User] = []

    var shareActionHandler: (() -> ())?
    var copyLinkActionHandler: (() -> ())?
    var addToListHandler: (() -> ())?
    var sendRecommendationsHandler: ((_ selectedUsers: [User], _ item: Item, _ completion: (() -> ())?) -> ())?

    private lazy var addToListActionView: ShareItemActionView = {
        let actionView = ShareItemActionView(shareItemActionType: .addToList)

        return actionView
    }()

    private lazy var copyLinkActionView: ShareItemActionView = {
        let actionView = ShareItemActionView(shareItemActionType: .copyLink)

        return actionView
    }()

    private lazy var shareToActionView: ShareItemActionView = {
        let actionView = ShareItemActionView(shareItemActionType: .shareTo)

        return actionView
    }()

    private lazy var progressHUD: MBProgressHUD = {
        let hud = MBProgressHUD(frame: .zero)

        hud.animationType = .fade
        hud.contentColor = FaveColors.Accent

        return hud
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

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)

        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.placeholder = "Search all users"
        searchBar.delegate = self

        return searchBar
    }()

    private lazy var usersTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0.01))

        tableView.register(ShareItemUserSearchResultTableViewCell.self)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var sendButtonView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.White

        view.addSubview(sendButton)

        constrain(sendButton, view) { sendButton, view in
            sendButton.top == view.top + 8
            sendButton.right == view.right - 16
            sendButton.bottom == view.bottom - 8
            sendButton.left == view.left + 16
        }

        return view
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

        let titleViewLabel = Label(text: "Share \(item.title)", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))

        view.addSubview(customShareSheet)
        view.addSubview(searchBar)
        view.addSubview(usersTableView)
        view.addSubview(sendButtonView)
        view.addSubview(progressHUD)

        constrain(customShareSheet, view) { customShareSheet, view in
            customShareSheet.top == view.topMargin
            customShareSheet.right == view.right - 8
            customShareSheet.left == view.left + 8
        }

        constrain(searchBar, customShareSheet, view) { searchBar, customShareSheet, view in
            searchExperienceConstraint = searchBar.top == customShareSheet.bottom
            searchExperienceExpandedConstraint = searchBar.top == view.topMargin

            searchBar.right == view.right
            searchBar.left == view.left
        }

        constrain(usersTableView, searchBar, sendButtonView, view) { usersTableView, searchBar, sendButtonView, view in
            usersTableView.top == searchBar.bottom
            usersTableView.right == view.right
            usersTableView.left == view.left
        }

        constrain(sendButtonView, usersTableView, view) { sendButtonView, usersTableView, view in
            sendButtonView.top == usersTableView.bottom
            sendButtonView.right == view.right
            sendButtonView.bottom == view.bottomMargin
            sendButtonView.left == view.left
        }

        constrain(progressHUD, view) { progressHUD, view in
            progressHUD.centerX == view.centerX
            progressHUD.centerY == view.centerY
        }

        searchExperienceExpandedConstraint?.isActive = false

        refreshUsers()

        view.bringSubviewToFront(progressHUD)
    }

    @objc func dismissView(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }

    @objc func sendButtonTapped(sender: UIButton!) {
        guard !selectedUsers.isEmpty else {
            // TODO: Throw error

            return
        }

        sender.performImpact(style: .light)

        isLoading = true

        // Send recommendation request
        // Dismiss view when done
        sendRecommendationsHandler?(selectedUsers, item) {
            self.isLoading = true
        }
    }

    func refreshUsers() {
        dependencyGraph.faveService.getUsers { users, error in
            guard let users = users else {
                return
            }

            self.users = users
        }
    }

    private func computeUserResults() {
        if isSearching && !currentSearchInput.isEmpty {
            computedUserResults = users.filter({ user in
                let fullName = "\(user.firstName) \(user.lastName)".lowercased()
                let handle = user.handle.lowercased()

                let fullNameContainsQuery = fullName.contains(currentSearchInput)
                let handleContainsQuery = handle.contains(currentSearchInput)

                return fullNameContainsQuery || handleContainsQuery
            })
        } else {
            computedUserResults = users
        }
    }
}

extension ShareItemViewController: ShareItemActionViewDelegate {
    func addToListActionTapped() {
        addToListHandler?()
    }

    func shareToActionTapped() {
        let alertController = UIAlertController(title: "Coming soon!", message: "We're actively working on the ability to share links to Fave lists and entries. Hold tight, and it'll be out before you know it.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Got it", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:
                alertController.dismiss(animated: true, completion: nil)
            }}))
        
        self.present(alertController, animated: true, completion: nil)
        
        /* TODO: Uncomment when universal links are live
        shareActionHandler?()
         */
    }

    func copyLinkActionTapped() {
        let alertController = UIAlertController(title: "Coming soon!", message: "We're actively working on the ability to share links to Fave lists and entries. Hold tight, and it'll be out before you know it.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Got it", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:
                alertController.dismiss(animated: true, completion: nil)
            }}))
        
        self.present(alertController, animated: true, completion: nil)
        
        /* TODO: Uncomment when universal links are live
        copyLinkActionHandler?()
         */
    }
}

extension ShareItemViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchInput = searchText.lowercased()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true

        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false

        print("\n\n Did end editing \n\n")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false

        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false

        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension ShareItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return computedUserResults.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        usersTableView.deselectRow(at: indexPath, animated: true)

        let user = computedUserResults[indexPath.row]

        let userAlreadySelected = selectedUsers.map({ $0.id }).contains(user.id)

        if userAlreadySelected {
            selectedUsers = selectedUsers.filter({ $0.id != user.id })
        } else {
            selectedUsers.append(user)
        }
    }
}

extension ShareItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ShareItemUserSearchResultTableViewCell.self, indexPath: indexPath)

        let user = computedUserResults[indexPath.row]

        let isSelected = selectedUsers.map({ $0.id }).contains(user.id)

        cell.populate(user: user, isSelected: isSelected)

        return cell
    }
}
