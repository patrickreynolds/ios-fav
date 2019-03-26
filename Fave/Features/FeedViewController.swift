import UIKit
import Cartography
import MBProgressHUD

class FeedViewController: FaveVC {
    let progressHud = MBProgressHUD.init(frame: CGRect.zero)
    let welcomeLabel = Label.init(text: "Welcome to Fave!", font: FaveFont(style: .h3, weight: .semiBold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 0)
    let removeTokenButton = UIButton(frame: CGRect.zero)

    private lazy var newListButton: UIButton = {
        let button = UIButton(frame: .zero)

        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.setTitleColor(FaveColors.Accent, for: .normal)
        button.backgroundColor = FaveColors.Accent
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        button.tintColor = FaveColors.White

        return button
    }()

    init(dependencyGraph: DependencyGraphType) {
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .homescreenFeedTabScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        progressHud.animationType = .fade
        progressHud.contentColor = FaveColors.Accent

        removeTokenButton.setTitle("Logout", for: .normal)
        removeTokenButton.setTitleColor(FaveColors.Black90, for: .normal)
        removeTokenButton.backgroundColor = FaveColors.Black20
        removeTokenButton.layer.cornerRadius = 6
        removeTokenButton.addTarget(self, action: #selector(removeToken), for: .touchUpInside)

        view.addSubview(welcomeLabel)
        view.addSubview(progressHud)
        view.addSubview(removeTokenButton)
        view.addSubview(newListButton)

        constrain(welcomeLabel, view) { label, view in
            label.left == view.left + 16
            label.right == view.right - 16
            label.top == view.top + 160
            label.centerX == view.centerX
        }

        constrain(removeTokenButton, welcomeLabel) { button, label in
            button.top == label.bottom + 40
            button.centerX == label.centerX
        }

        constrain(progressHud, view) { hud, view in
            hud.centerX == view.centerX
            hud.centerY == view.centerY
        }

        constrain(newListButton, view) { button, view in
            button.right == view.right - 16
            button.bottom == view.bottomMargin - 16
            button.width == 56
            button.height == 56
        }

        view.bringSubviewToFront(newListButton)

        checkLogin()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func refreshData() {
        welcomeLabel.alpha = 0
        removeTokenButton.alpha = 0
        progressHud.show(animated: true)
        progressHud.hide(animated: true, afterDelay: 2.0)

        self.showTokenButton(true)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.welcomeLabel.alpha = 1
        }, completion: { completed in })
    }

    func showTokenButton(_ shouldShow: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.removeTokenButton.alpha = shouldShow ? 1.0 : 0
        }) { completed in

        }
    }

    @objc func removeToken(sender: UIButton!) {
        self.dependencyGraph.authenticator.logout { success in
            self.showTokenButton(false)
            self.checkLogin()
        }
    }

    private func checkLogin() {
        if dependencyGraph.authenticator.isLoggedIn() {
            refreshData()
        } else {
            login()
        }
    }

    @objc func createButtonTapped(sender: UIButton!) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Item", style: .default , handler: { alertAction in
            self.addItemButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "List", style: .default , handler: { alertAction in
            self.addListButtonTapped()

            alertController.dismiss(animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alertAction in
            alertController.dismiss(animated: true, completion: nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    func addListButtonTapped() {
        print("\n\nAdd List Button Tapped\n\n")

        let createListViewController = CreateListViewController.init(dependencyGraph: self.dependencyGraph)
        let createListNavigationViewController = UINavigationController(rootViewController: createListViewController)

        createListViewController.delegate = self

        present(createListNavigationViewController, animated: true, completion: nil)
    }

    func addItemButtonTapped() {
        print("\n\nAdd Item Button Tapped\n\n")

        let createItemViewController = CreateItemViewController(dependencyGraph: self.dependencyGraph)
        let createItemNavigationViewController = UINavigationController(rootViewController: createItemViewController)

        createItemViewController.delegate = self

        present(createItemNavigationViewController, animated: true, completion: nil)
    }
}

extension FeedViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {

    }
}

extension FeedViewController: CreateItemViewControllerDelegate {
    func didCreateItem() {

    }
}


