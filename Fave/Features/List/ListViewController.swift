import UIKit
import Cartography
import MBProgressHUD

enum ListFilterType {
    case entries
    case recommendations
}

protocol ListViewControllerDelegate {
    func didRemoveList(viewController: FaveVC)
}

extension ListViewControllerDelegate {
    func didRemoveList(viewController: FaveVC) {}
}

class ListViewController: FaveVC {
    var list: List

    var delegate: ListViewControllerDelegate?

    var filterType: ListFilterType = .entries {
        didSet {
            if filterType != oldValue {
                listTableView.reloadData()
            }
        }
    }

    var listItems: [Item] = [] {
        didSet {
            listTableHeaderView.updateHeaderInfo(list: list, listItems: listItems)

            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }

    var entries: [Item] = []
    var recommendations: [Item] = []

    var listsUserFollows: [List] = [] {
        didSet {

            self.list.isUserFollowing = listsUserFollows.contains { list in
                return list.id == self.list.id
            }

            listTableHeaderView.updateHeaderInfo(list: list, listItems: listItems)

            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }

    var listOfCurrentItems: [Item] = [] {
        didSet {
            self.listItems = self.listItems.map({ listItem in
                var item = listItem

                let allListDataIds = listOfCurrentItems.map({ item in item.dataId })

                item.isSaved = allListDataIds.contains(item.dataId)

                return item
            })

            self.entries = self.listItems.filter({ item in
                return !item.isRecommendation
            })
            .sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })

            self.recommendations = self.listItems.filter({ item in
                return item.isRecommendation
            })
            .sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })

            listTableView.reloadData()
        }
    }

    var followersOfList: [User] = [] {
        didSet {
            print("\(followersOfList)")
        }
    }

    private lazy var listTableHeaderView: ListTableHeaderView = {
        let view = ListTableHeaderView(dependencyGraph: self.dependencyGraph, list: self.list)

        view.delegate = self

        return view
    }()

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                progressHud.show(animated: true)
            } else {
                progressHud.hide(animated: true)
            }
        }
    }

    private lazy var progressHud: MBProgressHUD = {
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

    private lazy var loadingIndicator: IndeterminateCircularIndicatorView = {
        var indicator = IndeterminateCircularIndicatorView()

        return indicator
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

    private lazy var listTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = self.listTableHeaderView
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(EntryTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)

        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = FaveColors.White

        return tableView
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 56 / 2
        button.tintColor = FaveColors.White

        if let currentUser = dependencyGraph.storage.getUser(), currentUser.id == list.owner.id {
            button.setImage(UIImage(named: "icon-add"), for: .normal)
            button.addTarget(self, action: #selector(addItemButtonTapped), for: .touchUpInside)
        } else {

            let icon = UIImage(named: "icon-comment")?.withRenderingMode(.alwaysTemplate)
            button.tintColor = FaveColors.White

            button.setImage(icon, for: .normal)
            button.addTarget(self, action: #selector(recommendItemButtonTapped), for: .touchUpInside)
        }

        return button
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

    init(dependencyGraph: DependencyGraphType, list: List) {
        self.list = list

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .listScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButton)
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.tabBarMenuButton)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        view.addSubview(listTableView)
        view.addSubview(loadingIndicator)
        view.addSubview(createButton)
        view.addSubview(progressHud)

        constrainToSuperview(listTableView, exceptEdges: [.top, .bottom])

        constrain(listTableView, view) { tableView, view in
            tableView.top == view.topMargin
            tableView.bottom == view.bottomMargin
        }

        constrain(createButton, view) { button, view in
            button.right == view.right - 12
            button.bottom == view.bottomMargin - 12
            button.width == 56
            button.height == 56
        }

        constrain(progressHud, view) { hud, view in
            hud.centerX == view.centerX
            hud.centerY == view.centerY
        }

        constrain(loadingIndicator, view) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }

        // TOOD: Open up recommendations to everyone to see
//        if let currentUser = dependencyGraph.storage.getUser() {
//            if list.title.lowercased() == "recommendations" && list.owner.id == currentUser.id {
            if list.title.lowercased() == "recommendations" {
                filterType = .recommendations
            }
//        }

        view.addSubview(loadingIndicator)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = listTableView.tableHeaderView {
            tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

            let constraint = NSLayoutConstraint(item: tableHeaderView,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: listTableView.frame.width)

            tableHeaderView.addConstraint(constraint)

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if listItems.isEmpty {
            loadingIndicator.startAnimating()
        }

        refreshData() {
            self.loadingIndicator.stopAnimating()
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(0.0) {
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        dependencyGraph.faveService.getList(listId: self.list.id) { response, error in
            guard let list = response else {
                return
            }

            self.list = list

            if let user = self.dependencyGraph.storage.getUser() {
                self.dependencyGraph.faveService.listsUserFollows(userId: user.id) { response, error in
                    guard let listsUserFollows = response else {
                        return
                    }

                    self.listsUserFollows = listsUserFollows
                }
            }
        }

        dependencyGraph.faveService.getListItems(userId: list.owner.id, listId: self.list.id) { response, error in
            guard let items = response else {
                completion()

                return
            }

            self.listItems = items

            completion()

            self.updateSaved(userId: self.list.owner.id)
        }

        dependencyGraph.faveService.followersOfList(listId: list.id) { response, error in
            guard let followersOfList = response else {
                return
            }

            self.followersOfList = followersOfList
        }
    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
    }

    private func showSuccess(title: String) {
        showToast(title: title)
    }

    private func handleItemTapped(item: Item, list: List?) {
        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item, list: list)

        let titleViewLabel = Label(text: "Place", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        itemViewController.delegate = self

        navigationController?.pushViewController(itemViewController, animated: true)
    }

    func deleteListButtonTapped(list: List) {
        print("\nDelete List Button Tapped\n")

        // Show confirmation
        // Put view in loading state
        // Make a call to delete the item
        // Upon success, call callback to refresh list
        // pop view

        let alertController = UIAlertController(title: "Remove list", message: "Are you sure you want to remove this list?", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:
                alertController.dismiss(animated: true, completion: nil)
            }}
        ))

        alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:

                self.removeList(list: list)

            }}
        ))

        self.present(alertController, animated: true, completion: nil)
    }

    private func removeList(list: List) {
        isLoading = true

        dependencyGraph.faveService.removeList(listId: list.id) { id, error in
            self.isLoading = false

            guard let _ = id else {
                return
            }

            self.delegate?.didRemoveList(viewController: self)
        }
    }
}

