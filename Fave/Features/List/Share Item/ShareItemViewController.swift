import UIKit
import Cartography

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

    var lastSelectedUser: User? {
        didSet {
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
            isSearching = false

            sendButtonEnabled = lastSelectedUser == nil ? false : true

            usersTableView.reloadData()
        }
    }

    var currentSearchInput: String = "" {
        didSet {
            usersTableView.reloadData()
        }
    }

    var users: [User] = [] {
        didSet {
            usersTableView.reloadData()
        }
    }

    var userResults: [User] {
        if isSearching && !currentSearchInput.isEmpty {
            return users.filter({ user in
                let fullName = "\(user.firstName) \(user.lastName)".lowercased()
                let handle = user.handle.lowercased()

                let fullNameContainsQuery = fullName.contains(currentSearchInput)
                let handleContainsQuery = handle.contains(currentSearchInput)

                return fullNameContainsQuery || handleContainsQuery
            })
        } else {
            return users
        }
    }

    var shareActionHandler: (() -> ())?
    var copyLinkActionHandler: (() -> ())?
    var addToListHandler: (() -> ())?
    var sendRecommendationHandler: ((_ selectedUser: User, _ item: Item) -> ())?

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

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar.init(frame: .zero)

        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.placeholder = "Search"
        searchBar.delegate = self

        return searchBar
    }()

    private lazy var usersTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0.01))

        tableView.register(ShareItemUserSearchResultTableViewCell.self)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton.init(frame: .zero)

        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var sendButtonView: UIView = {
        let view = UIView.init(frame: .zero)

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

        let titleViewLabel = Label.init(text: "Share item", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))

        view.addSubview(customShareSheet)
        view.addSubview(searchBar)
        view.addSubview(usersTableView)
        view.addSubview(sendButtonView)

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

        searchExperienceExpandedConstraint?.isActive = false

        sendButtonEnabled = false

        refreshUsers()
    }

    @objc func dismissView(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }

    @objc func sendButtonTapped(sender: UIButton!) {
        guard let selecteduser = lastSelectedUser else {
            // TODO: Throw error

            return
        }

        // Send recommendation request
        // Dismiss view when done
        sendRecommendationHandler?(selecteduser, item)
    }

    func refreshUsers() {
        dependencyGraph.faveService.getUsers { users, error in
            guard let users = users else {
                return
            }

            self.users = users
        }
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
        return userResults.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        usersTableView.deselectRow(at: indexPath, animated: true)

        let user = userResults[indexPath.row]

        if let lastSelectedUser = lastSelectedUser, user.id == lastSelectedUser.id {
            self.lastSelectedUser = nil

            return
        }

        lastSelectedUser = userResults[indexPath.row]
    }
}

extension ShareItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ShareItemUserSearchResultTableViewCell.self, indexPath: indexPath)

        let user = userResults[indexPath.row]

        var isSelected = false

        if let selectedUser = lastSelectedUser {
            isSelected = selectedUser.id == user.id
        }

        cell.populate(user: user, isSelected: isSelected)

        return cell
    }
}
