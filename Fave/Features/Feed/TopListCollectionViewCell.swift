import UIKit

import Cartography

protocol TopListCollectionViewCellDelegate {
    func didSelectUser(user: User)
}

class TopListCollectionViewCell: UICollectionViewCell {

    private var dependencyGraph: DependencyGraphType?

    var delegate: TopListCollectionViewCellDelegate?

    private var topList: List? {
        didSet {
            topListsTableView.reloadData()

            var title = ""
            if let topList = topList {
                title = "See all in \(topList.title)"
            }

            let attributedTitle = NSAttributedString(string: title,
                                                     font: FaveFont(style: .small, weight: .semiBold).font,
                                                     textColor: FaveColors.Accent)

            seeAllItemsButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }

    private lazy var topListsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = FaveColors.White

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))

        tableView.register(TopListItemTableViewCell.self)

        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: -24, right: 0)

        tableView.isScrollEnabled = false
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        return tableView
    }()

    private lazy var seeAllItemsButton: UIButton = {
        let button = UIButton.init(frame: .zero)

        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = FaveColors.White
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.contentHorizontalAlignment = .left

        var title = ""
        if let topList = topList {
            title = "See all in \(topList.title)"
        }

        let attributedTitle = NSAttributedString(string: title,
                                                 font: FaveFont(style: .small, weight: .semiBold).font,
                                                 textColor: FaveColors.Accent)
        button.setAttributedTitle(attributedTitle, for: .normal)

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = FaveColors.White

        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true

        contentView.layer.cornerRadius = 4
        contentView.layer.borderWidth = 1.0

        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath

        contentView.addSubview(topListsTableView)
        contentView.addSubview(seeAllItemsButton)

        constrainToSuperview(topListsTableView, exceptEdges: [.bottom])
        constrainToSuperview(seeAllItemsButton, exceptEdges: [.top])

        constrain(topListsTableView, seeAllItemsButton) { tableView, button in
            button.top == tableView.bottom
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(topList: List, dependencyGraph: DependencyGraphType) {
        self.dependencyGraph = dependencyGraph
        self.topList = topList
    }
}

extension TopListCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topList?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(TopListItemTableViewCell.self, indexPath: indexPath)

        if let item = topList?.items[indexPath.row] {
            cell.populate(item: item)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let topList = topList else {
            return UIView()
        }

        let header = TopListUserSectionHeaderView(list: topList)

        header.delegate = self

        return header
    }
}

extension TopListCollectionViewCell: UITableViewDelegate {}

extension TopListCollectionViewCell: TopListUserSectionHeaderViewDelegate {
    func didSelectTopListUserHeader(user: User) {
        print("\n Did Select Top List User Header \n")

        delegate?.didSelectUser(user: user)
    }

//    func didSelectItem(item: Item) {
//
//        delegate?.didSelectItem(item: item)
//
//    }
}
