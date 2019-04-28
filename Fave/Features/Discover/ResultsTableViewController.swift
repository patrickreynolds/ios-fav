//
//  ResultsTableViewController.swift
//  Fave
//
//  Created by Patrick Reynolds on 4/22/19.
//  Copyright © 2019 Patrick Reynolds. All rights reserved.
//

import Foundation
import UIKit

import Cartography

protocol ResultsTableViewControllerDelegate {
    func didSelectUser(user: User)
}

class ResultsTableViewController: FaveVC {

    var delegate: ResultsTableViewControllerDelegate?

    var filteredUsers: [User] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }

    lazy var resultsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.01), style: .plain)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UserSearchTableViewCell.self)

        tableView.separatorColor = UIColor.clear

        return tableView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .searchResultsScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        view.addSubview(resultsTableView)

        constrainToSuperview(resultsTableView, exceptEdges: [.top])

        constrain(resultsTableView, view) { tableView, view in
            tableView.top == view.topMargin
        }
    }
}

extension ResultsTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UserSearchTableViewCell.self, indexPath: indexPath)

        let user = filteredUsers[indexPath.row]
        cell.populate(user: user)

        return cell
    }
}

extension ResultsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultsTableView.deselectRow(at: indexPath, animated: true)

        let user = self.filteredUsers[indexPath.row]

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: user)

        let titleViewLabel = Label.init(text: user.handle, font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black80, textAlignment: .center, numberOfLines: 1)
        profileViewController.navigationItem.titleView = titleViewLabel

        presentingViewController?.navigationController?.pushViewController(profileViewController, animated: true)

        delegate?.didSelectUser(user: user)
    }
}