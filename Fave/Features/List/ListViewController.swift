import Foundation

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

    var listsUserFollows: [List] = [] {
        didSet {

            self.list.isUserFollowing = listsUserFollows.contains { list in
                return list.id == self.list.id
            }

            listTableHeaderView.updateHeaderInfo(list: list, listItems: listItems)
        }
    }

    var listOfCurrentFaveIds: [Int] = [] {
        didSet {
            self.listItems = self.listItems.map({ listItem in
                var item = listItem

                item.isFaved = listOfCurrentFaveIds.contains(item.dataId)

                return item
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

        return tableView
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

    private lazy var tabBarMenuButton: UIButton = {
        let button = UIButton.init(type: .custom)

        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(named: "icon-menu"), for: .normal)
        button.adjustsImageWhenHighlighted = false

        return button
    }()

    init(dependencyGraph: DependencyGraphType, list: List) {
        self.list = list

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .profileScreenShown)
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

        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        dependencyGraph.faveService.getList(userId: list.owner.id, listId: self.list.id) { response, error in
            guard let list = response else {
                return
            }

            self.list = list

            self.dependencyGraph.faveService.listsUserFollows(userId: user.id) { response, error in
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

            self.updateFaves(userId: user.id)
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
}

// Create button logic

extension ListViewController {
    @objc func createButtonTapped(sender: UIButton!) {
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // Have to decide whether the user can add an item or suggest an item

//        alertController.addAction(UIAlertAction(title: "Entry", style: .default , handler: { alertAction in
            self.addItemButtonTapped()

//            alertController.dismiss(animated: true, completion: nil)
//        }))

//        alertController.addAction(UIAlertAction(title: "List", style: .default , handler: { alertAction in
//            self.addListButtonTapped()
//
//            alertController.dismiss(animated: true, completion: nil)
//        }))

//        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alertAction in
//            alertController.dismiss(animated: true, completion: nil)
//        }))
//
//        self.present(alertController, animated: true, completion: nil)
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

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph, defaultList: list)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Share this list", style: .default , handler: { alertAction in
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

        alertController.addAction(UIAlertAction(title: "Nice", style: .default, handler: { action in
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

        let item = listItems[indexPath.row]

        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item, list: list)

        let titleViewLabel = Label.init(text: "Entry", font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        itemViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterType == .entries {
            return listItems.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(EntryTableViewCell.self, indexPath: indexPath)

        cell.delegate = self

        let item = listItems[indexPath.row]
        cell.populate(item: item)

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
                self.updateFaves(userId: user.id)
            }) { selectedList in
                self.dependencyGraph.faveService.addFave(userId: user.id, listId: selectedList.id, itemId: item.id) { response, error in

                    self.updateFaves(userId: user.id)


                    guard let _ = response else {
                        return
                    }
                }
            }
        } else {
            dependencyGraph.faveService.removeFave(userId: user.id, itemId: item.dataId) { success, error in

                self.updateFaves(userId: user.id)

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

    func updateFaves(userId: Int) {
        dependencyGraph.faveService.getFaves(userId: userId) { response, error in
            guard let faves = response else {
                return
            }

            self.listOfCurrentFaveIds = faves
        }
    }

    func shareItemButtonTapped(item: Item) {
        print("\nShare Item Button Tapped\n")

        guard let contextualItem = item.contextualItem as? GoogleItemType, let url = NSURL(string: "https://www.fave.com/lists/\(list.id)/item/\(item.id)") else {
            return
        }

        let title = contextualItem.name
        let itemsToShare: [Any] = [title, url]

        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)
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
