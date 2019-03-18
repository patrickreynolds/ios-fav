import Foundation

import UIKit
import Cartography
import MBProgressHUD

class ProfileViewController: FaveVC {

    private lazy var profileTableHeaderView: ProfileTableViewHeader = {
        return ProfileTableViewHeader(dependencyGraph: self.dependencyGraph, user: self.dependencyGraph.storage.getUser())
    }()

    private lazy var profileTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 667))

        tableView.tableHeaderView = self.profileTableHeaderView

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .profileScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        view.addSubview(profileTableView)

        constrainToSuperview(profileTableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = self.profileTableView.tableHeaderView {
            tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

            let constraint = NSLayoutConstraint(item: tableHeaderView,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: self.profileTableView.frame.width)

            tableHeaderView.addConstraint(constraint)

            let compressedHeaderSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            tableHeaderView.removeConstraint(constraint)

            tableHeaderView.translatesAutoresizingMaskIntoConstraints = true

            tableHeaderView.frame = compressedHeaderSize.toRect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dependencyGraph.faveService.getCurrentUser { response, error in
            if let userData = response, let user = User(data: userData) {
                self.dependencyGraph.storage.saveUser(user: user)
                self.profileTableHeaderView.updateUserInfo(user: user)

                self.logUserData(userData: userData)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let user = self.dependencyGraph.storage.getUser() else {
            return
        }

        self.navigationController?.navigationBar.topItem?.title = user.handle
        self.tabBarController?.tabBar.items?[2].title = "Profile"
    }

    private func logUserData(userData: [String: AnyObject]) {
        print("\n\nUser keys: \(Array(userData.keys))\n\n")
        print("User: \(userData.description)")
    }
}
