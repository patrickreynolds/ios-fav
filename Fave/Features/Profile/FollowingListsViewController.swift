import UIKit

import Cartography

class FollowingListViewController: FaveVC {
    let user: User

    var state: LoadingState = .presenting {
        didSet {

        }
    }

    var listsUserFollows: [List] = [] {
        didSet {
            followingTableView.reloadData()
        }
    }

    private lazy var leftBarButton: UIButton = {
        let image = UIImage(named: "icon-nav-chevron-left")
        let imageView = UIImageView(image: image)

        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.tintColor = FaveColors.Black90
        button.contentHorizontalAlignment = .left

        constrain(imageView) { imageView in
            imageView.width == 24
            imageView.height == 24
        }

        constrain(button) { button in
            button.width == 40
            button.height == 24
        }

        return button
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        return refreshControl
    }()

    private lazy var followingTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))

        tableView.register(ListTableViewCell.self)

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)

        tableView.separatorColor = FaveColors.Black30
        tableView.backgroundColor = FaveColors.White

        tableView.refreshControl = refreshControl

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType, user: User) {
        self.user = user

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .followingListsScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButton)

        view.addSubview(followingTableView)

        constrainToSuperview(followingTableView)

        refreshControl.refreshManually()
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        state = .loading

        dependencyGraph.faveService.listsUserFollows(userId: user.id) { response, error in
            completion()

            self.state = .presenting

            guard let listsUserFollows = response else {
                return
            }

            self.listsUserFollows = listsUserFollows
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            self.refreshControl.endRefreshing()
        }
    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension FollowingListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listsUserFollows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ListTableViewCell.self, indexPath: indexPath)

        let list = listsUserFollows[indexPath.row]
        cell.populate(list: list)

        return cell
    }
}

extension FollowingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        followingTableView.deselectRow(at: indexPath, animated: true)

        let list = self.listsUserFollows[indexPath.row]

        let listViewController = ListViewController(dependencyGraph: dependencyGraph, list: list)

        let titleViewLabel = Label(text: "Following", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        listViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(listViewController, animated: true)
    }
}
