import Foundation
import Cartography

enum RecommendationState {
    case loading
    case presenting
}

class RecommendationsViewController: FaveVC {

    var state: RecommendationState = .presenting

    var listsForRecommendations: [Int: List] = [:]

    var recommendations: [Item] = [] {
        didSet {
            // reload table view

            let noRecommendationsViewAlpha: CGFloat = recommendations.isEmpty ? 1.0 : 0

            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.noRecommendationsView.alpha = noRecommendationsViewAlpha
            }, completion: nil)

            fetchLists {
                self.recommendationsTableView.reloadData()
            }
        }
    }

    private var items: [Item] = [] {
        didSet {
            // $0.listTitle.lowercased() == "recommendations"
            self.recommendations = [] // items.filter({ $0.isRecommendation })
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
        let view = UIView.init(frame: .zero)

        let titleLabel = Label(text: "No recommendations yet",
                          font: FaveFont(style: .h4, weight: .bold) ,
                          textColor: FaveColors.Black90,
                          textAlignment: .center,
                          numberOfLines: 1)

        let subtitleLabel = Label(text: "When someone sends you a recommendation, you'll see them here.",
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

        let titleViewLabel = Label.init(text: "Recommendations", font: FaveFont.init(style: .h5, weight: .bold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.addSubview(recommendationsTableView)
        view.addSubview(noRecommendationsView)
        view.addSubview(createButton)

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

        view.bringSubviewToFront(createButton)
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
        state = .loading

        dependencyGraph.faveService.myItems() { response, error in
            completion()

            self.state = .presenting

            guard let items = response else {
                return
            }

            self.listOfCurrentItems = items
        }
    }

    private func fetchLists(completion: @escaping () -> ()) {
        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        var responses = 0

        let recommendationIds = recommendations.map { $0.id }
        let listIds = recommendations.map { $0.listId }

        listIds.enumerated().forEach { (index: Int, id: Int) in
            dependencyGraph.faveService.getList(userId: user.id, listId: id, completion: { list, error in
                responses += 1

                guard let list = list else {
                    return
                }

                self.listsForRecommendations[recommendationIds[index]] = list

                if responses == recommendationIds.count {
                    completion()
                }
            })
        }
    }
}

extension RecommendationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recommendationsTableView.deselectRow(at: indexPath, animated: true)

        let item = recommendations[indexPath.row]

        if let list = listsForRecommendations[item.id] {
            let itemViewController = ItemViewController(dependencyGraph: dependencyGraph, item: item, list: list)

            let titleViewLabel = Label.init(text: "Place", font: FaveFont.init(style: .h5, weight: .bold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
            itemViewController.navigationItem.titleView = titleViewLabel

            navigationController?.pushViewController(itemViewController, animated: true)
        }
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
        let list = listsForRecommendations[item.id]

        var mySavedItem: Item? = nil
        if item.isSaved ?? false {
            mySavedItem = listOfCurrentItems.filter({$0.dataId == item.dataId}).first
        }

        cell.populate(dependencyGraph: dependencyGraph,
                      item: item,
                      currentUser: dependencyGraph.storage.getUser(),
                      list: list,
                      mySavedItem: mySavedItem)

        return cell
    }
}

extension RecommendationsViewController: EntryTableViewCellDelegate {
    func faveItemButtonTapped(item: Item, from: Bool, to: Bool) {

    }

    func shareItemButtonTapped(item: Item) {

    }

    func googlePhotoTapped(item: Item) {

    }

    func dismissButtonTapped(item: Item) {

    }

    func addToListButtonTapped(item: Item) {

    }
}

extension RecommendationsViewController {
    @objc func createButtonTapped(sender: UIButton!) {

        guard dependencyGraph.authenticator.isLoggedIn() else {
            login()

            return
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Make a recommendation", style: .default , handler: { alertAction in
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
        let createListViewController = CreateListViewController.init(dependencyGraph: self.dependencyGraph)
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

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph, creationType: .recommendation)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }
}

extension RecommendationsViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {

    }
}

extension RecommendationsViewController: CreateItemViewControllerDelegate {
    func didCreateItem() {

    }
}
