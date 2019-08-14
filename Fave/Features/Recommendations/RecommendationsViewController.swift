import Foundation
import Cartography
import MBProgressHUD

//enum RecommendationState {
//    case loading
//    case presenting
//}

class RecommendationsViewController: FaveVC {

    var recommendations: [Item] = [] {
        didSet {
            // reload table view

            let noRecommendationsViewAlpha: CGFloat = recommendations.isEmpty ? 1.0 : 0

            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.noRecommendationsView.alpha = noRecommendationsViewAlpha
            }, completion: nil)


            self.recommendationsTableView.reloadData()
        }
    }

    private var items: [Item] = [] {
        didSet {
            // $0.listTitle.lowercased() == "recommendations"
            let recommendations = items.filter({ $0.isRecommendation })
            let sortedRecommendations = recommendations.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })

            self.recommendations = sortedRecommendations
        }
    }

    private var listOfCurrentItems: [Item] = [] {
        didSet {
            self.items = self.listOfCurrentItems.map({ listItem in
                var item = listItem

                let allListDataIds = listOfCurrentItems.map({ item in item.dataId })

                item.isSaved = allListDataIds.contains(item.dataId)

                return item
            })
        }
    }

    private var isLoadingInitialState: Bool = false {
        didSet {
            if isLoadingInitialState {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
    }

    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                progressHUD.show(animated: true)
            } else {
                progressHUD.hide(animated: true)
            }
        }
    }

    private lazy var progressHUD: MBProgressHUD = {
        let hud = MBProgressHUD(frame: .zero)

        hud.animationType = .fade
        hud.contentColor = FaveColors.Accent

        return hud
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        return refreshControl
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()

        indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.hidesWhenStopped = true

        return indicator
    }()

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

    private lazy var noRecommendationsView: UIView = {
        let view = UIView(frame: .zero)

        let titleLabel = Label(text: "No recommendations",
                          font: FaveFont(style: .h4, weight: .bold) ,
                          textColor: FaveColors.Black90,
                          textAlignment: .center,
                          numberOfLines: 1)

        let subtitleLabel = Label(text: "You don't have any recommendations at the moment. We'll make sure you see them here when you do.",
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

    private lazy var recommendationsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(EntryTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .myListsScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        let titleViewLabel = Label(text: "Recommendations", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.addSubview(recommendationsTableView)
        view.addSubview(noRecommendationsView)
        view.addSubview(createButton)
        view.addSubview(progressHUD)
        view.addSubview(loadingIndicator)

        constrainToSuperview(recommendationsTableView)

        constrain(noRecommendationsView, view) { noRecommendationsView, view in
            noRecommendationsView.left == view.left
            noRecommendationsView.right == view.right
            noRecommendationsView.centerY == view.centerY
        }

        constrain(createButton, view) { button, view in
            button.right == view.right - 12
            button.bottom == view.bottomMargin - 12
            button.width == 56
            button.height == 56
        }

        constrain(progressHUD, view) { progressHUD, view in
            progressHUD.centerX == view.centerX
            progressHUD.centerY == view.centerY
        }

        constrain(loadingIndicator, view) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }

        view.bringSubviewToFront(createButton)
        view.bringSubviewToFront(loadingIndicator)
        view.bringSubviewToFront(progressHUD)

        noRecommendationsView.alpha = 0
        isLoadingInitialState = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshData()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            self.refreshControl.endRefreshing()
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        dependencyGraph.faveService.myItems() { response, error in
            self.isLoadingInitialState = false

            completion()

            guard let items = response else {
                return
            }

            self.listOfCurrentItems = items
        }
    }

    private func showSuccess(title: String) {
        showToast(title: title)
    }

    private func selectListToFaveTo(item: Item, canceledSelection: @escaping () -> (), didSelectList: @escaping (_ list: List) -> ()) {
        let myListsViewController = MyListsViewController(dependencyGraph: dependencyGraph, item: item, canceledSelection: canceledSelection, didSelectList: didSelectList)
        myListsViewController.modalPresentationStyle = .overCurrentContext

        present(myListsViewController, animated: false, completion: nil)
    }
}

extension RecommendationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recommendationsTableView.deselectRow(at: indexPath, animated: true)

        let item = recommendations[indexPath.row]

        let itemViewController = ItemViewController(dependencyGraph: dependencyGraph, item: item)

        let titleViewLabel = Label(text: "Place", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension RecommendationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(EntryTableViewCell.self, indexPath: indexPath)

        cell.delegate = self

        let item = recommendations[indexPath.row]

        var mySavedItem: Item? = nil
        if item.isSaved ?? false {
            let combinedSavedItems = listOfCurrentItems.filter({$0.dataId == item.dataId}).filter({ !$0.isRecommendation })

            mySavedItem = combinedSavedItems.first
        }

        cell.populate(dependencyGraph: dependencyGraph,
                      item: item,
                      list: nil,
                      mySavedItem: mySavedItem)

        return cell
    }

    func updateSaved(userId: Int) {
        dependencyGraph.faveService.myItems() { response, error in
            guard let items = response else {
                return
            }

            self.listOfCurrentItems = items
        }
    }

    private func handleItemTapped(item: Item, list: List?) {
        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item, list: list)

        let titleViewLabel = Label(text: "Place", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension RecommendationsViewController: EntryTableViewCellDelegate {
    func faveItemButtonTapped(item: Item, from: Bool, to: Bool) {
        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        let weShouldFave = !from

        if weShouldFave {
            // fave the item
            // update faves endpoint
            // reload table

            selectListToFaveTo(item: item, canceledSelection: {
                self.updateSaved(userId: user.id)
            }) { selectedList in
                self.dependencyGraph.faveService.addFave(userId: user.id, listId: selectedList.id, itemId: item.id, note: "") { response, error in

                    self.dependencyGraph.analytics.logEvent(dependencyGraph: self.dependencyGraph, title: AnalyticsEvents.itemFaved.rawValue)

                    self.updateSaved(userId: user.id)


                    guard let _ = response else {
                        return
                    }
                }
            }
        } else {
            dependencyGraph.faveService.removeFave(userId: user.id, itemId: item.dataId) { success, error in

                self.updateSaved(userId: user.id)

                if let _ = error {
                    // TODO: Handle error

                    return
                }

                if success {
                    // Success placeholder
                } else {
                    let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Try unfaving again.", preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style {
                        case .default, .cancel, .destructive:
                            alertController.dismiss(animated: true, completion: nil)
                        }}))

                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func shareItemButtonTapped(item: Item) {
        print("\nShare Item Button Tapped\n")

        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        guard let contextualItem = item.contextualItem as? GoogleItemType, let url = NSURL(string: "https://www.fave.com/lists/\(item.listId)/item/\(item.id)") else {
            return
        }

        // Show the share sheet
        // Pass handlers for each of the actions

        let addToListHandler: (() -> ()) = {
            self.dismiss(animated: true, completion: {
                let myListsViewController = MyListsViewController(dependencyGraph: self.dependencyGraph, item: item, canceledSelection: {
                    self.dismiss(animated: true, completion: nil)
                }, didSelectList: { selectedList in
                    self.dependencyGraph.faveService.addFave(userId: user.id, listId: selectedList.id, itemId: item.id, note: item.note) { response, error in

                        self.dependencyGraph.analytics.logEvent(dependencyGraph: self.dependencyGraph, title: AnalyticsEvents.itemFaved.rawValue)

                        self.updateSaved(userId: user.id)


                        guard let _ = response else {
                            return
                        }

                        self.dismiss(animated: true, completion: nil)
                    }
                })

                myListsViewController.modalPresentationStyle = .overCurrentContext

                self.present(myListsViewController, animated: false, completion: nil)
            })
        }

        let copyLinkActionHandler: (() -> ()) = {
            self.dismiss(animated: true, completion: {
                print("\n\n Show copied link toast \n\n")

                self.showSuccess(title: "Copied link to clipboard")
            })
        }

        let shareActionHandler: (() -> ()) = {
            self.dismiss(animated: true, completion: {
                let title = contextualItem.name
                let itemsToShare: [Any] = [title, url]

                let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view

                self.present(activityViewController, animated: true, completion: nil)
            })
        }

        let sendRecommendationsHandler: ((_ selectedUsers: [User], _ item: Item) -> ()) = { selectedUser, item in
            // TODO: Patrick

            // Not needed for the recommendations view controller, but should refactor at some point
        }

        let shareViewController = ShareItemViewController(dependencyGraph: dependencyGraph, user: user, item: item)

        shareViewController.delegate = self

        shareViewController.shareActionHandler = shareActionHandler
        shareViewController.copyLinkActionHandler = copyLinkActionHandler
        shareViewController.addToListHandler = addToListHandler
        shareViewController.sendRecommendationsHandler = sendRecommendationsHandler

        let navigationController = UINavigationController(rootViewController: shareViewController)

        present(navigationController, animated: true, completion: nil)
    }

    func googlePhotoTapped(item: Item, list: List?) {
        handleItemTapped(item: item, list: list)
    }

    func dismissButtonTapped(item: Item) {

        isLoading = true

        dependencyGraph.faveService.removeListItem(itemId: item.id) { itemId, error in

            self.isLoading = false

            guard let itemId = itemId else {
                return
            }

            print("\(itemId)")

            self.refreshData()
        }
    }

    func addToListButtonTapped(item: Item) {
        // prompt lists
        // upon selection, post update to isRecommendation = false

        let selectListViewController = SelectListViewController(dependencyGraph: dependencyGraph)
        let selectListNavigationController = UINavigationController(rootViewController: selectListViewController)

        selectListViewController.didSelectList = { (list: List) in
            self.dependencyGraph.faveService.updateListItem(itemId: item.id, listId: list.id, type: item.type, note: item.note, isRecommendation: item.isRecommendation) { item, error in
                guard let _ = item else {
                    return
                }

                self.refreshData()
            }
        }

        present(selectListNavigationController, animated: true)
    }

    func didTapOwnerView(owner: User) {
        print("profile selected for \(owner.id)")

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: owner)

        let titleViewLabel = Label(text: owner.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }
}

extension RecommendationsViewController {
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

extension RecommendationsViewController: CreateRecommendationViewControllerDelegate {
    func didSendRecommendations(selectedUsers: [User]) {
        let titleString = selectedUsers.count == 1 ? "Recommendation sent!" : "Recommendations sent!"

        self.showToast(title: titleString)
    }
}

extension RecommendationsViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {

    }
}

extension RecommendationsViewController: CreateItemViewControllerDelegate {
    func didCreateItem(item: Item) {
        self.showToast(title: "Created \(item.contextualItem.name)")
    }
}

extension RecommendationsViewController: ShareItemViewControllerDelegate {}
