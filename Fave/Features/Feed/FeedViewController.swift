import UIKit
import Cartography
import MBProgressHUD

class FeedViewController: FaveVC {

    var user: User?
    let hintArrowImageViewWidth: CGFloat = 32

    var isLoading: Bool = true {
        didSet {
            if isLoading {
                view.bringSubviewToFront(loadingIndicatorView)
                loadingIndicatorView.startAnimating()
            } else {
                showCreateButton()

                loadingIndicatorView.stopAnimating()
            }
        }
    }

    var loggedIn: Bool = false {
        didSet {
            feedTableView.isHidden = false
            createButton.alpha = 1

            UIView.animate(withDuration: 0.2, animations: {
                self.feedTableView.alpha = 1

            }, completion: { _ in

            })

            if !isLoading {
                showCreateButton()
            }
        }
    }

    private lazy var feedViewModel: FeedViewModel = {
        let feedViewModel = FeedViewModel(delegate: self)

        return feedViewModel
    }()

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

    private lazy var loadingIndicatorView: IndeterminateCircularIndicatorView = {
        var indicator = IndeterminateCircularIndicatorView()

        return indicator
    }()

    private lazy var footerLoadingIndicatorView: IndeterminateCircularIndicatorView = {
        var indicator = IndeterminateCircularIndicatorView()

        constrain(indicator) { indicator in
            indicator.width == 32
            indicator.height == 32
        }

        return indicator
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        return refreshControl
    }()

