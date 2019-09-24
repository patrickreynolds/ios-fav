import UIKit
import Cartography
import MBProgressHUD

class FeedViewController: FaveVC {

    var user: User?
    var lastPage: Int = 1

    var topLists: [List] = [] {
        didSet {
            welcomeView.update(withTopLists: topLists, dependencyGraph: self.dependencyGraph)
        }
    }

    var events: [FeedEvent] = [] {
        didSet {
            feedTableView.reloadData()

            let hasEvents = !events.isEmpty

            if hasEvents {
                UIView.animate(withDuration: 0.15, animations: {
                    self.noEventsView.alpha = 0
                    self.feedTableView.alpha = 1
                }, completion: { _ in
                    self.noEventsView.isHidden = hasEvents
                })
            } else {

                self.noEventsView.isHidden = hasEvents

                UIView.animate(withDuration: 0.15, animations: {
                    self.noEventsView.alpha = 1
                    self.feedTableView.alpha = 0
                }, completion: { _ in
                })
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                loadingIndicatorView.startAnimating()
            } else {
                showCreateButton()

                loadingIndicatorView.stopAnimating()
            }
        }
    }

    var loggedIn: Bool = false {
        didSet {
//            if loggedIn {
                feedTableView.isHidden = false
                createButton.alpha = 1

                UIView.animate(withDuration: 0.2, animations: {
                    self.feedTableView.alpha = 1
                    self.welcomeView.alpha = 0
                }, completion: { _ in
                    self.welcomeView.isHidden = true
                })

                if !isLoading {
                    showCreateButton()
                }
//            } else {

                // After splash screen, this shouldn't happen

//                welcomeView.isHidden = false
//                createButton.alpha = 0
//                createButton.transform = CGAffineTransform(scaleX: 0, y: 0)
//
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.feedTableView.alpha = 0
//                    self.welcomeView.alpha = 1
//                }, completion: { _ in
//                    self.feedTableView.isHidden = true
//                })
//            }
        }
    }

    private lazy var createButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        button.tintColor = FaveColors.White

        button.alpha = 0

