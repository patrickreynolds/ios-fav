import Foundation

import UIKit
import Cartography
import MBProgressHUD

enum ItemSectionType: Int {
    case info = 0
    case photos = 1
    case directions = 2
    case suggestions = 3
}

class ItemViewController: FaveVC {

    var item: Item {
        didSet {
            itemTableView.reloadData()

            itemTableHeaderView.updateHeader(item: item)
        }
    }

    var list: List {
        didSet {

        }
    }

    private lazy var itemTableHeaderView: ItemTableHeaderView = {
        let view = ItemTableHeaderView(dependencyGraph: dependencyGraph, item: item)

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

    private lazy var tabBarMenuButton: UIButton = {
        let button = UIButton.init(type: .custom)

        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(named: "icon-menu"), for: .normal)
        button.adjustsImageWhenHighlighted = false

        return button
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
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.tabBarMenuButton)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        view.addSubview(itemTableView)

        constrainToSuperview(itemTableView, exceptEdges: [.top])

        constrain(itemTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }
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
            guard let item = item else {
                return
            }

            self.item = item
        }
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        print("\nOpen menu\n")


        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Share \(item.contextualItem.name)", style: .default , handler: { alertAction in
            self.shareItemButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

//        if let user = dependencyGraph.storage.getUser(), user.id == item.owner.id {
//            alertController.addAction(UIAlertAction(title: "Edit item info", style: .default , handler: { alertAction in
//                self.editListButtonTapped()
//
//                alertController.dismiss(animated: true, completion: nil)
//            }))
//        }

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
}

extension ItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemTableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
                cell.populate(item: item)

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
    func faveItemTapped(item: Item) {
        print("\n Fave Item Tapped \n")
    }
}

extension ItemViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
