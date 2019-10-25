import UIKit

import Cartography

class ResultsTableViewController: FaveVC {

    var filteredUsers: [User] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }

    var usersUserFollows: [Int] = []

    lazy var resultsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(DiscoverUserTableViewCell.self)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .searchResultsScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        view.addSubview(resultsTableView)

        constrainToSuperview(resultsTableView, exceptEdges: [.top])

        constrain(resultsTableView, view) { tableView, view in
            tableView.top == view.topMargin
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

extension ResultsTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DiscoverUserTableViewCell.self, indexPath: indexPath)

        cell.delegate = self

        let user = filteredUsers[indexPath.row]
        let isFollowingUser = usersUserFollows.contains(user.id)

        cell.populate(dependencyGraph: dependencyGraph, user: user, isUserFollowing: isFollowingUser)

        return cell
    }
}

extension ResultsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultsTableView.deselectRow(at: indexPath, animated: true)

        let user = self.filteredUsers[indexPath.row]

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        presentingViewController?.navigationController?.pushViewController(profileViewController, animated: true)
    }
}

extension ResultsTableViewController: DiscoverUserTableViewCellDelegate {

    func didUpdateRelationship(to relationship: FaveRelationshipType, forUser user: User) {

        guard let authenticatedUser = dependencyGraph.storage.getUser() else {
            return
        }

        let row = self.filteredUsers.index(of: user)

        if relationship == .notFollowing {
            // make call to follow list

            dependencyGraph.faveService.unfollowUser(userId: user.id) { success, error in
                if success {
                    if let row = row {
                        self.refreshUsersUserFollows(user: authenticatedUser) { usersUserFollows in
                            self.usersUserFollows = usersUserFollows

                            self.resultsTableView.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: .none)
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

                            self.resultsTableView.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: .none)
                        }
                    }
                } else {
                    // throw error
                }
            }
        }
    }
}