        return button
    }()

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(frame: .zero)

        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.style = .gray

        return loadingIndicatorView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        return refreshControl
    }()

    private lazy var welcomeView: FaveLoggedOutWelcomeView = {
        let view = FaveLoggedOutWelcomeView()

        view.delegate = self

        return view
    }()

    private lazy var feedTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(FeedEventTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        tableView.separatorColor = UIColor.clear

        tableView.estimatedRowHeight = 2.0

        return tableView
    }()

    private lazy var noEventsView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.White

        let titleLabel = Label(text: "Events on Fave",
                               font: FaveFont(style: .h4, weight: .bold) ,
                               textColor: FaveColors.Black90,
                               textAlignment: .center,
                               numberOfLines: 1)

        let subtitleLabel = Label(text: "New updates will show here when you follow your first list, or your friends join Fave.",
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


    // MARK: - Initializers

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .homescreenFeedScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UIViewController Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        tabBarController?.delegate = self

        let titleViewLabel = Label(text: "Home", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.addSubview(loadingIndicatorView)
        view.addSubview(welcomeView)
        view.addSubview(feedTableView)
        view.addSubview(noEventsView)
        view.addSubview(createButton)

        constrainToSuperview(welcomeView, exceptEdges: [.top, .bottom])
        constrainToSuperview(feedTableView, exceptEdges: [.top])

        constrain(welcomeView, view) { welcomeView, view in
            welcomeView.top == view.topMargin
            welcomeView.bottom == view.bottomMargin
        }

        constrain(feedTableView, view) { tableView, view in
            tableView.top == view.topMargin + 8
        }

        constrain(createButton, view) { button, view in
            button.right == view.right - 12
            button.bottom == view.bottomMargin - 12
            button.width == 56
            button.height == 56
        }

        constrain(loadingIndicatorView, view) { loadingIndicatorView, view in
            loadingIndicatorView.centerY == view.centerY
            loadingIndicatorView.centerX == view.centerX
        }

        constrain(noEventsView, view) { suggestionsView, view in
            suggestionsView.top == view.top + 120
            suggestionsView.right == view.right - 16
            suggestionsView.left == view.left + 16
        }

        view.bringSubviewToFront(loadingIndicatorView)
        view.bringSubviewToFront(createButton)
        view.bringSubviewToFront(noEventsView)

        welcomeView.alpha = 0
        welcomeView.isHidden = true
        feedTableView.alpha = 0
        feedTableView.isHidden = true
        createButton.alpha = 0
        createButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        noEventsView.alpha = 0
        noEventsView.isHidden = true

        isLoading = true

        refreshFeed()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshFeedFromOnboarding), name: .shouldRefreshHomeFeed, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if events.isEmpty {
            refreshFeed()
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshFeed()
    }

    @objc func refreshFeedFromOnboarding() {
        events = []

        refreshFeed()
    }

    @objc func refreshFeed(completion: @escaping () -> () = {}) {

        if dependencyGraph.authenticator.isLoggedIn() {
            isLoading = events.isEmpty

            loggedIn = true

            dependencyGraph.faveService.getFeed(from: 0, to: 100) { response, error in
                self.refreshControl.endRefreshing()

                self.isLoading = false

                completion()

                guard let events = response else {
                    return
                }

                self.events = events
            }

            guard let user = dependencyGraph.storage.getUser() else {

                dependencyGraph.faveService.getCurrentUser { user, error in

                    guard let user = user else {
                        if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
                            tabBarItem.image = UIImage(named: "tab-icon-profile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                            tabBarItem.selectedImage = UIImage(named: "tab-icon-profile-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                        }

                        self.dependencyGraph.authenticator.logout { success in
                            print("Logged out")
                        }

                        self.loggedIn = false

                        return
                    }

                    self.dependencyGraph.storage.saveUser(user: user)
                    self.user = user
                    self.loggedIn = true
                }

                return
            }

            self.user = user

            updateProfileTabPhoto()
        } else {
            if !topLists.isEmpty {
                isLoading = false
            }

            loggedIn = false

            dependencyGraph.faveService.topLists { topLists, error in
                self.isLoading = false

                self.topLists = topLists ?? []

                completion()
            }
        }
    }

    private func showCreateButton() {
        if !isLoading && loggedIn {
            self.createButton.alpha = 1

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.2, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.createButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }

    private func updateProfileTabPhoto() {
        guard let user = self.user else {
            return
        }

        if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
            let tabBarItemImage = UIImage(base64String: user.profilePicture)?
                .resize(targetSize: CGSize(width: 24, height: 24))?
                .roundedImage?
                .withRenderingMode(.alwaysOriginal)
            tabBarItem.image = tabBarItemImage
            tabBarItem.selectedImage = tabBarItemImage
        }
    }
}

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FeedEventTableViewCell.self, indexPath: indexPath)

        cell.delegate = self

        let event = events[indexPath.row]
        cell.populate(dependencyGraph: dependencyGraph, event: event)

        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        let minTime = Double(min((0.01 * Double(indexPath.row)), 0.1))

        UIView.animate(withDuration: 0.1, delay: minTime, animations: {
            cell.alpha = 1
        })
    }
}

extension FeedViewController {
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

extension FeedViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {

    }
}

extension FeedViewController: CreateItemViewControllerDelegate {
    func didCreateItem(item: Item) {
        self.showToast(title: "Created \(item.contextualItem.name)")
    }
}

extension FeedViewController: UITabBarControllerDelegate {
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

extension FeedViewController: FeedEventTableViewCellDelegate {
    func userProfileSelected(user: User) {
        print("profile selected for \(user.id)")

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }

    func listItemSelected(item: Item, list: List) {

        print("item selected for \(item.id)")

        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item)

        let titleViewLabel = Label(text: "Entry", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension FeedViewController: CreateRecommendationViewControllerDelegate {
    func didSendRecommendations(selectedUsers: [User]) {
        let titleString = selectedUsers.count == 1 ? "Recommendation sent!" : "Recommendations sent!"

        self.showToast(title: titleString)
    }
}

extension FeedViewController: FaveLoggedOutWelcomeViewDelegate {
    func didSelectUser(user: User) {
        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label(text: user.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }

    func didSelectList(list: List) {
        let listViewController = ListViewController(dependencyGraph: dependencyGraph, list: list)

        listViewController.delegate = self

        let titleViewLabel = Label(text: "List", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        listViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(listViewController, animated: true)
    }

    func didSelectItem(item: Item, list: List) {
        let itemViewController = ItemViewController(dependencyGraph: dependencyGraph, item: item)

        let titleViewLabel = Label(text: "Place", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(itemViewController, animated: true)
    }

    func didSelectSignUp() {
        login()
    }
}

extension FeedViewController: ListViewControllerDelegate {
    func didRemoveList(viewController: FaveVC) {
        viewController.navigationController?.popViewController(animated: true)

        refreshFeed()
    }
}
