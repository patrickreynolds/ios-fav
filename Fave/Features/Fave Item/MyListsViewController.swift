import UIKit

import Cartography

class MyListsViewController: FaveVC {

    var sheetOffsetLayoutConstraint: NSLayoutConstraint?

    var didSelectList: ((_ list: List) -> ())
    var canceledSelection: (() -> ())

    var lists: [List] = [] {
        didSet {
            listsTableView.reloadData()
        }
    }

    private lazy var listsTableView: AutoSizingTableView = {
        let tableView = AutoSizingTableView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self)
        tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01))

        tableView.separatorColor = FaveColors.Black20

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType, canceledSelection: @escaping () -> (), didSelectList: @escaping (_ list: List) -> ()) {
        self.didSelectList = didSelectList
        self.canceledSelection = canceledSelection

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .myListsScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var loadingSpinnerView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)

        activityIndicatorView.hidesWhenStopped = true

        return activityIndicatorView
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black100
        view.alpha = 0

        return view
    }()

    private lazy var pickerView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.White

        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        constrain(view) { view in
            view.width == UIScreen.main.bounds.width
            view.height == UIScreen.main.bounds.height
        }

        return view
    }()

    private lazy var pickerTitleLabel: Label = {
        let label = Label.init(text: "Add to List", font: FaveFont.init(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)

        self.pickerView.addSubview(label)

        constrain(label, self.pickerView) { label, view in
            label.centerX == view.centerX
            label.top == view.top + 16
        }

        return label
    }()

    private lazy var cancelLabel: Label = {
        let label = Label.init(text: "Cancel", font: FaveFont(style: .h5, weight: .regular), textColor: FaveColors.Black60, textAlignment: .left, numberOfLines: 1)

        label.isUserInteractionEnabled = true

        self.pickerView.addSubview(label)

        constrain(label, self.pickerView) { label, view in
            label.top == view.top + 16
            label.left == view.left + 16
        }

        _ = label.tapped({ _ in
            self.cancelSelection()
        })

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        view.addSubview(backgroundView)
        view.addSubview(pickerView)

        pickerView.addSubview(loadingSpinnerView)
        pickerView.addSubview(listsTableView)

        constrainToSuperview(backgroundView)

        constrain(loadingSpinnerView, pickerView) { spinnerView, view in
            spinnerView.centerX == view.centerX
            spinnerView.centerY == view.centerY
        }

        constrain(pickerView, view) { pickerView, view in
            pickerView.left == view.left
            pickerView.right == view.right
            sheetOffsetLayoutConstraint = pickerView.top == view.bottom
        }

        constrainToSuperview(listsTableView, exceptEdges: [.top])

        constrain(listsTableView, pickerTitleLabel) { tableView, label in
            tableView.top == label.bottom + 16
        }

        view.bringSubviewToFront(pickerView)

        _ = backgroundView.tapped { _ in
            self.cancelSelection()
        }

        cancelLabel.alpha = 1

        loadingSpinnerView.startAnimating()

        loadLists {
            self.loadingSpinnerView.stopAnimating()
        }
    }

    func loadLists(completion: @escaping () -> ()) {
        guard let user = dependencyGraph.storage.getUser() else {
            return
        }

        dependencyGraph.faveService.getLists(userId: user.id) { lists, error in
            guard let unwrappedLists = lists, error == nil else {
                completion()

                return
            }

            self.lists = unwrappedLists.filter({ (list) -> Bool in
                return list.title.lowercased() != "recommendations"
            })

            completion()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let constraint = sheetOffsetLayoutConstraint {
            constraint.constant -= (UIScreen.main.bounds.height - 64)
        }

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.backgroundView.alpha = 0.56
        }, completion: nil)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.2, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func dismissView() {
        if let constraint = sheetOffsetLayoutConstraint {
            constraint.constant += (UIScreen.main.bounds.height - 64)
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }

    func didSelectList(list: List) {
        didSelectList(list)
        dismissView()
    }

    func cancelSelection() {
        self.canceledSelection()
        self.dismissView()
    }
}

extension MyListsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let list = self.lists[indexPath.row]

        self.didSelectList(list: list)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

extension MyListsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, indexPath: indexPath)

        let list = lists[indexPath.row]

        cell.textLabel?.text = list.title

        return cell
    }
}
