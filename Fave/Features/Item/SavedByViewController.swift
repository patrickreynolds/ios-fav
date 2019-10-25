import UIKit

import Cartography

class SavedByViewController: FaveVC {
    let item: Item

    var users: [User] = [] {
        didSet {
            savedByTableView.reloadData()
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

    private lazy var loadingIndicator: IndeterminateCircularIndicatorView = {
        var indicator = IndeterminateCircularIndicatorView()

        return indicator
    }()

    private lazy var savedByTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))

        tableView.register(UserTableViewCell.self)

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)

        tableView.separatorColor = FaveColors.Black30
        tableView.backgroundColor = FaveColors.White

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType, item: Item) {
        self.item = item

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .savedByScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButton)

        view.addSubview(savedByTableView)
        view.addSubview(loadingIndicator)

        constrainToSuperview(savedByTableView)

        constrain(loadingIndicator, view) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }

        view.bringSubviewToFront(loadingIndicator)

        loadingIndicator.startAnimating()

        refreshData() {
            self.loadingIndicator.stopAnimating()
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        // TODO: Figure out API call to get all the users and/or lists that have saved this item
        // dependencyGraph.faveService.usersWhoSavedItem

//        dependencyGraph.faveService.usersWhoSavedItem(listId: item.id) { users, error in
//            completion()
//
//            guard let users = users else {
//                // TODO: Throw error
//
//                return
//            }
//
//            self.users = users
//        }
    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension SavedByViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UserTableViewCell.self, indexPath: indexPath)

        let user = users[indexPath.row]
        cell.populate(user: user)

        return cell
    }
}

extension SavedByViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        savedByTableView.deselectRow(at: indexPath, animated: true)

        let user = self.users[indexPath.row]

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }
}
