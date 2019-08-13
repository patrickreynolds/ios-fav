import UIKit

import Cartography

struct ImageInfo {
    let image: UIImage
    let tintColor: UIColor
}

class DefaultDialogContentView: UIView {
    // MARK: - Constants

    private struct Constants {
        static let Padding: CGFloat = 24
        static let ImageViewDimension: CGFloat = 40
        static let TitleTopMargin: CGFloat = 8
        static let BodyTopMargin: CGFloat = 16
    }

    // MARK: - Initializers
    init(imageInfo: ImageInfo? = nil, title: String? = nil, body: String? = nil, titleAlignment: NSTextAlignment = .center) {
        super.init(frame: CGRect.zero)

        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.tintColor = imageInfo?.tintColor
        imageView.image = imageInfo?.image

        let titleLabel = Label(text: title,
                               font: FaveFont(style: .h4, weight: .bold),
                               textColor: FaveColors.Black100,
                               textAlignment: titleAlignment,
                               numberOfLines: 0)

        let bodyLabel = Label(text: body,
                              font: FaveFont(style: .h5, weight: .regular),
                              textColor: FaveColors.Black90,
                              textAlignment: .center,
                              numberOfLines: 0)

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(bodyLabel)

        let imageProvided = imageInfo?.image != nil
        let titleProvided = title?.isEmpty == false

        constrain(imageView, titleLabel, bodyLabel, self) { imageView, titleLabel, bodyLabel, view in
            imageView.top == view.top + Constants.Padding
            imageView.centerX == view.centerX
            imageView.width == (imageProvided ? Constants.ImageViewDimension : 0)
            imageView.height == imageView.width

            let titleLabelTopMargin = (imageProvided && titleProvided ? Constants.TitleTopMargin : 0)
            titleLabel.top == imageView.bottom + titleLabelTopMargin
            titleLabel.left == view.left + Constants.Padding
            titleLabel.right == view.right - Constants.Padding

            let bodyLabelTopMargin = ((imageProvided || titleProvided) && body?.isEmpty == false ? Constants.BodyTopMargin : 0)
            bodyLabel.top == titleLabel.bottom + bodyLabelTopMargin
            bodyLabel.left == titleLabel.left
            bodyLabel.right == titleLabel.right
            bodyLabel.bottom == view.bottom
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
