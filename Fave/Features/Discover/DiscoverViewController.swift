import Foundation
import UIKit

import Cartography
import MBProgressHUD

class DiscoverViewController: FaveVC {

    var suggestions: [List] = [] {
        didSet {
            discoverTableView.reloadData()
        }
    }

    var users: [User] = [] {
        didSet {
            print("\nUsers: \(users.count)\n")
        }
    }

    var filteredUsers: [User] = [] {
        didSet {

        }
    }

    private lazy var resultsTableController: ResultsTableViewController = {
        let viewController = ResultsTableViewController(dependencyGraph: self.dependencyGraph)


        viewController.delegate = self

        return viewController
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: resultsTableController)

        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none

        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // The default is true.
        searchController.searchBar.delegate = self // Monitor when the search button is tapped.

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

    private lazy var discoverTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01), style: .plain)

//        tableView.delegate = self
//        tableView.dataSource = self
//
//        tableView.tableHeaderView = UIView(frame: .zero)
//        tableView.tableFooterView = UIView(frame: .zero)
//
        tableView.register(UserSearchTableViewCell.self)
//
        tableView.addSubview(self.refreshControl)

        tableView.separatorColor = UIColor.clear

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

        /*
         Search Results Controller Implementation
         ––––––––-––––––––-––––––––-––––––––-––––––––-
         */


        // For iOS 11 and later, place the search bar in the navigation bar.
        navigationItem.searchController = searchController

        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false

        /** Search presents a view controller by applying normal view controller presentation semantics.
         This means that the presentation moves up the view controller hierarchy until it finds the root
         view controller or one that defines a presentation context.
         */

        /** Specify that this view controller determines how the search controller is presented.
         The search controller should be presented modally and match the physical size of this view controller.
         */
        definesPresentationContext = true

        /*
         ––––––––-––––––––-––––––––-––––––––-––––––––-
         End: Search Results Controller Implementation
        */

        let titleViewLabel = Label.init(text: "Discover", font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.addSubview(createButton)

        constrain(createButton, view) { button, view in
            button.right == view.right - 16
            button.bottom == view.bottomMargin - 16
            button.width == 56
            button.height == 56
        }

        view.bringSubviewToFront(createButton)

        refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshData()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(1.0) {
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        dependencyGraph.faveService.suggestions { response, error in
            guard let suggestions = response else {
                // handle error

                return
            }

            self.suggestions = suggestions

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

//        let item = listItems[indexPath.row]
//
//        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item)
//
//        let titleViewLabel = Label.init(text: "Entry", font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
//        itemViewController.navigationItem.titleView = titleViewLabel
//
//        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension DiscoverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DiscoverUserTableViewCell.self, indexPath: indexPath)

//        cell.delegate = self
//
//        let item = listItems[indexPath.row]
//        cell.populate(item: item)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension DiscoverViewController {
    @objc func createButtonTapped(sender: UIButton!) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Entry", style: .default , handler: { alertAction in
            self.addItemButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "List", style: .default , handler: { alertAction in
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

        let createListViewController = CreateListViewController.init(dependencyGraph: self.dependencyGraph)
        let createListNavigationViewController = UINavigationController(rootViewController: createListViewController)

        createListViewController.delegate = self

        present(createListNavigationViewController, animated: true, completion: nil)
    }

    func addItemButtonTapped() {
        print("\n\nAdd Item Button Tapped\n\n")

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }
}

extension DiscoverViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {

    }
}

extension DiscoverViewController: CreateItemViewControllerDelegate {
    func didCreateItem() {

    }
}

extension DiscoverViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if dependencyGraph.authenticator.isLoggedIn() {
            return true
        }

        if viewController == tabBarController.viewControllers?[2] {
            login()

            return false
        } else {
            return true
        }
    }
}

extension DiscoverViewController: ResultsTableViewControllerDelegate {
    func didSelectUser(user: User) {
//        searchController.isActive = false

        let profileViewController = ProfileViewController.init(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label.init(text: user.handle, font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        dismiss(animated: true) {
            delay(0.3, closure: {
                self.navigationController?.pushViewController(profileViewController, animated: true)
            })
        }
    }
}


/* Users search experience */
extension DiscoverViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
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