// Create button logic

extension ListViewController {
    func addListButtonTapped() {
        print("\n\nAdd List Button Tapped\n\n")

        let createListViewController = CreateListViewController(dependencyGraph: self.dependencyGraph)
        let createListNavigationViewController = UINavigationController(rootViewController: createListViewController)

        createListViewController.delegate = self

        present(createListNavigationViewController, animated: true, completion: nil)
    }

    @objc func addItemButtonTapped(sender: UIButton!) {
        print("\n\nAdd Item Button Tapped\n\n")

        guard self.dependencyGraph.authenticator.isLoggedIn() else {
            login()

            return
        }

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph, defaultList: list, creationType: .addition)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }

    @objc func recommendItemButtonTapped(sender: UIButton!) {
        print("\n\nAdd Item Button Tapped\n\n")

        sender.performImpact(style: .light)

        guard self.dependencyGraph.authenticator.isLoggedIn() else {
            login()

            return
        }

        let createRecommendationViewController = CreateRecommendationViewController(dependencyGraph: self.dependencyGraph, recipient: list.owner, list: list)
        let createRecommendationNavigationViewController = UINavigationController(rootViewController: createRecommendationViewController)

        createRecommendationViewController.delegate = self

        createRecommendationViewController.modalPresentationStyle = .overFullScreen

        present(createRecommendationNavigationViewController, animated: true, completion: nil)
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let user = dependencyGraph.storage.getUser(), user.id == list.owner.id {
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive , handler: { alertAction in
                self.deleteListButtonTapped(list: self.list)

                alertController.dismiss(animated: true, completion: nil)
            }))

            alertController.addAction(UIAlertAction(title: "Edit", style: .default , handler: { alertAction in
                self.editListButtonTapped(list: self.list)

                alertController.dismiss(animated: true, completion: nil)
            }))
        }

        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alertAction in
            alertController.dismiss(animated: true, completion: nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    func shareListButtonTapped() {
        print("\n Share list button tapped\n")

        guard let url = NSURL(string: "https://www.fave.com/lists/\(list.id)") else {
            return
        }

        let title = "Check out my list on Fave: \(list.title)"
        let itemsToShare: [Any] = [title, url]

        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)
    }

    func editListButtonTapped(list: List) {

        let updateListViewController = UpdateListViewController(dependencyGraph: dependencyGraph, list: list)

        let updateListNavigationViewController = UINavigationController(rootViewController: updateListViewController)

        updateListViewController.delegate = self

        present(updateListNavigationViewController, animated: true, completion: nil)
    }
}

