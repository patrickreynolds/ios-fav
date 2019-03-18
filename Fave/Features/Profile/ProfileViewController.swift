import Foundation

import UIKit
import Cartography
import MBProgressHUD

class ProfileViewController: FaveVC {

    private lazy var lists: [List] = {
        let list1Items: [Item] = [
            Item.init(name: "Item 1"),
            Item.init(name: "Item 2"),
            Item.init(name: "Item 3")
        ]

        let list2Items: [Item] = [
            Item.init(name: "Item A"),
            Item.init(name: "Item B"),
            Item.init(name: "Item C")
        ]

        let list3Items: [Item] = [
            Item.init(name: "Item Doe"),
            Item.init(name: "Item Ray"),
            Item.init(name: "Item Mi")
        ]

        let list1 = List.init(title: "Favorite Wings in SF", followers: 12, items: list1Items)
        let list2 = List.init(title: "Best SF Photo Spots", followers: 598, items: list2Items)
        let list3 = List.init(title: "Bucketlist Locations", followers: 298, items: list3Items)

        return [list1, list2, list3]
    }()

    private lazy var profileTableHeaderView: ProfileTableViewHeader = {
        return ProfileTableViewHeader(dependencyGraph: self.dependencyGraph, user: self.dependencyGraph.storage.getUser())
    }()

    private lazy var profileTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 667))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = self.profileTableHeaderView

        tableView.register(ListTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)

        refreshControl.tintColor = FaveColors.Accent

        return refreshControl
    }()

    private lazy var listTableLoadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()

        indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.style = UIActivityIndicatorView.Style.gray

        return indicator
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .profileScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        view.addSubview(profileTableView)

        constrainToSuperview(profileTableView)

        refreshData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = self.profileTableView.tableHeaderView {
            tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

            let constraint = NSLayoutConstraint(item: tableHeaderView,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: self.profileTableView.frame.width)

            tableHeaderView.addConstraint(constraint)

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let user = self.dependencyGraph.storage.getUser() else {
            return
        }

        self.navigationController?.navigationBar.topItem?.title = user.handle
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(2.0) {
                self.profileTableView.reloadData()

                refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        dependencyGraph.faveService.getCurrentUser { response, error in
            if let userData = response, let user = User(data: userData) {
                self.dependencyGraph.storage.saveUser(user: user)
                self.profileTableHeaderView.updateUserInfo(user: user)

                self.logUserData(userData: userData)
            }

            completion()
        }
    }

    private func logUserData(userData: [String: AnyObject]) {
        print("\n\nUser keys: \(Array(userData.keys))\n\n")
        print("User: \(userData.description)")
    }
}

extension ProfileViewController: UITableViewDelegate {}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ListTableViewCell.self, indexPath: indexPath)

        let list = lists[indexPath.row]
        cell.populate(list: list)

        return cell
    }
}
