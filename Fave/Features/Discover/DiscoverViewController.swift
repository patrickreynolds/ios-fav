import UIKit

import Cartography
import MBProgressHUD

struct SuggestionSection {
    let user: User
    let lists: [List]
}

class DiscoverViewController: FaveVC {

    private let hintArrowImageViewWidth: CGFloat = 48

    var users: [User] = [] {
        didSet {
            print("\nUsers: \(users.count)\n")
        }
    }

    var filteredUsers: [User] = []

    var usersUserFollows: [Int] = [] {
        didSet {
            isLoadingInitialState = false

            resultsTableController.usersUserFollows = usersUserFollows
        }
    }

    private var isLoadingInitialState: Bool = false {
        didSet {
            if isLoadingInitialState {
                loadingIndicator.startAnimating()
            } else {
                delay(0.15) {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
    }

    private lazy var loadingIndicator: IndeterminateCircularIndicatorView = {
        var indicator = IndeterminateCircularIndicatorView()

        return indicator
    }()

    private lazy var resultsTableController: ResultsTableViewController = {
        let viewController = ResultsTableViewController(dependencyGraph: self.dependencyGraph)
        
        viewController.resultsTableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag

        return viewController
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: resultsTableController)

        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none

        searchController.delegate = self
        searchController.searchBar.delegate = self // Monitor when the search button is tapped.
        searchController.searchBar.placeholder = "Search all users"

        return searchController
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        button.tintColor = FaveColors.White

        return button
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        return refreshControl
    }()
    
    private lazy var tableHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56.0))
        
        view.backgroundColor = FaveColors.White
        
        let titleLabel = Label(text: "Friends on Fave",
                              font: FaveFont(style: .h3, weight: .bold),
                              textColor: FaveColors.Black90,
                              textAlignment: .left,
                              numberOfLines: 1)
        
        view.addSubview(titleLabel)
        
        constrain(titleLabel, view) { label, view in
            label.top == view.top + 16
            label.right == view.right - 16
            label.bottom == view.bottom - 8
            label.left == view.left + 16
        }
        
        return view
    }()

    private lazy var discoverTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .grouped)
        
        tableView.backgroundColor = FaveColors.White

        tableView.delegate = self
        tableView.dataSource = self

        tableView.estimatedSectionHeaderHeight = 64
        tableView.sectionHeaderHeight = UITableView.automaticDimension

        tableView.register(DiscoverUserTableViewCell.self)

        tableView.addSubview(self.refreshControl)
        tableView.separatorColor = FaveColors.Black20

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .discoverScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

//        edgesForExtendedLayout = []


        /*
         Search Results Controller Implementation
         ––––––––-––––––––-––––––––-––––––––-––––––––-
         */


//        // For iOS 11 and later, place the search bar in the navigation bar.
        navigationItem.searchController = searchController

        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false

        // Don't hide the navigation bar because the search bar is in it.
        searchController.hidesNavigationBarDuringPresentation = true

        /** Search presents a view controller by applying normal view controller presentation semantics.
         This means that the presentation moves up the view controller hierarchy until it finds the root
         view controller or one that defines a presentation context.
         */

        /** Specify that this view controller determines how the search controller is presented.
         The search controller should be presented modally and match the physical size of this view controller.
         */
        definesPresentationContext = true

        let titleViewLabel = Label(text: "Browse", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        /*
         ––––––––-––––––––-––––––––-––––––––-––––––––-
         End: Search Results Controller Implementation
        */

        view.addSubview(discoverTableView)
        view.addSubview(createButton)
        view.addSubview(loadingIndicator)

        constrain(createButton, view) { button, view in
            button.right == view.right - 12
            button.bottom == view.bottomMargin - 12
            button.width == 56
            button.height == 56
        }

        constrainToSuperview(discoverTableView, exceptEdges: [.top])

        constrain(discoverTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }

        constrain(loadingIndicator, view) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }

        view.bringSubviewToFront(createButton)
        view.bringSubviewToFront(loadingIndicator)

        isLoadingInitialState = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshData()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            self.refreshControl.endRefreshing()
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        if let user = self.dependencyGraph.storage.getUser() {
            refreshUsersUserFollows(user: user) { usersUserFollows in

                self.usersUserFollows = usersUserFollows

                completion()

                self.discoverTableView.reloadData()
            }
        } else {
            self.usersUserFollows = []

            completion()
        }

        dependencyGraph.faveService.getUsers { response, error in
            guard let users = response else {

                return
            }

            self.users = users

            self.discoverTableView.reloadData()
        }
    }

    private func refreshUsersUserFollows(user: User, completion: @escaping (_ users: [Int]) -> ()) {
        self.dependencyGraph.faveService.usersUserFollows(userId: user.id) { response, error in

            guard let usersUserFollows = response else {
                completion([])

                return
            }

            completion(usersUserFollows)
        }
    }
}

extension DiscoverViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        discoverTableView.deselectRow(at: indexPath, animated: true)

        let user = users[indexPath.row]

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }
}

extension DiscoverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DiscoverUserTableViewCell.self, indexPath: indexPath)

        cell.delegate = self

        let user = users[indexPath.row]
        let isFollowingUser = usersUserFollows.contains(user.id)

        cell.populate(dependencyGraph: dependencyGraph, user: user, isUserFollowing: isFollowingUser)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return UIView()

//        let header = DiscoverUserSectionHeaderView(user: user)
//
//        header.delegate = self
//
//        return header
    }
}

extension DiscoverViewController: UIScrollViewDelegate {
}

