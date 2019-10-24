import UIKit

import Cartography

class ItemGooglePhotoCollectionViewCell: UICollectionViewCell {

    var photo: FavePhotoType? {
        didSet {
            resetImage()

            guard let photo = photo else {
                return
            }

            FaveImageCache.downloadImage(url: photo.url) { lastestURL, image in
                guard let image = image else {
                    return
                }

                print("Image URL: \(photo.url.absoluteString)\n")

                DispatchQueue.main.async {
                    if photo.url.absoluteString == lastestURL {
                        self.googlePhotoImageView.setNeedsDisplay()
                        self.googlePhotoImageView.setNeedsLayout()
                        self.googlePhotoImageView.layoutIfNeeded()
                        self.googlePhotoImageView.image = image
                    } else {
                        print("\n\nSkipping outdated image call\n\n")
                    }
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

    func populate(photo: FavePhotoType) {
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
