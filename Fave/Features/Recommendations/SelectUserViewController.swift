import UIKit
import Cartography

protocol SelectUserViewControllerDelegate {
    func selectUsersButtonTapped(selectedUsers: [User])
}

class SelectUserViewController: FaveVC {

    var delegate: SelectUserViewControllerDelegate?

    var isSearching: Bool = false {
        didSet {
//            searchExperienceExpanded = isSearching
        }
    }

    var selectButtonEnabled: Bool = false {
        didSet {
            if selectButtonEnabled {
                let titleString = selectedUsers.count == 1 ? "Select user" : "Select users"

                selectButton.isEnabled = true
                selectButton.backgroundColor = FaveColors.Accent
                let attributedTitle = NSAttributedString(string: titleString,
                                                         font: FaveFont(style: .h5, weight: .semiBold).font,
                                                         textColor: FaveColors.White)

                selectButton.setAttributedTitle(attributedTitle, for: .normal)
            } else {
                selectButton.isEnabled = false
                selectButton.backgroundColor = FaveColors.Black20
                let attributedTitle = NSAttributedString(string: "Select user",
                                                         font: FaveFont(style: .h5, weight: .semiBold).font,
                                                         textColor: FaveColors.Black60)

                selectButton.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
    }

    var selectedUsers: [User] = [] {
        didSet {
//            searchBar.resignFirstResponder()
//            searchBar.setShowsCancelButton(false, animated: true)
//            isSearching = false

            selectButtonEnabled = selectedUsers.isEmpty ? false : true

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

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar.init(frame: .zero)

        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.placeholder = "Search all users"
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

    private lazy var selectButton: UIButton = {
        let button = UIButton.init(frame: .zero)

        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var selectButtonView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.White

        view.addSubview(selectButton)

        constrain(selectButton, view) { selectButton, view in
            selectButton.top == view.top + 8
            selectButton.right == view.right - 16
            selectButton.bottom == view.bottom - 8
            selectButton.left == view.left + 16
        }

        return view
    }()

    init(dependencyGraph: DependencyGraphType, selectedUsers: [User]) {
        self.selectedUsers = selectedUsers

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .shareItemScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        let titleViewLabel = Label.init(text: "Select user(s)", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(dismissView))

        view.addSubview(searchBar)
        view.addSubview(usersTableView)
        view.addSubview(selectButtonView)

        constrain(searchBar, view) { searchBar, view in
            searchBar.top == view.topMargin

            searchBar.right == view.right
            searchBar.left == view.left
        }

        constrain(usersTableView, searchBar, selectButtonView, view) { usersTableView, searchBar, selectButtonView, view in
            usersTableView.top == searchBar.bottom
            usersTableView.right == view.right
            usersTableView.left == view.left
        }

        constrain(selectButtonView, usersTableView, view) { selectButtonView, usersTableView, view in
            selectButtonView.top == usersTableView.bottom
            selectButtonView.right == view.right
            selectButtonView.bottom == view.bottomMargin
            selectButtonView.left == view.left
        }

        refreshUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectButtonEnabled = selectedUsers.isEmpty ? false : true
    }

    @objc func dismissView(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }

    @objc func selectButtonTapped(sender: UIButton!) {
        guard !selectedUsers.isEmpty else {
            // TODO: Throw error

            return
        }

        // Send recommendation request
        // Dismiss view when done
        delegate?.selectUsersButtonTapped(selectedUsers: selectedUsers)

        dismiss(animated: true, completion: nil)
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

extension SelectUserViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchInput = searchText.lowercased()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true

        searchBar.setShowsCancelButton(false, animated: true)
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

extension SelectUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userResults.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        usersTableView.deselectRow(at: indexPath, animated: true)

        let user = userResults[indexPath.row]

        let userAlreadySelected = selectedUsers.map({ $0.id }).contains(user.id)

        if userAlreadySelected {
            selectedUsers = selectedUsers.filter({ $0.id != user.id })
        } else {
            selectedUsers.append(user)
        }
    }
}

extension SelectUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ShareItemUserSearchResultTableViewCell.self, indexPath: indexPath)

        let user = userResults[indexPath.row]

        let isSelected = selectedUsers.map({ $0.id }).contains(user.id)

        cell.populate(user: user, isSelected: isSelected)

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

