import Foundation
import UIKit

import Cartography
import MBProgressHUD

class DiscoverViewController: FaveVC {

    var suggestions: [List] = [] {
        didSet {
            // reload data
        }
    }

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
        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .discoverScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FaveColors.White

        let titleViewLabel = Label.init(text: "Discover", font: FaveFont.init(style: .h5, weight: .semiBold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
        navigationItem.titleView = titleViewLabel

        view.addSubview(createButton)

        constrain(createButton, view) { button, view in
            button.right == view.right - 16
            button.bottom == view.bottomMargin - 16
            button.width == 56
            button.height == 56
        }

        view.bringSubviewToFront(createButton)

        refreshSuggestions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor = UIColor.white

        refreshSuggestions()
    }

    func refreshSuggestions() {
        dependencyGraph.faveService.suggestions { response, error in
            guard let suggestions = response else {
                // handle error

                return
            }

             self.suggestions = suggestions
        }
    }
}

extension DiscoverViewController {
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

extension DiscoverViewController: CreateListViewControllerDelegate {
    func didCreateList(list: List) {

    }
}

extension DiscoverViewController: CreateItemViewControllerDelegate {
    func didCreateItem() {

    }
}


