import UIKit

import Cartography

class ItemGooglePhotoCollectionViewCell: UICollectionViewCell {

    var dependencyGarph: DependencyGraphType?

    var photo: GooglePhoto? {
        didSet {
            guard let photo = photo,
                let dependencyGraph = self.dependencyGarph,
                let googlePhotoUrl = photo.photoUrl(googleApiKey: dependencyGraph.appConfiguration.googleAPIKey, googlePhotoReference: photo.googlePhotoReference, maxHeight: 400, maxWidth: 400) else {
                return
            }

            FaveImageCache.downloadImage(url: googlePhotoUrl) { image in
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

    func populate(photo: GooglePhoto, dependencyGraph: DependencyGraphType) {
        self.dependencyGarph = dependencyGraph
        self.photo = photo
    }
}
