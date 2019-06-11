import UIKit

import Cartography

class FaveLoggedOutWelcomeView: UIView {

    private var dependencyGraph: DependencyGraphType?

    private var topLists: [TopList] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private lazy var titleLabel: Label = {
        let label = Label(text: "Welcome to Fave!",
                               font: FaveFont(style: .h4, weight: .bold),
                               textColor: FaveColors.Black90,
                               textAlignment: .center,
                               numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "Create, discover, and share your favorite places with friends.",
                                  font: FaveFont(style: .h5, weight: .regular),
                                  textColor: FaveColors.Black70,
                                  textAlignment: .center,
                                  numberOfLines: 0)

        return label
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 32
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)

        let size = UIScreen.main.bounds.width - 32
        let height: CGFloat = 338.0
//        layout.estimatedItemSize = CGSize(width: size, height: size)
        layout.itemSize = CGSize(width: size, height: height)

        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionViewLayout)

        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = false
        collectionView.register(TopListCollectionViewCell.self)
        collectionView.backgroundColor = FaveColors.White
//        collectionView.backgroundColor = FaveColors.Black10
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.contentInsetAdjustmentBehavior = .automatic

        return collectionView
    }()

    init() {
        super.init(frame: CGRect.zero)

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(collectionView)

        constrain(titleLabel, self) { titleLabel, view in
            titleLabel.top == view.top + 32
            titleLabel.centerX == view.centerX
        }

        constrain(subtitleLabel, titleLabel, self) { subtitleLabel, titleLabel, view in
            subtitleLabel.top == titleLabel.bottom + 8
            subtitleLabel.left == view.left + 32
            subtitleLabel.right == view.right - 32
        }

        constrain(collectionView, subtitleLabel, self) { collectionView, subtitleLabel, view in
            collectionView.top == subtitleLabel.bottom + 24

            collectionView.left == view.left
            collectionView.right == view.right

            let height = UIScreen.main.bounds.width

            collectionView.height == height
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withTopLists lists: [TopList], dependencyGraph: DependencyGraphType) {
        self.topLists = lists
        self.dependencyGraph = dependencyGraph
    }
}

extension FaveLoggedOutWelcomeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topLists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(TopListCollectionViewCell.self, indexPath: indexPath)

        let list = topLists[indexPath.row]

        if let dependencyGraph = dependencyGraph {
            cell.populate(topList: list, dependencyGraph: dependencyGraph)
        }

        return cell
    }
}

extension FaveLoggedOutWelcomeView: UICollectionViewDelegate {

}
