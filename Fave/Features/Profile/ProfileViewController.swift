import Foundation

import UIKit
import Cartography
import MBProgressHUD

class ProfileViewController: FaveVC {

    var lists: [List] {
        didSet {
            self.sectionHeaderView.updateLists(lists: lists)
            self.profileTableView.reloadData()
        }
    }

    private lazy var profileTableHeaderView: ProfileTableHeaderView = {
        return ProfileTableHeaderView(dependencyGraph: self.dependencyGraph, user: self.dependencyGraph.storage.getUser())
    }()

    private lazy var sectionHeaderView: ProfileTableSectionHeaderView = {
        let sectionHeaderView = ProfileTableSectionHeaderView(lists: self.lists)

        sectionHeaderView.delegate = self

        return sectionHeaderView
    }()

    private lazy var newListButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        button.tintColor = FaveColors.White

        return button
    }()

    private lazy var profileTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableHeaderView = self.profileTableHeaderView
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.register(ListTableViewCell.self)

        tableView.addSubview(self.refreshControl)

        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

        refreshControl.tintColor = FaveColors.Accent

        return refreshControl
    }()

    private lazy var listTableLoadingIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()

        indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.style = UIActivityIndicatorView.Style.gray

        return indicator
    }()

    init(dependencyGraph: DependencyGraphType) {
//        self.lists = [
//            List(id: 1, title: "Favorite Wings in SF", followers: 12, items: [
//                Item(id: 1, title: "Item 1"),
//                Item(id: 2, title: "Item 2"),
//                Item(id: 3, title: "Item 3")
//                ]),
//            List(id: 2, title: "Best SF Photo Spots", followers: 598, items: [
//                Item(id: 4, title: "Item A"),
//                Item(id: 5, title: "Item B"),
//                Item(id: 6, title: "Item C")
//                ]),
//            List(id: 3, title: "Bucketlist Locations", followers: 298, items: [
//                Item(id: 7, title: "Item Doe"),
//                Item(id: 8, title: "Item Ray"),
//                Item(id: 9, title: "Item Mi")
//                ])]

        self.lists = []

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .profileScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        view.addSubview(profileTableView)
        view.addSubview(newListButton)

        view.bringSubviewToFront(newListButton)

        constrainToSuperview(profileTableView, exceptEdges: [.top])

        constrain(profileTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }

        constrain(newListButton, view) { button, view in
            button.right == view.right - 16
            button.bottom == view.bottomMargin - 16
            button.width == 56
            button.height == 56
        }

        refreshData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = profileTableView.tableHeaderView {
            tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

            let constraint = NSLayoutConstraint(item: tableHeaderView,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: profileTableView.frame.width)

            tableHeaderView.addConstraint(constraint)

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let user = self.dependencyGraph.storage.getUser() else {
            return
        }

        navigationController?.navigationBar.topItem?.title = user.handle
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData {
            delay(2.0) {
                self.profileTableView.reloadData()

                refreshControl.endRefreshing()
            }
        }
    }

    private func refreshData(completion: @escaping () -> () = {}) {
        dependencyGraph.faveService.getCurrentUser { response, error in
            if let userData = response, let user = User(data: userData) {
                self.dependencyGraph.storage.saveUser(user: user)
                self.profileTableHeaderView.updateUserInfo(user: user)

                self.navigationController?.navigationBar.topItem?.title = user.handle

                self.logUserData(userData: userData)
            }
        }

        var userId = ""

        if let user = dependencyGraph.storage.getUser() {
            userId = "\(user.id)"
        }

        dependencyGraph.faveService.getLists(userId: userId) { response, error in
            if let unwrappedResponse = response, let listData = unwrappedResponse["data"] as? [[String: AnyObject]] {
                print("\n\nGOT A VALID RESPONSE\n\n")

                let updatedLists = listData.map({ List(data: $0)}).compactMap({ $0 })

                self.lists = updatedLists
            }

            completion()
        }
    }

    private func logUserData(userData: [String: AnyObject]) {
        print("\n\nUser keys: \(Array(userData.keys))\n\n")
        print("User: \(userData.description)")
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileTableView.deselectRow(at: indexPath, animated: true)

        let list = self.lists[indexPath.row]

        let listViewController = ListViewController(dependencyGraph: self.dependencyGraph, list: list)
        listViewController.title = "List"

        navigationController?.pushViewController(listViewController, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ListTableViewCell.self, indexPath: indexPath)

        let list = lists[indexPath.row]
        cell.populate(list: list)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? self.sectionHeaderView : UIView(frame: CGRect.zero)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 48 : 0
    }

    @objc func createButtonTapped(sender: UIButton!) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Item", style: .default , handler: { alertAction in
            self.addItemButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "List", style: .default , handler: { alertAction in
            self.addListButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alertAction in
            alertController.dismiss(animated: true, completion: nil)
        }))

        self.present(alertController, animated: true, completion: nil)
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

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }
}

extension ProfileViewController: ProfileTableSectionHeaderViewDelegate {
    func listsButtonTapped() {
        print("\n\nLists Button Tapped\n\n")
    }
}

extension ProfileViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {
        refreshData()
    }
}

extension ProfileViewController: CreateItemViewControllerDelegate {
    func didCreateItem() {

    }
}
