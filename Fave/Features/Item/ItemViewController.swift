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
        }
    }

    private lazy var itemTableHeaderView: ItemTableHeaderView = {
        let view = ItemTableHeaderView(dependencyGraph: self.dependencyGraph, item: item)

//        view.delegate = self

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

    init(dependencyGraph: DependencyGraphType, item: Item) {
        self.item = item

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
//        dependencyGraph.faveService.getListItem(itemId: "\(item.id)") { response, error in
//            guard let item = response else {
//                return
//            }
//
//            self.item = item
//        }
        completion()
    }

    @objc func menuButtonTapped(sender: UIBarButtonItem) {
        print("\nOpen menu\n")
    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
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
