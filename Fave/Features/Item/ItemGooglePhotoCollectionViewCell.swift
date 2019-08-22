import UIKit

import Cartography

class ItemGooglePhotoCollectionViewCell: UICollectionViewCell {

    var photo: FavePhotoType? {
        didSet {
            guard let photo = photo else {
                return
            }

            FaveImageCache.downloadImage(url: photo.url) { image in
                guard let image = image else {
                    DispatchQueue.main.async {
                        self.googlePhotoImageView.backgroundColor = FaveColors.Black20
                    }

                    return
                }

                DispatchQueue.main.async {
                    self.googlePhotoImageView.image = image
                }
            }
        }
    }

    private lazy var googlePhotoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = FaveColors.Black20
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true

        contentView.addSubview(googlePhotoImageView)

        constrainToSuperview(googlePhotoImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(photo: FavePhotoType) {
        self.photo = photo
    }
}
