import UIKit

import Cartography

class MyListsViewController: FaveVC {

    let item: Item

    var didSelectList: ((_ list: List) -> ())
    var canceledSelection: (() -> ())

    var lists: [List] = [] {
        didSet {
            if lists.isEmpty {
                UIView.animate(withDuration: 0.3) {
                    self.noListsView.alpha = 1
                }

                listsTableView.alpha = 0
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.noListsView.alpha = 0
                }

                listsTableView.alpha = 1
                listsTableView.reloadData()
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                loadingIndicatorView.startAnimating()
            } else {
                loadingIndicatorView.stopAnimating()
            }
        }
    }

    private lazy var listsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(SelectListTableViewCell.self)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))

        tableView.separatorColor = FaveColors.Black30

        return tableView
    }()

    private lazy var noListsView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = FaveColors.White

        let titleLabel = Label(text: "No lists found", font: FaveFont(style: .h4, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 0)

        let subtitleLabel = Label(text: "Create a new list to add your entry.", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 0)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        constrain(titleLabel, subtitleLabel, view) { titleLabel, subtitleLabel, view in
            titleLabel.top == view.top + 24
            titleLabel.right == view.right - 32
            titleLabel.left == view.left + 32

            subtitleLabel.top == titleLabel.bottom + 8
            subtitleLabel.right == titleLabel.right
            subtitleLabel.left == titleLabel.left
            subtitleLabel.bottom == view.bottom - 24
        }

        view.alpha = 0

        return view
    }()

    private lazy var newButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)

        button.addTarget(self, action: #selector(createListButtonTapped), for: .touchUpInside)
        button.backgroundColor = FaveColors.Accent
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.layer.cornerRadius = 16

        let attributedTitle = NSAttributedString(string: "New",
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    private lazy var loadingIndicatorView: IndeterminateCircularIndicatorView = {
        var indicator = IndeterminateCircularIndicatorView()

        return indicator
    }()

    init(dependencyGraph: DependencyGraphType, item: Item, canceledSelection: @escaping () -> (), didSelectList: @escaping (_ list: List) -> ()) {
        self.didSelectList = didSelectList
        self.canceledSelection = canceledSelection
        self.item = item

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .myListsScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.white

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelection))

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newButton)

        view.addSubview(listsTableView)
        view.addSubview(loadingIndicatorView)
        view.addSubview(noListsView)

        constrainToSuperview(listsTableView)

        constrain(loadingIndicatorView, view) { loadingIndicator, view in
            loadingIndicator.centerX == view.centerX
            loadingIndicator.centerY == view.centerY
        }

        constrain(noListsView, view) { noListsView, view in
            noListsView.top == view.topMargin + 64
            noListsView.right == view.right
            noListsView.left == view.left + 16
        }

        let titleViewLabel = Label(text: "Select a collection", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.bringSubviewToFront(loadingIndicatorView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadLists() {
            self.isLoading = false
        }
    }

    func loadLists(completion: @escaping () -> ()) {
        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        isLoading = true

        dependencyGraph.faveService.getLists(userId: user.id) { lists, error in
            guard let unwrappedLists = lists, error == nil else {
                completion()

                return
            }

            let lists = unwrappedLists.filter({ $0.title.lowercased() != "recommendations" && $0.title.lowercased() != "saved for later" })
            let filterForDuplicates = lists.filter({ $0.id != self.item.listId })

            self.lists = filterForDuplicates

            completion()
        }
    }

    func didSelectList(list: List) {
        didSelectList(list)
    }

    @objc func cancelSelection(sender: UIBarButtonItem!) {
        dismiss(animated: true, completion: {
            self.canceledSelection()
        })
    }

    @objc func createListButtonTapped(sender: UIButton!) {
        sender.performImpact(style: .light)

        let createListViewController = CreateListViewController(dependencyGraph: dependencyGraph)

        createListViewController.delegate = self

        navigationController?.pushViewController(createListViewController, animated: true)
    }
}

extension MyListsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let list = self.lists[indexPath.row]

        self.didSelectList(list: list)

        dismiss(animated: true, completion: nil)
    }
}

extension MyListsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SelectListTableViewCell.self, indexPath: indexPath)

        let list = lists[indexPath.row]
        cell.populate(list: list)

        return cell
    }
}

extension MyListsViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {
        didSelectList(list)
    }
}