extension ListViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {
        showToast(title: "Created \(list.title)")

        refreshData()
    }
}

extension ListViewController: CreateItemViewControllerDelegate {
    func didCreateItem(item: Item) {
        showToast(title: "Created \(item.contextualItem.name)")

        refreshData()
    }
}

extension ListViewController: UpdateListViewControllerDelegate {
    func didUpdateList(list: List) {
        self.list = list

        refreshData()
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listTableView.deselectRow(at: indexPath, animated: true)

        let item: Item

        switch filterType {
        case .entries:
            item = entries[indexPath.row]
        case .recommendations:
            item = recommendations[indexPath.row]
        }

        handleItemTapped(item: item, list: list)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.alpha = 0
//
//        let minTime = Double(min((0.01 * Double(indexPath.row)), 0.1))
//
//        UIView.animate(withDuration: 0.2, delay: minTime, animations: {
//                cell.alpha = 1
//        })
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch filterType {
        case .entries:
            return entries.count
        case .recommendations:
            return recommendations.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(EntryTableViewCell.self, indexPath: indexPath)

        cell.delegate = self

        let item: Item

        switch filterType {
        case .entries:
            item = entries[indexPath.row]
        case .recommendations:
            item = recommendations[indexPath.row]
        }

        var mySavedItem: Item? = nil
        if item.isSaved ?? false {
            let combinedSavedItems = listOfCurrentItems.filter({$0.dataId == item.dataId})

            if combinedSavedItems.count > 1 {
                mySavedItem = combinedSavedItems.filter({ !$0.isRecommendation }).first
            } else {
                mySavedItem = combinedSavedItems.first
            }
        }

        cell.populate(dependencyGraph: dependencyGraph, item: item, list: list, mySavedItem: mySavedItem)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension ListViewController: ListTableHeaderViewDelegate {

    func showLogin() {
        login()
    }

    func entriesButtonTapped() {
        print("\nLists Button Tapped\n")

        filterType = .entries
    }

    func suggestionsButtonTapped() {
        print("\nRecommentaion Button Tapped\n")
        filterType = .recommendations
    }

    func didTapFollowedByLabel(list: List) {
        let followedByViewController = FollowedByViewController(dependencyGraph: dependencyGraph, list: list)

        let titleViewLabel = Label(text: "Followed by", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        followedByViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(followedByViewController, animated: true)
    }
}

extension ListViewController: EntryTableViewCellDelegate {

    func dismissButtonTapped(item: Item) {
        // delete recommendation
        // reload entries

        dependencyGraph.faveService.removeListItem(itemId: item.id) { itemId, error in
            guard let itemId = itemId else {
                return
            }

            print("\(itemId)")

            self.refreshData()
        }
    }

    func addToListButtonTapped(item: Item, autoMerge: Bool = false) {

        let selectListViewController = SelectListViewController(dependencyGraph: dependencyGraph)
        let selectListNavigationController = UINavigationController(rootViewController: selectListViewController)

        // If autoMerge, skip this and add straight to list
        guard autoMerge else {
            selectListViewController.didSelectList = { list in

                self.isLoading = true

                self.dependencyGraph.faveService.updateListItem(itemId: item.id, listId: list.id, type: item.type, note: item.note, isRecommendation: item.isRecommendation) { item, error in

                    self.isLoading = false

                    guard let _ = item else {
                        return
                    }

                    self.refreshData()
                }
            }

            present(selectListNavigationController, animated: true)

            return
        }

        isLoading = true
        self.dependencyGraph.faveService.updateListItem(itemId: item.id, listId: item.listId, type: item.type, note: item.note, isRecommendation: false) { item, error in

            self.isLoading = false

            guard let _ = item else {
                return
            }

            self.refreshData()
        }

    }

    func photoTapped(item: Item, list: List?) {
        handleItemTapped(item: item, list: list)
    }

    func faveItemButtonTapped(item: Item, from: Bool, to: Bool) {

        guard let user = dependencyGraph.storage.getUser() else {

            login()

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
            let removeFaveAlertController = UIAlertController(title: "Remove \(item.contextualItem.name)", message: "Are you sure you want to remove \(item.contextualItem.name) from your list?", preferredStyle: .alert)

            removeFaveAlertController.addAction(UIAlertAction(title: "Nevermind", style: .default, handler: { action in
                switch action.style {
                case .default, .cancel, .destructive:
                    removeFaveAlertController.dismiss(animated: true, completion: nil)
                    self.updateSaved(userId: user.id)
                }}))

            removeFaveAlertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { action in
                switch action.style {
                case .default, .cancel, .destructive:
                    removeFaveAlertController.dismiss(animated: true, completion: nil)

                    self.dependencyGraph.faveService.removeFave(userId: user.id, itemId: item.id) { success, error in

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
            }}))

            present(removeFaveAlertController, animated: true, completion: nil)
        }
    }

    func didTapOwnerView(owner: User) {
        print("profile selected for \(owner.id)")

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: owner)

        let titleViewLabel = Label(text: owner.handle, font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(profileViewController, animated: true)
    }

    func updateSaved(userId: Int) {
        dependencyGraph.faveService.myItems() { response, error in

            guard let items = response else {
                self.listOfCurrentItems = []

                return
            }

            self.listOfCurrentItems = items
        }
    }

    func shareItemButtonTapped(item: Item) {
        print("\nShare Item Button Tapped\n")

        guard let user = dependencyGraph.storage.getUser() else {

            login()

            return
        }

        guard let contextualItem = item.contextualItem as? GoogleItemType, let url = NSURL(string: "https://www.fave.com/lists/\(list.id)/item/\(item.id)") else {
            return
        }

        // Show the share sheet
        // Pass handlers for each of the actions

        let addToListHandler: (() -> ()) = {
            self.dismiss(animated: true, completion: {
                let myListsViewController = MyListsViewController(dependencyGraph: self.dependencyGraph, item: item, canceledSelection: {
                    self.dismiss(animated: true, completion: nil)
                }, didSelectList: { selectedList in
                    self.dependencyGraph.faveService.addFave(userId: user.id, listId: selectedList.id, itemId: item.id, note: "") { response, error in

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


        let sendRecommendationsHandler: ((_ selectedUsers: [User], _ item: Item, _ completion: (() -> ())?) -> ())? = { selectedUsers, item, completion in
            guard let currentUser = self.dependencyGraph.storage.getUser() else {
                completion?()

                return
            }

            var completedRequests = 0

            self.isLoading = true

            for selectedUser in selectedUsers {

                self.dependencyGraph.faveService.getLists(userId: selectedUser.id) { lists, error in
                    guard let lists = lists else {
                        completion?()

                        return
                    }

                    guard let recommendationsList = lists.filter({ list in
                        return list.title.lowercased() == "recommendations"
                    }).first else {
                        return
                    }

                    guard let googleItem = item.contextualItem as? GoogleItemType else {
                        completion?()

                        return
                    }

                    self.dependencyGraph.faveService.createListItem(userId: currentUser.id, listId: recommendationsList.id, type: item.type, placeId: googleItem.placeId, note: "") { item, error in

                        self.dependencyGraph.analytics.logEvent(dependencyGraph: self.dependencyGraph, title: AnalyticsEvents.recommendationSent.rawValue)

                        completedRequests += 1

                        guard let _ = item else {
                            let alertController = UIAlertController(title: "Error", message: "Oops, something went wrong. Try creating an entry again.", preferredStyle: .alert)

                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style {
                                case .default, .cancel, .destructive:
                                    alertController.dismiss(animated: true, completion: nil)
                                }}))

                            self.present(alertController, animated: true, completion: nil)


                            completion?()
                            return
                        }

                        if completedRequests == selectedUsers.count {
                            self.isLoading = false

                            completion?()

                            self.dismiss(animated: true, completion: {
                                // show sent recommendation toast

                                self.showSuccess(title: "Recommendation sent!")
                            })
                        }
                    }
                }
            }
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

    func selectListToFaveTo(item: Item, canceledSelection: @escaping () -> (), didSelectList: @escaping (_ list: List) -> ()) {

        let myListsViewController = MyListsViewController(dependencyGraph: dependencyGraph, item: item, canceledSelection: canceledSelection, didSelectList: didSelectList)
        myListsViewController.modalPresentationStyle = .overCurrentContext

        present(myListsViewController, animated: false, completion: nil)
    }
}

extension ListViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ListViewController: ShareItemViewControllerDelegate {}

extension ListViewController: CreateRecommendationViewControllerDelegate {
    func didSendRecommendations(selectedUsers: [User]) {
        let titleString = selectedUsers.count == 1 ? "Recommendation sent!" : "Recommendations sent!"

        self.showToast(title: titleString)
    }
}

extension ListViewController: ItemViewControllerDelegate {
    func didRemoveItem(viewController: FaveVC) {
        viewController.navigationController?.popViewController(animated: true)
        
        refreshData()
    }
}
