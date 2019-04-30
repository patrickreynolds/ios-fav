import Foundation
import UIKit

import Cartography

protocol ItemPhotosTableViewCellDelegate {
    func didSelectItemPhoto() // item: Item, photo: Photo
}


// Google Places API for photo references
// https://developers.google.com/places/web-service/photos

class ItemPhotosTableViewCell: UITableViewCell {

    var item: Item?
    var delegate: ItemPhotosTableViewCellDelegate?
    var googlePhotos = [GooglePhoto]()
    var dependencyGraph: DependencyGraphType?

    private lazy var titleLabel: Label = {
        let label = Label(text: "Photos",
                          font: FaveFont(style: .h4, weight: .bold),
                          textColor: FaveColors.Black90,
                          textAlignment: .left,
                          numberOfLines: 1)

        return label
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()

        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 120)

        return layout
    }()

    private lazy var photosCollectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionViewLayout)

        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = false
        collectionView.register(ItemGooglePhotoCollectionViewCell.self)
        collectionView.backgroundColor = FaveColors.White
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private lazy var dividerView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = FaveColors.Black20

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(photosCollectionView)
        contentView.addSubview(dividerView)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 24
            label.right == view.right - 16
            label.left == view.left + 16
        }

        constrain(photosCollectionView, titleLabel, contentView) { collectionView, label, view in
            collectionView.top == label.bottom + 16
            collectionView.right == view.right - 16
            collectionView.bottom == view.bottom - 24
            collectionView.left == view.left + 16

            collectionView.height == 120
        }

        constrain(dividerView, self) { dividerView, view in
            dividerView.right == view.right
            dividerView.bottom == view.bottom
            dividerView.left == view.left
            dividerView.height == 8
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(item: Item, dependencyGraph: DependencyGraphType?) {
        self.item = item
        self.dependencyGraph = dependencyGraph

        guard let googleItem = item.contextualItem as? GoogleItemType else {
            return
        }

        self.googlePhotos = googleItem.photos
    }
}

extension ItemPhotosTableViewCell: UICollectionViewDelegate {

}

extension ItemPhotosTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return googlePhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ItemGooglePhotoCollectionViewCell.self, indexPath: indexPath)

        let photo = googlePhotos[indexPath.row]

        if let dependencyGraph = dependencyGraph {
            cell.populate(photo: photo, dependencyGraph: dependencyGraph)
        }

        return cell
    }
}

extension ItemPhotosTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 120, height: 120)
    }
}
