import UIKit

import Cartography

protocol TopListCollectionViewCellDelegate {
    func didSelectUser(user: User)
    func didSelectList(list: List)
    func didSelectItem(item: Item, list: List)
}

class TopListCollectionViewCell: UICollectionViewCell {

    private var dependencyGraph: DependencyGraphType?

    var delegate: TopListCollectionViewCellDelegate?

    private var topList: List? {
        didSet {
//            var title = ""
//            if let topList = topList {
//                title = "See all in \(topList.title)"
//            }
//
//            let attributedTitle = NSAttributedString(string: title,
//                                                     font: FaveFont(style: .h5, weight: .semiBold).font,
//                                                     textColor: FaveColors.Accent)
//
//            seeAllItemsButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }

    private lazy var seeAllItemsButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.setTitleColor(FaveColors.White, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 6
        button.clipsToBounds = true

        let attributedTitle = NSAttributedString(string: "View list",
                                                 font: FaveFont(style: .h5, weight: .semiBold).font,
                                                 textColor: FaveColors.White)
        button.setAttributedTitle(attributedTitle, for: .normal)

        button.addTarget(self, action: #selector(didTapListButton), for: .touchUpInside)

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

        contentView.addSubview(seeAllItemsButton)

        constrain(seeAllItemsButton, self) { seeAllItemsButton, view in
            seeAllItemsButton.centerX == view.centerX
            seeAllItemsButton.centerY == view.centerY
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(topList: List, dependencyGraph: DependencyGraphType) {
        self.dependencyGraph = dependencyGraph
        self.topList = topList
    }

    @objc func didTapListButton(sender: UIButton!) {
        if let topList = topList {
            delegate?.didSelectList(list: topList)
        }
    }
}

//extension TopListCollectionViewCell: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return topList?.items.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeue(TopListItemTableViewCell.self, indexPath: indexPath)
//
//        if let item = topList?.items[indexPath.row] {
//            cell.populate(item: item)
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 72
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.1
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        guard let topList = topList else {
//            return UIView()
//        }
//
//        let header = TopListUserSectionHeaderView(list: topList)
//
//        header.delegate = self
//
//        return header
//    }
//}

extension TopListCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let list = topList {
            delegate?.didSelectItem(item: list.items[indexPath.row], list: list)
        }
    }
}

extension TopListCollectionViewCell: TopListUserSectionHeaderViewDelegate {
    func didSelectTopListUserHeader(user: User) {
        print("\n Did Select Top List User Header \n")

        delegate?.didSelectUser(user: user)
    }
}
