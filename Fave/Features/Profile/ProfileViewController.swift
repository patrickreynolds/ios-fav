import Foundation

import UIKit
import Cartography
import MBProgressHUD

class ProfileViewController: FaveVC {

    var user: User? {
        didSet {

            guard let user = user else {
                return
            }

            profileTableHeaderView.updateUserInfo(user: user, followingCount: listsUserFollows.count)

            let titleViewLabel = Label.init(text: user.handle, font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
            navigationItem.titleView = titleViewLabel
        }
    }

    var lists: [List] = [] {
        didSet {
            self.profileTableView.reloadData()

            profileTableHeaderView.updateListInfo(lists: lists)
        }
    }

    var listsUserFollows: [List] = [] {
        didSet {
            guard let user = user else {
                return
            }

            profileTableHeaderView.updateUserInfo(user: user, followingCount: listsUserFollows.count)
        }
    }

    private lazy var profileTableHeaderView: ProfileTableHeaderView = {
        let headerView = ProfileTableHeaderView(dependencyGraph: self.dependencyGraph, user: user)

        headerView.delegate = self

        return headerView
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        button.tintColor = FaveColors.White

        return button
    }()

    private lazy var profileTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = self.profileTableHeaderView
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(ListTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        return refreshControl
    }()

    private lazy var listTableLoadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()

        indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.style = UIActivityIndicatorView.Style.gray

        return indicator
    }()

    private lazy var tabBarMenuButton: UIButton = {
        let button = UIButton.init(type: .custom)

        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(named: "icon-menu"), for: .normal)
        button.adjustsImageWhenHighlighted = false

        return button
    }()

    private lazy var leftBarButton: UIButton = {
        let image = UIImage.init(named: "icon-nav-chevron-left")
        let imageView = UIImageView(image: image)

        constrain(imageView) { imageView in
            imageView.width == 24
            imageView.height == 24
        }

        let button = UIButton.init(frame: .zero)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.tintColor = FaveColors.Black90

        return button
    }()

    init(dependencyGraph: DependencyGraphType, user: User?) {
        self.user = user

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .profileScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        view.addSubview(profileTableView)
        view.addSubview(createButton)

        view.bringSubviewToFront(createButton)

        constrainToSuperview(profileTableView, exceptEdges: [.top])

        constrain(profileTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }

        constrain(createButton, view) { button, view in
            button.right == view.right - 12
            button.bottom == view.bottomMargin - 12
            button.width == 56
            button.height == 56
        }

        let titleViewLabel = Label.init(text: user?.handle ?? "", font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.tabBarMenuButton)

        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButton)
        }

        refreshData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = profileTableView.tableHeaderView {
            tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

            let constraint = NSLayoutConstraint(item: tableHeaderView,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: profileTableView.frame.width)

            tableHeaderView.addConstraint(constraint)

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(0.5) {
                refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {

        let currentUser: User

        if let passedUser = user {
            currentUser = passedUser
        } else if let user = dependencyGraph.storage.getUser() {
            currentUser = user
        } else {
            login()

            return
        }

        // Comment in when the /users/:userId endpoint is live
        dependencyGraph.faveService.getUser(userId: currentUser.id) { user, error in
            guard let unwrappedUser = user else {
                return
            }

            self.user = unwrappedUser
        }

        dependencyGraph.faveService.getLists(userId: currentUser.id) { lists, error in
            guard let unwrappedLists = lists, error == nil else {
                completion()

                return
            }

            self.lists = unwrappedLists

            completion()
        }

        dependencyGraph.faveService.listsUserFollows(userId: currentUser.id) { response, error in
            guard let listsUserFollows = response else {
                return
            }

            self.listsUserFollows = listsUserFollows
        }
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        print("\nOpen menu\n")

        let alertController = UIAlertController(title: "Not yet implemented", message: "Coming soon!", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cool", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:
                alertController.dismiss(animated: true, completion: nil)
            }}))

        self.present(alertController, animated: true, completion: nil)
    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
    }

    private func logUserData(userData: [String: AnyObject]) {
        print("\n\nUser keys: \(Array(userData.keys))\n\n")
        print("User: \(userData.description)")
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileTableView.deselectRow(at: indexPath, animated: true)

        let list = self.lists[indexPath.row]

        let listViewController = ListViewController(dependencyGraph: self.dependencyGraph, list: list)

        let titleViewLabel = Label.init(text: "List", font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        listViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(listViewController, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ListTableViewCell.self, indexPath: indexPath)

        let list = lists[indexPath.row]
        cell.populate(list: list)

        return cell
    }

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

extension ProfileViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {
        refreshData()
    }
}

extension ProfileViewController: CreateItemViewControllerDelegate {
    func didCreateItem() {
        refreshData()
    }
}

extension ProfileViewController: ProfileTableHeaderViewDelegate {
    func editProfileButtonTapped() {
        let editProfileViewController = EditProfileViewController(dependencyGraph: dependencyGraph)
        let editProfileNavigationViewController = UINavigationController.init(rootViewController: editProfileViewController)

        present(editProfileNavigationViewController, animated: true, completion: nil)
    }
}
