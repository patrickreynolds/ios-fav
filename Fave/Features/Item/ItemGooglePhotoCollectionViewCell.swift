import UIKit

import Cartography

class ItemGooglePhotoCollectionViewCell: UICollectionViewCell {

    var showPhoto: Bool = false

    var photo: FavePhotoType? {
        didSet {
            resetImage()

            if !showPhoto {
                return
            }

            guard let photo = photo else {
                return
            }

            FaveImageCache.downloadImage(url: photo.url) { image in
                guard let image = image else {

                    return
                }

                DispatchQueue.main.async {
                    self.googlePhotoImageView.setNeedsDisplay()
                    self.googlePhotoImageView.setNeedsLayout()
                    self.googlePhotoImageView.layoutIfNeeded()
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

    override func prepareForReuse() {
        resetImage()
    }

    func populate(photo: FavePhotoType, showPhoto: Bool) {
        self.showPhoto = showPhoto
        self.photo = photo
    }

    private func resetImage() {
        self.googlePhotoImageView.image = nil
        self.googlePhotoImageView.setNeedsDisplay()
        self.googlePhotoImageView.setNeedsLayout()
        self.googlePhotoImageView.layoutIfNeeded()
        self.googlePhotoImageView.backgroundColor = FaveColors.Black20
    }
}
