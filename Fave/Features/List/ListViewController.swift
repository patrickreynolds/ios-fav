import Foundation

import UIKit
import Cartography
import MBProgressHUD

class ListViewController: FaveVC {
    var list: List

    private lazy var listTableHeaderView: ListTableHeaderView = {
        return ListTableHeaderView(dependencyGraph: self.dependencyGraph, list: self.list)
    }()

    private lazy var sectionHeaderView: ListTableSectionHeaderView = {
        let sectionHeaderView = ListTableSectionHeaderView(list: self.list)

        sectionHeaderView.delegate = self

        return sectionHeaderView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        refreshControl.tintColor = FaveColors.Accent

        return refreshControl
    }()

    private lazy var loadingIIndicator: UIActivityIndicatorView = {
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

        return button
    }()

    private lazy var listTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = self.listTableHeaderView
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(EntryTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        return tableView
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

        view.addSubview(listTableView)

        constrainToSuperview(listTableView, exceptEdges: [.top])

        constrain(listTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }
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

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(2.0) {
                self.listTableView.reloadData()

                self.refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        var userId = ""

        if let user = dependencyGraph.storage.getUser() {
            userId = "\(user.id)"
        }

        dependencyGraph.faveService.getList(userId: userId, listId: "\(self.list.id)") { response, error in
            if let unwrappedResponse = response, let listData = unwrappedResponse["data"] as? [String: AnyObject] {
                print("\n\nGOT A VALID RESPONSE\n\n")

                if let list = List(data: listData) {
                    self.list = list
                }

                self.listTableView.reloadData()
            }

            completion()
        }
    }

    @objc func backButtonTapped(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listTableView.deselectRow(at: indexPath, animated: true)

//        let item = list.items[indexPath.row]
//
//        let itemViewController = ItemViewController(dependencyGraph: self.dependencyGraph, item: item)
//        itemViewController = "Item"
//
//        navigationController?.pushViewController(itemViewController, animated: true)
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(EntryTableViewCell.self, indexPath: indexPath)

        let item = list.items[indexPath.row]
        cell.populate(item: item)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? self.sectionHeaderView : UIView(frame: CGRect.zero)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 48 : 0
    }
}

extension ListViewController: ListTableSectionHeaderViewDelegate {
    func entriesButtonTapped() {
        print("\nLists Button Tapped\n")
    }

    func recommendationsButtonTapped() {
        print("\nRecommentaion Button Tapped\n")
    }

    func newEntryButtonTapped() {
        print("\nAdd Item Button Tapped\n")

//        let createListViewController = CreateItemViewController.init(dependencyGraph: self.dependencyGraph)
//        let createListNavigationViewController = UINavigationController(rootViewController: createListViewController)
//
//        present(createListNavigationViewController, animated: true, completion: nil)
    }
}

