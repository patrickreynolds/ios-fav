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
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(FeedEventTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .homescreenFeedScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        tabBarController?.delegate = self

        let titleViewLabel = Label(text: "Home", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.addSubview(loadingIndicatorView)
        view.addSubview(welcomeView)
        view.addSubview(feedTableView)
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

        view.bringSubviewToFront(loadingIndicatorView)
        view.bringSubviewToFront(createButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshFeed()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadingIndicatorView.isHidden = true

        refreshFeed()
    }

    func refreshFeed() {
        loadingIndicatorView.startAnimating()

        if dependencyGraph.authenticator.isLoggedIn() {
            loadingIndicatorView.isHidden = true
            
            dependencyGraph.faveService.getFeed(from: 0, to: 100) { response, error in
                self.loadingIndicatorView.stopAnimating()
                self.refreshControl.endRefreshing()

                guard let events = response else {
                    return
                }

                self.events = events
            }

            dependencyGraph.faveService.getCurrentUser { user, error in
                guard let user = user else {
                    if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
                        tabBarItem.image = UIImage(named: "tab-icon-profile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                        tabBarItem.selectedImage = UIImage(named: "tab-icon-profile-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    }

                    self.dependencyGraph.authenticator.logout { success in
                        print("Logged out")
                    }

                    return
                }

                self.dependencyGraph.storage.saveUser(user: user)

                self.updateUI()

                if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
                    let tabBarItemImage = UIImage(base64String: user.profilePicture)?
                        .resize(targetSize: CGSize(width: 24, height: 24))?
                        .roundedImage?
                        .withRenderingMode(.alwaysOriginal)
                    tabBarItem.image = tabBarItemImage
                    tabBarItem.selectedImage = tabBarItemImage
                }
            }
        } else {
            updateUI()

            dependencyGraph.faveService.topLists { topLists, error in
                self.topLists = topLists ?? []

                self.loadingIndicatorView.stopAnimating()
            }
        }
    }

    func updateUI() {
        if dependencyGraph.authenticator.isLoggedIn() {
            feedTableView.alpha = 1
            feedTableView.isHidden = false
            welcomeView.alpha = 0
            welcomeView.isHidden = true
        } else {
            feedTableView.alpha = 0
            feedTableView.isHidden = true
            welcomeView.alpha = 1
            welcomeView.isHidden = false
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

extension FeedViewController: UITableViewDelegate {}

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

        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item, list: list)

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
        let itemViewController = ItemViewController(dependencyGraph: dependencyGraph, item: item, list: list)

        let titleViewLabel = Label(text: "Place", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension FeedViewController: ListViewControllerDelegate {
    func didRemoveList(viewController: FaveVC) {
        viewController.navigationController?.popViewController(animated: true)

        refreshFeed()
    }
}
