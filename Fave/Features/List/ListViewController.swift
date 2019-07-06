import UIKit
import Cartography
import MBProgressHUD

enum ListFilterType {
    case entries
    case recommendations
}

class ListViewController: FaveVC {
    var list: List

    var filterType: ListFilterType = .entries {
        didSet {
            listTableView.reloadData()
        }
    }

    var listItems: [Item] = []

    var entries: [Item] = []
    var recommendations: [Item] = []

    var listsUserFollows: [List] = [] {
        didSet {

            self.list.isUserFollowing = listsUserFollows.contains { list in
                return list.id == self.list.id
            }

            listTableHeaderView.updateHeaderInfo(list: list, listItems: listItems)
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

            self.recommendations = self.listItems.filter({ item in
                return item.isRecommendation
            })

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

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        return refreshControl
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()

        indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.style = UIActivityIndicatorView.Style.gray

        return indicator
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

    private lazy var listTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = self.listTableHeaderView
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(EntryTableViewCell.self)

        tableView.addSubview(self.refreshControl)

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
        let button = UIButton.init(type: .custom)

        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(named: "icon-menu"), for: .normal)
        button.adjustsImageWhenHighlighted = false

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
//        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.tabBarMenuButton)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        view.addSubview(listTableView)
        view.addSubview(createButton)

        constrainToSuperview(listTableView, exceptEdges: [.top])

        constrain(listTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }

        constrain(createButton, view) { button, view in
            button.right == view.right - 12
            button.bottom == view.bottomMargin - 12
            button.width == 56
            button.height == 56
        }

        if let currentUser = dependencyGraph.storage.getUser() {
            if list.title.lowercased() == "recommendations" && list.owner.id == currentUser.id {
                filterType = .recommendations
            }
        }

        refreshData()
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

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshData()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(1.0) {
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {

        dependencyGraph.faveService.getList(userId: list.owner.id, listId: self.list.id) { response, error in
            guard let list = response else {
                return
            }

            self.list = list

            self.dependencyGraph.faveService.listsUserFollows(userId: list.owner.id) { response, error in
                guard let listsUserFollows = response else {
                    return
                }

                self.listsUserFollows = listsUserFollows
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

    private func handleItemTapped(item: Item) {
        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item, list: list)

        let titleViewLabel = Label.init(text: "Place", font: FaveFont.init(style: .h5, weight: .bold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

// Create button logic

extension ListViewController {
    func addListButtonTapped() {
        print("\n\nAdd List Button Tapped\n\n")

        let createListViewController = CreateListViewController.init(dependencyGraph: self.dependencyGraph)
        let createListNavigationViewController = UINavigationController(rootViewController: createListViewController)

        createListViewController.delegate = self

        present(createListNavigationViewController, animated: true, completion: nil)
    }

    @objc func addItemButtonTapped(sender: UIButton!) {
        print("\n\nAdd Item Button Tapped\n\n")

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph, defaultList: list, creationType: .addition)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }

    @objc func recommendItemButtonTapped(sender: UIButton!) {
        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph, defaultList: list, creationType: .recommendation)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Share list", style: .default , handler: { alertAction in
            self.shareListButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        if let user = dependencyGraph.storage.getUser(), user.id == list.owner.id {
            alertController.addAction(UIAlertAction(title: "Edit list", style: .default , handler: { alertAction in
                self.editListButtonTapped()

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

    func editListButtonTapped() {
        print("\n Edit list button tapped\n")

        let alertController = UIAlertController(title: "Not yet implemented", message: "Coming soon!", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cool", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:
                alertController.dismiss(animated: true, completion: nil)
            }}))

        self.present(alertController, animated: true, completion: nil)
    }
}

extension ListViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {
        refreshData()
    }
}

extension ListViewController: CreateItemViewControllerDelegate {
    func didCreateItem() {
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

        handleItemTapped(item: item)
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
            mySavedItem = listOfCurrentItems.filter({$0.dataId == item.dataId}).first
        }

        cell.populate(dependencyGraph: dependencyGraph, item: item, currentUser: dependencyGraph.storage.getUser(), list: nil, mySavedItem: mySavedItem)

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

    func didUpdateRelationship(to relationship: FaveRelationshipType, forList list: List) {

        if relationship == .notFollowing {
            // make call to follow list

            dependencyGraph.faveService.unfollowList(listId: list.id) { success, error in
                if success {
                    self.refreshData()
                } else {
                    // throw error
                }
            }
        } else {
            // make call to unfollow list

            dependencyGraph.faveService.followList(listId: list.id) { success, error in
                if success {
                    self.refreshData()
                } else {
                    // throw error
                }
            }
        }
    }
}

extension ListViewController: EntryTableViewCellDelegate {

    func dismissButtonTapped(item: Item) {
        // delete recommendation
        // reload entries

        dependencyGraph.faveService.deleteListItem(itemId: item.id) { itemId, error in
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

        selectListViewController.delegate = self

        present(selectListNavigationController, animated: true)
    }

    func googlePhotoTapped(item: Item) {
        handleItemTapped(item: item)
    }

    func faveItemButtonTapped(item: Item, from: Bool, to: Bool) {
        print("\nFave Item Button Tapped\n")

        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        let weShouldFave = !from

        if weShouldFave {
            // fave the item
            // update faves endpoint
            // reload table

            selectListToFaveTo(canceledSelection: {
                self.updateSaved(userId: user.id)
            }) { selectedList in
                self.dependencyGraph.faveService.addFave(userId: user.id, listId: selectedList.id, itemId: item.id, note: "") { response, error in

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

    func updateSaved(userId: Int) {
        dependencyGraph.faveService.myItems() { response, error in
            guard let items = response else {
                return
            }

            self.listOfCurrentItems = items
        }
    }

    func shareItemButtonTapped(item: Item) {
        print("\nShare Item Button Tapped\n")

        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        guard let contextualItem = item.contextualItem as? GoogleItemType, let url = NSURL(string: "https://www.fave.com/lists/\(list.id)/item/\(item.id)") else {
            return
        }

        // Show the share sheet
        // Pass handlers for each of the actions

        let addToListHandler: (() -> ()) = {
            self.dismiss(animated: true, completion: {
                let myListsViewController = MyListsViewController(dependencyGraph: self.dependencyGraph, canceledSelection: {
                    self.dismiss(animated: true, completion: nil)
                }, didSelectList: { selectedList in
                    self.dependencyGraph.faveService.addFave(userId: user.id, listId: selectedList.id, itemId: item.id, note: "") { response, error in

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

        let sendRecommendationHandler: ((_ selectedUser: User, _ item: Item) -> ()) = { selectedUser, item in
            guard let currentUser = self.dependencyGraph.storage.getUser() else {
                return
            }

            self.dependencyGraph.faveService.getLists(userId: selectedUser.id) { lists, error in
                guard let lists = lists else {
                    return
                }

                guard let recommendationsList = lists.filter({ list in
                    return list.title.lowercased() == "recommendations"
                }).first else {
                    return
                }

                guard let googleItem = item.contextualItem as? GoogleItemType else {
                    return
                }

                self.dependencyGraph.faveService.createListItem(userId: currentUser.id, listId: recommendationsList.id, type: item.type, placeId: googleItem.placeId, note: "") { item, error in

                    guard let _ = item else {
                        let alertController = UIAlertController(title: "Error", message: "Oops, something went wrong. Try creating an entry again.", preferredStyle: .alert)

                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            switch action.style {
                            case .default, .cancel, .destructive:
                                alertController.dismiss(animated: true, completion: nil)
                            }}))

                        self.present(alertController, animated: true, completion: nil)

                        return
                    }

                    self.dismiss(animated: true, completion: {
                        // show sent recommendation toast

                        print("\n\n Show recommendation sent toast \n\n")

                        self.showSuccess(title: "Recommendation sent!")
                    })
                }
            }
        }

        let shareViewController = ShareItemViewController(dependencyGraph: dependencyGraph, user: user, item: item)

        shareViewController.delegate = self

        shareViewController.shareActionHandler = shareActionHandler
        shareViewController.copyLinkActionHandler = copyLinkActionHandler
        shareViewController.addToListHandler = addToListHandler
        shareViewController.sendRecommendationHandler = sendRecommendationHandler

        let navigationController = UINavigationController.init(rootViewController: shareViewController)

        present(navigationController, animated: true, completion: nil)

    }

    func selectListToFaveTo(canceledSelection: @escaping () -> (), didSelectList: @escaping (_ list: List) -> ()) {

        let myListsViewController = MyListsViewController(dependencyGraph: dependencyGraph, canceledSelection: canceledSelection, didSelectList: didSelectList)
        myListsViewController.modalPresentationStyle = .overCurrentContext

        present(myListsViewController, animated: false, completion: nil)
    }
}

extension ListViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ListViewController: ShareItemViewControllerDelegate {

}

extension ListViewController: SelectListViewControllerDelegate {
    func didSelectList(list: List) {

        dependencyGraph.faveService.updateListItem(listId: list.id, isRecommendation: false) { item, error in
            guard let _ = item else {
                return
            }

            self.refreshData()
        }
    }
}
