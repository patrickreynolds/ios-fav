import UIKit

import Cartography

enum LoadingState {
    case loading
    case presenting
}

class FollowedByViewController: FaveVC {
    let list: List

    var state: LoadingState = .presenting {
        didSet {

        }
    }

    var followers: [User] = [] {
        didSet {
            followedByTableView.reloadData()
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

    private lazy var followedByTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))

        tableView.register(UserTableViewCell.self)

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)

        tableView.separatorColor = FaveColors.Black30
        tableView.backgroundColor = FaveColors.White

        tableView.refreshControl = refreshControl

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType, list: List) {
        self.list = list

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .followedByScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButton)

        view.addSubview(followedByTableView)

        constrainToSuperview(followedByTableView)

        refreshControl.refreshManually()
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        state = .loading

            dependencyGraph.faveService.getList(listId: list.id) { list, error in
                completion()

                self.state = .presenting

                guard let list = list else {
                    // TODO: Throw error

                    return
                }

                self.followers = list.followers
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

extension FollowedByViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UserTableViewCell.self, indexPath: indexPath)

        let user = followers[indexPath.row]
        cell.populate(user: user)

        return cell
    }
}

extension FollowedByViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        followedByTableView.deselectRow(at: indexPath, animated: true)

        let user = self.followers[indexPath.row]

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }
}
