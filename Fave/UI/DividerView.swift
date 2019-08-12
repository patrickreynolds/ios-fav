import UIKit
import Cartography

class DividerView: UIView {
    init(backgroundColor: UIColor = FaveColors.Black20, height: CGFloat = 1.0) {
        super.init(frame: CGRect.zero)

        let divider = UIView(frame: .zero)
        divider.backgroundColor = backgroundColor

        addSubview(divider)

        constrainToSuperview(divider)

        constrain(divider) { divider in
            divider.height == height
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
