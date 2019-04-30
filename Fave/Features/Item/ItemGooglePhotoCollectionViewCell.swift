import Foundation
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

            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: googlePhotoUrl)

                    DispatchQueue.main.async {
                        self.googlePhotoImageView.image = UIImage(data: data)
                    }
                    return
                } catch {
                    print(error)
                }
            }
        }
    }

    

    private lazy var googlePhotoImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)

        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = FaveColors.Black20
        contentView.layer.cornerRadius = 6
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
