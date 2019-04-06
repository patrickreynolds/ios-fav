import UIKit
import Cartography
import MBProgressHUD

class FeedViewController: FaveVC {

    var lastPage: Int = 1

    var current = [FeedItem]()

    private lazy var createButton: UIButton = {
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

        view.addSubview(createButton)

        constrain(createButton, view) { button, view in
            button.right == view.right - 16
            button.bottom == view.bottomMargin - 16
            button.width == 56
            button.height == 56
        }

        view.bringSubviewToFront(createButton)

        checkLogin()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func checkLogin() {
        if dependencyGraph.authenticator.isLoggedIn() {
            refreshFeed()
        } else {
            login()
        }
    }

    func refreshFeed() {
        dependencyGraph.faveService.getFeed(from: 0, to: 100) { response, error in
            guard let feedData = response else {
                return
            }

            print("\(feedData.description)")
        }


//        dependencyGraph.faveService.getPaginatedFeed(page: lastPage) { response, error in
//            guard let feedData = response else {
//                return
//            }
//
//            print("\(feedData.description)")
//        }
    }
}

extension FeedViewController {
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