    private lazy var feedTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .grouped)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(FeedEventTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        tableView.separatorColor = UIColor.clear

        tableView.estimatedRowHeight = 2.0
        tableView.backgroundColor = FaveColors.White

        return tableView
    }()

    private lazy var noEventsView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = FaveColors.White

        let titleLabel = Label(text: "Updates from friends",
                               font: FaveFont(style: .h4, weight: .bold) ,
                               textColor: FaveColors.Black90,
                               textAlignment: .center,
                               numberOfLines: 1)

        let subtitleLabel = Label(text: "Follow your friends on Fave and you'll see their updates right here.",
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

    private lazy var hintArrowImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "illustration-search-users-hint")
        imageView.tintColor = FaveColors.HJLightningYellow

        constrain(imageView) { imageView in
            imageView.width == hintArrowImageViewWidth
        }

        return imageView
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
        view.addSubview(feedTableView)
        view.addSubview(noEventsView)
        view.addSubview(createButton)
        view.addSubview(hintArrowImageView)

        constrainToSuperview(feedTableView, exceptEdges: [.top])

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
            suggestionsView.right == view.right - 16
            suggestionsView.left == view.left + 16

            let noEventsViewTopMargin: CGFloat

            if FaveDeviceSize.isIPhone5sOrLess() || FaveDeviceSize.isIPhone6() {
                noEventsViewTopMargin = 96
            } else {
                noEventsViewTopMargin = 120
            }

            suggestionsView.top == view.top + noEventsViewTopMargin
        }

        constrain(hintArrowImageView, view) { hintArrowImageView, view in

            let width = UIScreen.main.bounds.width
            let offset = (width / 8 * 3) - (hintArrowImageViewWidth / 2)

            hintArrowImageView.bottom == view.bottomMargin - 12
            hintArrowImageView.left == view.left + offset
        }

        view.bringSubviewToFront(loadingIndicatorView)
        view.bringSubviewToFront(createButton)
        view.bringSubviewToFront(noEventsView)

        feedTableView.alpha = 0
        feedTableView.isHidden = true
        createButton.alpha = 0
        createButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        noEventsView.alpha = 0
        noEventsView.isHidden = true
        hintArrowImageView.alpha = 0

        isLoading = true

        NotificationCenter.default.addObserver(self, selector: #selector(refreshFeedFromNotificationCenter), name: .shouldRefreshHomeFeed, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if feedViewModel.currentCount == 0 {
            refreshFeed()
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshFeed()
    }

    @objc func refreshFeedFromNotificationCenter() {
        refreshFeed()
    }

    @objc func refreshFeed(completion: @escaping () -> () = {}) {

        if dependencyGraph.authenticator.isLoggedIn() {
            isLoading = feedViewModel.currentCount == 0

            loggedIn = true

            self.feedViewModel.resetContent()

            self.fetchFeed(fromIndex: feedViewModel.currentFromIndex, toIndex: feedViewModel.currentToIndex)

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

    private func fetchFeed(fromIndex: Int, toIndex: Int, completion: @escaping () -> () = {}) {
        dependencyGraph.faveService.getFeed(from: fromIndex, to: toIndex) { response, error in
            DispatchQueue.main.async {
                self.feedViewModel.isInfinateScrollingFetchInProgress = false

                self.refreshControl.endRefreshing()

                self.isLoading = false

                completion()

                guard let newEvents = response else {
                    return
                }

                self.feedViewModel.addNewEvents(events: newEvents)
            }
        }
    }
}

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedViewModel.currentCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FeedEventTableViewCell.self, indexPath: indexPath)

        cell.delegate = self

        let event = feedViewModel.event(at: indexPath.row)
        cell.populate(dependencyGraph: dependencyGraph, event: event)

        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = FaveColors.White

        footerView.addSubview(footerLoadingIndicatorView)

        constrain(footerView, footerLoadingIndicatorView) { footerView, loadingView in
            loadingView.centerX == footerView.centerX
            loadingView.top == footerView.top + 24
            loadingView.bottom == footerView.bottom - 24
        }

        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.zero)

        view.backgroundColor = FaveColors.White

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
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
        showToast(title: "Created \(list.title)")

        let listViewController = ListViewController(dependencyGraph: dependencyGraph, list: list)

        let titleViewLabel = Label(text: "\(list.title)", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        listViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(listViewController, animated: true)
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

extension FeedViewController: ListViewControllerDelegate {
    func didRemoveList(viewController: FaveVC) {
        viewController.navigationController?.popViewController(animated: true)

        refreshFeed()
    }
}

extension FeedViewController: FeedViewModelDelegate {
    func onFetchCompleted(indexPaths: [IndexPath]) {

        for path in indexPaths {
            print("\nPath row: \(path.row)")
        }

        if feedViewModel.currentCount == indexPaths.count {
            feedTableView.reloadData()
        } else {
            feedTableView.beginUpdates()
            feedTableView.insertRows(at: indexPaths, with: .none)
            feedTableView.endUpdates()
        }

        footerLoadingIndicatorView.stopAnimating()

        feedViewModel.isInfinateScrollingFetchInProgress = false
    }

    func didUpdateEvents(events: [FeedEvent]) {

        let hasEvents = !events.isEmpty

        if hasEvents {
            UIView.animate(withDuration: 0.15, animations: {
                self.noEventsView.alpha = 0
                self.hintArrowImageView.alpha = 0
                self.feedTableView.alpha = 1
            }, completion: { _ in
                self.noEventsView.isHidden = hasEvents
            })
        } else {

            self.noEventsView.isHidden = hasEvents

            UIView.animate(withDuration: 0.15, animations: {
                self.noEventsView.alpha = 1
                self.hintArrowImageView.alpha = 1
                self.feedTableView.alpha = 0
            }, completion: { _ in
            })
        }
    }
}

extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if feedTableView.contentOffset.y >= (feedTableView.contentSize.height - feedTableView.frame.size.height) {

            if !feedViewModel.isInfinateScrollingFetchInProgress && !feedViewModel.hasReachedEndOfList {
                feedViewModel.isInfinateScrollingFetchInProgress = true

                self.fetchFeed(fromIndex: feedViewModel.currentFromIndex, toIndex: feedViewModel.currentToIndex)

                if feedViewModel.currentCount != 0 {
                    footerLoadingIndicatorView.startAnimating()
                }
            }
        }
    }
}
