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
    var photos = [FavePhotoType]()
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
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 120)

        return layout
    }()

    private lazy var photosCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

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

        let savedPhotos = googleItem.savedPhotos

        if !savedPhotos.isEmpty {
            self.photos = savedPhotos
        } else {
            self.photos = Array(googleItem.photos.prefix(5))
        }
    }
}

extension ItemPhotosTableViewCell: UICollectionViewDelegate {

}

extension ItemPhotosTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ItemGooglePhotoCollectionViewCell.self, indexPath: indexPath)

        let photo = photos[indexPath.row]

        cell.populate(photo: photo)

        return cell
    }
}

extension ItemPhotosTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}
