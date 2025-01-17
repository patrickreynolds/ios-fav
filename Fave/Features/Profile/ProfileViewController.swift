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

            let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
            navigationItem.titleView = titleViewLabel

            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }

    var lists: [List] = [] {
        didSet {
            profileTableHeaderView.updateListInfo(lists: lists)
            view.setNeedsLayout()

            self.profileTableView.reloadData()
            TimeIntervalEventTracker.trackEnd(event: .userPrecievedProfileResponseTime)
        }
    }

    var listsUserFollows: [List] = [] {
        didSet {
            guard let user = user else {
                return
            }

            profileTableHeaderView.updateUserInfo(user: user, followingCount: listsUserFollows.count)

            view.setNeedsLayout()
            view.layoutIfNeeded()
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
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

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

    private lazy var listTableLoadingIndicator: IndeterminateCircularIndicatorView = {
        var indicator = IndeterminateCircularIndicatorView()

        return indicator
    }()

    private lazy var tabBarMenuButton: UIButton = {
        let image = UIImage(named: "icon-menu")
        let imageView = UIImageView(image: image)

        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.tintColor = FaveColors.Black90
        button.adjustsImageWhenHighlighted = false
        button.contentHorizontalAlignment = .right

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
        view.addSubview(listTableLoadingIndicator)
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

        constrain(listTableLoadingIndicator, view) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }

        let titleViewLabel = Label(text: user?.handle ?? "", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButton)
        }

        if let user = dependencyGraph.storage.getUser(), let currentPageUser = self.user, user.id != currentPageUser.id {
            navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.tabBarMenuButton)
        }

        view.bringSubviewToFront(listTableLoadingIndicator)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let storedUser = dependencyGraph.storage.getUser() else {
            return
        }

        if let navigationController = navigationController, navigationController.viewControllers.count == 1 {
            self.user = storedUser
        }

        if lists.isEmpty {
            listTableLoadingIndicator.startAnimating()
        }

        refreshData() {
            self.listTableLoadingIndicator.stopAnimating()
        }
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

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(0) {
                refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {

        TimeIntervalEventTracker.trackStart(event: .userPrecievedProfileResponseTime)

        let currentUser: User

        if let passedUser = user {
            currentUser = passedUser
        } else if let user = dependencyGraph.storage.getUser() {
            currentUser = user

            if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
                let tabBarItemImage = UIImage(base64String: user.profilePicture)?
                    .resize(targetSize: CGSize(width: 24, height: 24))?
                    .roundedImage?
                    .withRenderingMode(.alwaysOriginal)
                tabBarItem.image = tabBarItemImage
                tabBarItem.selectedImage = tabBarItemImage
            }
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

            // TODO: Uncomment this if we want to hide recommendations again
             let lists = unwrappedLists.filter({ $0.title.lowercased() != "recommendations" && $0.title.lowercased() != "saved for later" })
//            let lists = unwrappedLists.filter({ $0.title.lowercased() != "saved for later" })

            self.lists = lists

            completion()
        }

        dependencyGraph.faveService.listsUserFollows(userId: currentUser.id) { response, error in
            guard let listsUserFollows = response else {
                return
            }

            self.listsUserFollows = listsUserFollows
        }

        if let loggedInUser = self.dependencyGraph.storage.getUser() {

            dependencyGraph.faveService.usersUserFollows(userId: loggedInUser.id) { userIds, error in
                guard let userIds = userIds else {
                    self.profileTableHeaderView.updateRelationship(relationship: .notFollowing)

                    return
                }

                let relationship: UserRelationship

                guard let loggedInUser = self.dependencyGraph.storage.getUser() else {
                    self.profileTableHeaderView.updateRelationship(relationship: .notFollowing)

                    return
                }

                if loggedInUser.id == currentUser.id {
                    self.profileTableHeaderView.updateRelationship(relationship: .notFollowing)

                    return
                }

                if userIds.contains(currentUser.id) {
                    relationship = .following
                } else {
                    relationship = .notFollowing
                }

                self.profileTableHeaderView.updateRelationship(relationship: relationship)
            }

        }

    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
    }

    private func logUserData(userData: [String: AnyObject]) {
        print("\n\nUser keys: \(Array(userData.keys))\n\n")
        print("User: \(userData.description)")
    }

    @objc func createButtonTapped(sender: UIButton!) {

        sender.performImpact(style: UIImpactFeedbackGenerator.FeedbackStyle.light)

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

    private func showPushNotificationsPrompt(dependencyGraph: DependencyGraphType, viewController: FaveVC) {
        if dependencyGraph.authenticator.isLoggedIn() {

            PushNotifications.shouldPromptToRegisterForNotifications(dependencyGraph: dependencyGraph) { shouldPrompt in

                guard shouldPrompt else {
                    return
                }

                PushNotifications.promptForPushNotifications(dependencyGraph: dependencyGraph, fromViewController: viewController) {}
            }
        }
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        guard let currentPageUser = user else {
            return
        }

        if let user = dependencyGraph.storage.getUser(), user.id != currentPageUser.id {
            alertController.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { alertAction in
                self.blockUser(user: currentPageUser)

                alertController.dismiss(animated: true, completion: nil)
            }))

            alertController.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { alertAction in
                self.reportUser(user: currentPageUser)

                alertController.dismiss(animated: true, completion: nil)
            }))
        }

        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alertAction in
            alertController.dismiss(animated: true, completion: nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    private func blockUser(user: User) {
        relationshipButtonTapped(relationship: UserRelationship.following, userId: user.id, forceUnfollow: true)
    }

    private func reportUser(user: User) {
        showToast(title: "\(user.handle) reported")
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileTableView.deselectRow(at: indexPath, animated: true)

        let list = self.lists[indexPath.row]

        let listViewController = ListViewController(dependencyGraph: self.dependencyGraph, list: list)

        listViewController.delegate = self

        let titleViewLabel = Label(text: "Collection", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        listViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(listViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.alpha = 0
//
//        let minTime = Double(min((0.01 * Double(indexPath.row)), 0.1))
//
//        UIView.animate(withDuration: 0.2, delay: minTime, animations: {
//            cell.alpha = 1
//        })
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
}

extension ProfileViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {
        showToast(title: "Created \(list.title)")

        refreshData()

        showPushNotificationsPrompt(dependencyGraph: dependencyGraph, viewController: self)
    }
}

extension ProfileViewController: CreateItemViewControllerDelegate {
    func didCreateItem(item: Item) {
        showToast(title: "Created \(item.contextualItem.name)")

        refreshData()
    }
}

extension ProfileViewController: ProfileTableHeaderViewDelegate {
    func editProfileButtonTapped() {
        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        let editProfileViewController = EditProfileViewController(dependencyGraph: dependencyGraph, user: user)
        let editProfileNavigationViewController = UINavigationController(rootViewController: editProfileViewController)

        editProfileViewController.delegate = self

        present(editProfileNavigationViewController, animated: true, completion: nil)
    }

    func didTapFollowingListsLabel(user: User) {
        let followingListsViewController = FollowingListViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: "Following", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        followingListsViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(followingListsViewController, animated: true)
    }

    func relationshipButtonTapped(relationship: UserRelationship, userId: Int, forceUnfollow: Bool = false) {
        switch relationship {
         case .loading:
            return
        case .following:
            // unfollow

            profileTableHeaderView.updateRelationship(relationship: .notFollowing)

            dependencyGraph.faveService.unfollowUser(userId: userId) { success, error in
                if !success {

                    // Show toast that something went wrong
                    if !forceUnfollow {
                        self.profileTableHeaderView.updateRelationship(relationship: .following)
                    }
                }
            }
        case .notFollowing:
            // follow
            profileTableHeaderView.updateRelationship(relationship: .following)

            dependencyGraph.faveService.followUser(userId: userId) { success, error in
                if !success {
                    // Show toast that something went wrong
                    self.profileTableHeaderView.updateRelationship(relationship: .notFollowing)
                }
            }
        }
    }
}

extension ProfileViewController: EditProfileViewControllerDelegate {
    func didLogout() {
        if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
            tabBarItem.image = UIImage(named: "tab-icon-profile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-profile-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
    }
}

extension ProfileViewController: CreateRecommendationViewControllerDelegate {
    func didSendRecommendations(selectedUsers: [User]) {
        let titleString = selectedUsers.count == 1 ? "Recommendation sent!" : "Recommendations sent!"

        self.showToast(title: titleString)
    }
}

extension ProfileViewController: ListViewControllerDelegate {
    func didRemoveList(viewController: FaveVC) {
        viewController.navigationController?.popViewController(animated: true)

        refreshData()
    }
}
