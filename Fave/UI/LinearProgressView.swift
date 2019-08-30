import UIKit

import Cartography

class LinearProgressView: UIView {

    // MARK: - Properties

    var trackColor: UIColor = FaveColors.Black20 {
        didSet {
            trackView.backgroundColor = trackColor
        }
    }

    var progressColor: UIColor = FaveColors.Accent {
        didSet {
            progressView.backgroundColor = progressColor
        }
    }

    var height: CGFloat = 4 {
        didSet {

        }
    }

    private var trackViewHeightConstraint: NSLayoutConstraint?
    private var progressWidthConstraint: NSLayoutConstraint?

    private var progressPercentage: Double = 0 {
        didSet {
            let viewWidth: CGFloat = trackView.frame.width
            let constraintPercentage = viewWidth * CGFloat(progressPercentage)

            progressWidthConstraint?.constant = constraintPercentage

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.2, options: .curveEaseInOut, animations: {
                self.layoutIfNeeded()
            }) { completion in }
        }
    }


    // MARK: - UI Properties

    private lazy var trackView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = trackColor
        view.layer.cornerRadius = height / 2
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        return view
    }()

    private lazy var progressView: UIView = {
        let view = UIView(frame: .zero)

        view.backgroundColor = progressColor
        view.layer.cornerRadius = height / 2
        view.layer.masksToBounds = true
        view.clipsToBounds = true

        return view
    }()


    // MARK: - Initializers

    init(height: Double = 4) {
        self.height = CGFloat(height)

        super.init(frame: .zero)

        addSubview(trackView)
        trackView.addSubview(progressView)

        constrainToSuperview(trackView)

        constrain(trackView) { trackView in
            trackViewHeightConstraint = trackView.height == CGFloat(self.height)
        }

        constrain(progressView, trackView) { progressView, trackView in
            progressView.top == trackView.top
            progressView.bottom == trackView.bottom
            progressView.left == trackView.left

            progressWidthConstraint = progressView.width == 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateProgress(progress: Double) {
        var shadowProgress = progress

        let progressFloor: Double = 0
        let progressCeiling: Double = 1

        if progress > progressCeiling {
            shadowProgress = 1
        } else if progress < progressFloor {
            shadowProgress = 0
        }

        progressPercentage = shadowProgress
    }
}