extension DiscoverViewController {
    @objc func createButtonTapped(sender: UIButton!) {

        sender.performImpact(style: .light)

        guard dependencyGraph.authenticator.isLoggedIn() else {
            login()

            return
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Send a recommendation", style: .default , handler: { alertAction in
            self.recommendItemButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Add an entry", style: .default , handler: { alertAction in
            self.addItemButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Create a list", style: .default , handler: { alertAction in
            self.addListButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alertAction in
            alertController.dismiss(animated: true, completion: nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    func addListButtonTapped() {
        print("\n\nAdd List Button Tapped\n\n")

        let createListViewController = CreateListViewController(dependencyGraph: self.dependencyGraph)
        let createListNavigationViewController = UINavigationController(rootViewController: createListViewController)

        createListViewController.delegate = self

        present(createListNavigationViewController, animated: true, completion: nil)
    }

    func addItemButtonTapped() {
        print("\n\nAdd Item Button Tapped\n\n")

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph, creationType: .addition)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }

    func recommendItemButtonTapped() {
        print("\n\nAdd Item Button Tapped\n\n")

        let createRecommendationViewController = CreateRecommendationViewController(dependencyGraph: self.dependencyGraph)
        let createRecommendationNavigationViewController = UINavigationController(rootViewController: createRecommendationViewController)

        createRecommendationViewController.delegate = self

        createRecommendationViewController.modalPresentationStyle = .overFullScreen

        present(createRecommendationNavigationViewController, animated: true, completion: nil)
    }
}

extension DiscoverViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {
        showToast(title: "Created \(list.title)")

        let listViewController = ListViewController(dependencyGraph: dependencyGraph, list: list)

        let titleViewLabel = Label(text: "\(list.title)", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        listViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(listViewController, animated: true)
    }
}

extension DiscoverViewController: CreateItemViewControllerDelegate {
    func didCreateItem(item: Item) {
        self.showToast(title: "Created \(item.contextualItem.name)")
    }
}

extension DiscoverViewController: DiscoverUserSectionHeaderViewDelegate {
    func didSelectHeaderForUser(user: User) {
        // push on user

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }
}

extension DiscoverViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if dependencyGraph.authenticator.isLoggedIn() {
            return true
        }

        if viewController == tabBarController.viewControllers?[2] || viewController == tabBarController.viewControllers?[3] {
            login()

            return false
        } else {
            return true
        }
    }
}

/* Users search experience */
extension DiscoverViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

//        // Always show the search result controller
        if let searchResultsController = searchController.searchResultsController, searchResultsController.view.isHidden {
            searchController.searchResultsController?.view.alpha = 0
            searchController.searchResultsController?.view.isHidden = false

            UIView.animate(withDuration: 0.3, delay: 0.3, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                searchController.searchResultsController?.view.alpha = 1
            }, completion: nil)
        }

        // Update the filtered array based on the search text.
        let allPotentialResults = users

        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text?.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString?.components(separatedBy: " ") ?? []

        // Build all the "AND" expressions for each value in searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            findMatches(searchString: searchString)
        }

        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)

        let filteredUsers = allPotentialResults.filter { finalCompoundPredicate.evaluate(with: $0) }

        // Apply the filtered results to the search results table.
        if let resultsController = searchController.searchResultsController as? ResultsTableViewController {
            if let searchResultString = strippedString, searchResultString.isEmpty {
                resultsController.filteredUsers = allPotentialResults
            } else {
                resultsController.filteredUsers = filteredUsers
            }
        }
    }

    private func findMatches(searchString: String) -> NSPredicate {
        let predicateUsername = NSPredicate(format: "handle CONTAINS[c] %@", searchString)
        let predicateFristName = NSPredicate(format: "firstName CONTAINS[c] %@", searchString)
        let predicateLastName = NSPredicate(format: "lastName CONTAINS[c] %@", searchString)

        return NSCompoundPredicate(type: .or, subpredicates: [predicateUsername, predicateFristName, predicateLastName])
    }

}

// MARK: - UISearchBarDelegate

extension DiscoverViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


// MARK: - UISearchControllerDelegate

// Use these delegate functions for additional control over the search controller.

extension DiscoverViewController: UISearchControllerDelegate {

    func presentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
}

extension DiscoverViewController: DiscoverUserTableViewCellDelegate {

    func didUpdateRelationship(to relationship: FaveRelationshipType, forUser user: User) {

        guard let authenticatedUser = dependencyGraph.storage.getUser() else {
            return
        }

        let row = self.users.index(of: user)

        if relationship == .notFollowing {
            // make call to follow list

            dependencyGraph.faveService.unfollowUser(userId: user.id) { success, error in
                if success {
                    if let row = row {
                        self.refreshUsersUserFollows(user: authenticatedUser) { usersUserFollows in
                            self.usersUserFollows = usersUserFollows

                            self.discoverTableView.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: .none)

                            NotificationCenter.default.post(name: .shouldRefreshHomeFeed, object: nil)
                        }
                    }
                } else {
                    // throw error
                }
            }
        } else {
            // make call to unfollow list

            dependencyGraph.faveService.followUser(userId: user.id) { success, error in
                if success {
                    if let row = row {
                        self.refreshUsersUserFollows(user: authenticatedUser) { usersUserFollows in
                            self.usersUserFollows = usersUserFollows

                            self.discoverTableView.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: .none)

                            NotificationCenter.default.post(name: .shouldRefreshHomeFeed, object: nil)
                        }
                    }
                } else {
                    // throw error
                }
            }
        }
    }
}

extension DiscoverViewController: CreateRecommendationViewControllerDelegate {
    func didSendRecommendations(selectedUsers: [User]) {
        let titleString = selectedUsers.count == 1 ? "Recommendation sent!" : "Recommendations sent!"

        self.showToast(title: titleString)
    }
}
