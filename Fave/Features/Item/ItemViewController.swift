import UIKit
import Cartography
import MBProgressHUD

enum ItemSectionType: Int {
    case info = 0
    case photos = 1
    case directions = 2
    case suggestions = 3
}

protocol ItemViewControllerDelegate {
    func didRemoveItem(viewController: FaveVC)
}

extension ItemViewControllerDelegate {
    func didRemoveItem(viewController: FaveVC) {}
}

class ItemViewController: FaveVC {

    var delegate: ItemViewControllerDelegate?

    var item: Item {
        didSet {
            itemTableHeaderView.updateContent(item: item)
        }
    }

    var list: List {
        didSet {

        }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                progressHUD.show(animated: true)
            } else {
                progressHUD.hide(animated: true, afterDelay: 0.3)
            }
        }
    }

    var listOfCurrentItems: [Item] = [] {
        didSet {
            let allListDataIds = listOfCurrentItems
                                    .filter({ !$0.isRecommendation })
                                    .map({ item in item.dataId })
            

            item.isSaved = allListDataIds.contains(item.dataId)

            let mySavedItem = listOfCurrentItems.first { currentItem in
                return currentItem.dataId == item.dataId
            }

            itemTableHeaderView.updateHeader(item: item, list: list, user: self.dependencyGraph.storage.getUser(), mySavedItem: mySavedItem)
            view.setNeedsLayout()
            itemTableView.reloadData()
        }
    }

    private lazy var itemTableHeaderView: ItemTableHeaderView = {
        let view = ItemTableHeaderView(item: item, list: list)

        view.delegate = self

        return view
    }()

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

        return indicator
    }()

    private lazy var leftBarButton: UIButton = {
        let image = UIImage.init(named: "icon-nav-chevron-left")
        let imageView = UIImageView(image: image)

        let button = UIButton.init(frame: .zero)
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

    private lazy var tabBarMenuButton: UIButton = {
        let image = UIImage.init(named: "icon-menu")
        let imageView = UIImageView(image: image)

        let button = UIButton.init(frame: .zero)
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

    private lazy var itemTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = self.itemTableHeaderView
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(ItemInfoTableViewCell.self)
        tableView.register(ItemPhotosTableViewCell.self)
        tableView.register(ItemMapTableViewCell.self)
        tableView.register(ItemListSuggestionsTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType, item: Item, list: List) {
        self.item = item
        self.list = list

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .itemScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButton)

        if let user = dependencyGraph.storage.getUser(), user.id == item.addedBy.id {
            navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.tabBarMenuButton)
        }

        navigationController?.interactivePopGestureRecognizer?.delegate = self

        view.addSubview(itemTableView)
        view.addSubview(progressHUD)

        constrainToSuperview(itemTableView, exceptEdges: [.top])

        constrain(itemTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }

        constrain(progressHUD, view) { progressHUD, view in
            progressHUD.centerX == view.centerX
            progressHUD.centerY == view.centerY
        }

        refreshData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = itemTableView.tableHeaderView {
            tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

            let constraint = NSLayoutConstraint(item: tableHeaderView,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: itemTableView.frame.width)

            tableHeaderView.addConstraint(constraint)

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
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

        dependencyGraph.faveService.getListItem(userId: user.id, listId: list.id, itemId: item.id) { item, error in

            completion()

            guard let item = item else {
                return
            }

            self.item = item

            self.updateSaved(userId: user.id)
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

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        print("\nOpen menu\n")

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let user = dependencyGraph.storage.getUser(), user.id == item.addedBy.id {
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive , handler: { alertAction in
                self.deleteItemButtonTapped(item: self.item)

                alertController.dismiss(animated: true, completion: nil)
            }))

            alertController.addAction(UIAlertAction(title: "Edit", style: .default , handler: { alertAction in
                self.editItemButtonTapped(item: self.item)

                alertController.dismiss(animated: true, completion: nil)
            }))
        }

        //        alertController.addAction(UIAlertAction(title: "Share \(item.contextualItem.name)", style: .default , handler: { alertAction in
        //            self.shareItemButtonTapped()
        //
        //            alertController.dismiss(animated: true, completion: nil)
        //        }))

        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alertAction in
            alertController.dismiss(animated: true, completion: nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
    }

    func shareItemButtonTapped() {
        print("\n Share item button tapped\n")

        guard let url = NSURL(string: "https://www.fave.com/path-to-item") else {
            return
        }

        let title = "Check out \(item.contextualItem.name) on Fave:"
        let itemsToShare: [Any] = [title, url]

        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)
    }

    func deleteItemButtonTapped(item: Item) {
        print("\nDelete item\n")

        // Show confirmation
        // Put view in loading state
        // Make a call to delete the item
        // Upon success, call callback to refresh list
        // pop view

        let alertController = UIAlertController(title: "Remove item", message: "Are you sure you want to remove this item from your list?", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:
                alertController.dismiss(animated: true, completion: nil)
            }}
        ))

        alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { action in
            switch action.style {
            case .default, .cancel, .destructive:

                self.removeItem(item: item)

            }}
        ))

        self.present(alertController, animated: true, completion: nil)

    }

    func editItemButtonTapped(item: Item) {
        print("\nEdit item\n")

        // Show editing state
        // Upon tapping "update", show loading spinner
        // Make a call to update
        // Upon success, call callback to refresh item
        // Dismiss modal

        let updateItemViewController = UpdateItemViewController.init(dependencyGraph: dependencyGraph, item: item, creationType: .addition)

        let updateItemNavigationViewController = UINavigationController(rootViewController: updateItemViewController)

        updateItemViewController.delegate = self

        present(updateItemNavigationViewController, animated: true, completion: nil)
    }

    func selectListToFaveTo(item: Item, canceledSelection: @escaping () -> (), didSelectList: @escaping (_ list: List) -> ()) {

        let myListsViewController = MyListsViewController(dependencyGraph: dependencyGraph, item: item, canceledSelection: canceledSelection, didSelectList: didSelectList)
        myListsViewController.modalPresentationStyle = .overCurrentContext

        present(myListsViewController, animated: false, completion: nil)
    }

    private func removeItem(item: Item) {
        // Put view in loading state
        // Make a call to delete the item
        // Upon success, call callback to refresh list
        // pop view
        isLoading = true

        dependencyGraph.faveService.removeListItem(itemId: item.id) { (id, error) in
            self.isLoading = false

            guard let _ = id else {
                return
            }

            self.delegate?.didRemoveItem(viewController: self)
        }
    }
}

