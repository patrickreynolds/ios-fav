import UIKit

import Cartography

protocol FaveLoggedOutWelcomeViewDelegate {
    func didSelectUser(user: User)
    func didSelectList(list: List)
    func didSelectItem(item: Item, list: List)
    func didSelectSignUp()
}

class FaveLoggedOutWelcomeView: UIView {

    private var dependencyGraph: DependencyGraphType?

    var delegate: FaveLoggedOutWelcomeViewDelegate?

    private var topLists: [List] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private lazy var titleLabel: Label = {
        let label = Label(text: "Welcome to Fave!",
                               font: FaveFont(style: .h4, weight: .extraBold),
                               textColor: FaveColors.Black90,
                               textAlignment: .center,
                               numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "Create lists, share recommendations, and discover places with friends.",
                                  font: FaveFont(style: .h5, weight: .regular),
                                  textColor: FaveColors.Black70,
                                  textAlignment: .center,
                                  numberOfLines: 0)

        return label
    }()

    private lazy var signUpWithFacebookLabel: Label = {
        let label = Label(text: "Sign up with Facebook",
                          font: FaveFont(style: .h5, weight: .bold),
                          textColor: FaveColors.FacebookBlue,
                          textAlignment: .center,
                          numberOfLines: 0)

        _ = label.tapped { recognizer in
            self.delegate?.didSelectSignUp()
        }

        label.isUserInteractionEnabled = true

        return label
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()


        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let size = UIScreen.main.bounds.width - 64
//        let height: CGFloat = 338.0
        layout.estimatedItemSize = CGSize(width: size, height: size)
//        layout.itemSize = CGSize(width: size, height: height)

        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

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
        addSubview(signUpWithFacebookLabel)

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

        constrain(signUpWithFacebookLabel, collectionView, self) { signUpWithFacebookLabel, collectionView, view in
            signUpWithFacebookLabel.centerX == view.centerX
            signUpWithFacebookLabel.top == collectionView.bottom + 24
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withTopLists lists: [List], dependencyGraph: DependencyGraphType) {
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

        cell.delegate = self

        return cell
    }
}

extension FaveLoggedOutWelcomeView: UICollectionViewDelegate {}

extension FaveLoggedOutWelcomeView: TopListCollectionViewCellDelegate {
    func didSelectUser(user: User) {
        delegate?.didSelectUser(user: user)
    }

    func didSelectList(list: List) {
        delegate?.didSelectList(list: list)
    }

    func didSelectItem(item: Item, list: List) {
        delegate?.didSelectItem(item: item, list: list)
    }
}
