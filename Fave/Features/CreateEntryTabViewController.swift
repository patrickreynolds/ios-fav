import Foundation
import UIKit

import Cartography
import MBProgressHUD

class CreateEntryTabViewController: FaveVC {
    init(dependencyGraph: DependencyGraphType) {

        super.init(dependencyGraph: dependencyGraph, analyticsImpressionEvent: .createEntryTabScreenShown)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tempTitle = Label.init(
            text: "Create Entry Screen",
            font: FaveFont.init(style: .h2, weight: .bold),
            textColor: FaveColors.Black90,
            textAlignment: .center,
            numberOfLines: 0)

        view.addSubview(tempTitle)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor = UIColor.white
    }
}