extension ItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemTableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
            case 0:
                let cell = tableView.dequeue(ItemInfoTableViewCell.self, indexPath: indexPath)

                cell.delegate = self
                cell.populate(item: item)

                return cell
            case 1:
                let cell = tableView.dequeue(ItemPhotosTableViewCell.self, indexPath: indexPath)

                cell.delegate = self
                cell.populate(item: item, dependencyGraph: dependencyGraph)

                return cell
            case 2:
                let cell = tableView.dequeue(ItemMapTableViewCell.self, indexPath: indexPath)

                cell.delegate = self
                cell.populate(item: item)

                return cell
            case 3:
                let cell = tableView.dequeue(ItemListSuggestionsTableViewCell.self, indexPath: indexPath)

                cell.delegate = self
                cell.populate(item: item)

                return cell
            default:
                return UITableViewCell.init(frame: .zero)
        }
    }
}

extension ItemViewController: ItemInfoTableViewCellDelegate {
    func  visitWebsiteButtonTapped(item: Item) {
        print("\nVisit Website Button Tapped\n")

        guard let googleItem = item.contextualItem as? GoogleItemType, let url = URL(string: googleItem.website) else {
            return
        }

        UIApplication.shared.open(url, options: [:])
    }

    func callButtonTapped(item: Item) {
        print("\nCall Button Tapped\n")

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        googleItem.internationalPhoneNumber?.makePhoneCall()
    }
}

extension ItemViewController: ItemPhotosTableViewCellDelegate {
    func didSelectItemPhoto() {

    }
}

extension ItemViewController: ItemMapTableViewCellDelegate {
    func didSelectMap(item: Item) {

    }
}

extension ItemViewController: ItemListSuggestionsTableViewCellDelegate {
    func didSelectList(list: List) {

    }
}

extension ItemViewController: ItemTableHeaderViewDelegate {
    func saveItemButtonTapped(item: Item, from: Bool, to: Bool) {

        guard let user = dependencyGraph.storage.getUser() else {

            login()

            listOfCurrentItems = []

            return
        }

        let weShouldFave = !from

        if weShouldFave {

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

    func didTapSavedByOthersLabel(item: Item) {

        let savedByViewController = SavedByViewController(dependencyGraph: dependencyGraph, item: item)

        let titleViewLabel = Label(text: "Saved by", font: FaveFont.init(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        savedByViewController.navigationItem.titleView = titleViewLabel

        navigationController?.pushViewController(savedByViewController, animated: true)
    }
}

extension ItemViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ItemViewController: UpdateItemViewControllerDelegate {
    func didUpdateItem(viewController: FaveVC) {
        refreshData {
            delay(0.3) {
                viewController.view.endEditing(true)
                viewController.dismiss(animated: true, completion: nil)
            }
        }
    }
}

