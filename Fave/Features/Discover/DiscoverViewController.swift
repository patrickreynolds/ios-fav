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
            discoverTableView.reloadData()
        }
    }

    var filteredUsers: [User] = []

    var usersUserFollows: [Int] = [] {
        didSet {
            discoverTableView.reloadData()
        }
    }

    private var isLoadingInitialState: Bool = false {
        didSet {
            if isLoadingInitialState {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
    }

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()

        indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.hidesWhenStopped = true

        return indicator
    }()
    
    private lazy var noSuggestionsView: UIView = {
        let view = UIView(frame: .zero)
        
        view.backgroundColor = FaveColors.White
        
        let titleLabel = Label(text: "Friends on Fave",
                               font: FaveFont(style: .h4, weight: .bold) ,
                               textColor: FaveColors.Black90,
                               textAlignment: .center,
                               numberOfLines: 1)
        
        let subtitleLabel = Label(text: "After signing up with Facebook, you'll see your friends on Fave right here. \n\nMeanwhile, you can search for people above to browse around.",
                                  font: FaveFont(style: .h5, weight: .regular) ,
                                  textColor: FaveColors.Black70,
                                  textAlignment: .center,
                                  numberOfLines: 0)
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        constrain(titleLabel, subtitleLabel, view) { titleLabel, subtitleLabel, view in
            titleLabel.top == view.top
            titleLabel.right == view.right - 16
            titleLabel.left == view.left + 16
            
            subtitleLabel.top == titleLabel.bottom + 8
            subtitleLabel.right == view.right - 16
            subtitleLabel.left == view.left + 16
            subtitleLabel.bottom == view.bottom
        }
        
        return view
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
        tableView.register(UserTableViewCell.self)

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
        view.addSubview(noSuggestionsView)
        view.addSubview(createButton)
        view.addSubview(loadingIndicator)

        constrain(createButton, view) { button, view in
            button.right == view.right - 12
            button.bottom == view.bottomMargin - 12
            button.width == 56
            button.height == 56
        }

        constrainToSuperview(discoverTableView, exceptEdges: [.top])
        
        constrain(noSuggestionsView, view) { suggestionsView, view in
            suggestionsView.top == view.top + 168
            suggestionsView.right == view.right - 16
            suggestionsView.left == view.left + 16
        }

        constrain(discoverTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }

        constrain(loadingIndicator, view) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }

        view.bringSubviewToFront(createButton)
        view.bringSubviewToFront(loadingIndicator)

        noSuggestionsView.alpha = 0
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
            self.dependencyGraph.faveService.usersUserFollows(userId: user.id) { response, error in

                self.isLoadingInitialState = false

                guard let usersUserFollows = response else {

                    completion()

                    return
                }

                self.usersUserFollows = usersUserFollows

                completion()
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

            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.discoverTableView.alpha = 0
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

        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.discoverTableView.alpha = 1
        }, completion: nil)
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
}

extension DiscoverViewController: DiscoverUserTableViewCellDelegate {

    func didUpdateRelationship(to relationship: FaveRelationshipType, forUser user: User) {

        if relationship == .notFollowing {
            // make call to follow list

            dependencyGraph.faveService.unfollowUser(userId: user.id) { success, error in
                if success {
                    self.refreshData()
                } else {
                    // throw error
                }
            }
        } else {
            // make call to unfollow list

            dependencyGraph.faveService.followUser(userId: user.id) { success, error in
                if success {
                    self.refreshData()
                } else {
                    // throw error
                }
            }
        }
    }

    func showLogin() {
        login()
    }
}

extension DiscoverViewController: CreateRecommendationViewControllerDelegate {
    func didSendRecommendations(selectedUsers: [User]) {
        let titleString = selectedUsers.count == 1 ? "Recommendation sent!" : "Recommendations sent!"

        self.showToast(title: titleString)
    }
}
