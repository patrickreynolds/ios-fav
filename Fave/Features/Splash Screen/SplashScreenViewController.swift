import UIKit

import Cartography

class SplashScreenViewController: FaveVC {

    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?

    private var isLoading: Bool = false {
        didSet {
            if isLoading {

                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1.2, options: [.curveEaseIn], animations: {
                    self.faveIconImageView.alpha = 1
                }) { (completion) in }

                UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {

                    self.faveIconImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

                }, completion: nil)

            } else {

                delay(1.0) {
                    UIView.animate(withDuration: 0.3, delay: 1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                        self.view.alpha = 0
                    }, completion: { (completed) in
                        self.dismiss(animated: false, completion: nil)
                    })
                }

            }
        }
    }

    private lazy var faveIconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "fave-logo")
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        imageView.backgroundColor = UIColor.red

        imageView.backgroundColor = FaveColors.Accent

        constrain(imageView) { imageView in
            self.heightConstraint = imageView.height == (UIScreen.main.bounds.width * 0.25)
            self.widthConstraint = imageView.width == (UIScreen.main.bounds.width * 0.25)
        }

        return imageView
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .splashScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.Accent

        view.addSubview(faveIconImageView)

        constrain(faveIconImageView, view) { imageView, view in
            imageView.centerX == view.centerX
            imageView.centerY == view.centerY
        }

        // TODO: Also make a call to switchgate here
        dependencyGraph.faveService.getCurrentUser { user, error in

            guard let user = user else {
                self.dependencyGraph.authenticator.logout { success in
                    print("Logged out")
                }

                self.isLoading = false

                return
            }

            self.dependencyGraph.storage.saveUser(user: user)

            if let tabBarItem = self.tabBarController?.tabBar.items?[3] {
                let tabBarItemImage = UIImage(base64String: user.profilePicture)?
                    .resize(targetSize: CGSize(width: 24, height: 24))?
                    .roundedImage?
                    .withRenderingMode(.alwaysOriginal)
                tabBarItem.image = tabBarItemImage
                tabBarItem.selectedImage = tabBarItemImage
            }

            self.isLoading = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isLoading = true
    }
}
