import UIKit

import Cartography

protocol FaveLoggedOutWelcomeViewDelegate {
    func didSelectUser(user: User)
    func didSelectList(list: List)
    func didSelectItem(item: Item, list: List)
    func didSelectSignUp()
}

class FaveLoggedOutWelcomeView: UIView {

    enum ScrollDirection {
        case Left
        case Right
    }

    private var dependencyGraph: DependencyGraphType?

    var delegate: FaveLoggedOutWelcomeViewDelegate?

    private var previousView: UIView?

    private var topLists: [List] = [] {
        didSet {
            scrollView.subviews.forEach { view in
                view.removeFromSuperview()
            }

            lists = []
            var existingAuthors: [Int:Int] = [:]

            for index in 0..<topLists.count {
                let list = topLists[index]

                let view = TopListView(list: list)

                view.delegate = self

                if let _ = existingAuthors[list.owner.id] {

                } else {
                    existingAuthors[list.owner.id] = 1
                    lists.append(view)
                }
            }

            setOffsets(count: lists.count)

            let scrollViewContentWidth = CGFloat(Float(UIScreen.main.bounds.width - 64) * Float(lists.count) + (Float(lists.count) * 16) + 48)

            scrollView.contentSize = CGSize(width: scrollViewContentWidth, height: 300)
            scrollView.isPagingEnabled = false

            previousView = nil

            for i in 0 ..< self.lists.count {
                let view = self.lists[i]

                self.scrollView.addSubview(view)

                if let prevView = previousView {
                    // Not first view

                    constrain(view, prevView, scrollView) { view, prevView, scrollView in
                        view.left == prevView.right + 16
                        view.top == scrollView.top + 16
                        view.bottom == scrollView.bottom - 16
                        view.centerY == scrollView.centerY
                    }
                } else {
                    // First view

                    constrain(view, scrollView) { view, scrollView in
                        view.left == scrollView.left + 32
                        view.top == scrollView.top + 16
                        view.bottom == scrollView.bottom - 16
                        view.centerY == scrollView.centerY
                    }
                }

                if view == self.lists.last {
                    constrain(view, scrollView) { view, scrollView in
                        view.right == scrollView.right - 32
                    }
                }

                previousView = view
            }
        }
    }

    private var lists: [UIView] = []

    private var history: [CGPoint] = [] {
        didSet {
            guard history.count > 1 else {
                return
            }

            guard let last = history.last, let secondToLast = history.dropLast().last else {
                return
            }

            if last.x > secondToLast.x {
                lastScrollDirection = .Left
            } else {
                lastScrollDirection = .Right
            }
        }
    }

    private var lastScrollDirection: ScrollDirection = .Left

    private var offsets: [Float] = []

    private lazy var titleLabel: Label = {
        let label = Label(text: "Welcome to Fave!",
                               font: FaveFont(style: .h4, weight: .extraBold),
                               textColor: FaveColors.Black90,
                               textAlignment: .center,
                               numberOfLines: 0)

        return label
    }()

    private lazy var subtitleLabel: Label = {
        let label = Label(text: "Create collections, share recommendations, and discover places with friends.",
                                  font: FaveFont(style: .h5, weight: .regular),
                                  textColor: FaveColors.Black70,
                                  textAlignment: .center,
                                  numberOfLines: 0)

        return label
    }()

    private lazy var signUpWithFacebookLabel: Label = {
        let label = Label(text: "Continue with Facebook",
                          font: FaveFont(style: .h5, weight: .bold),
                          textColor: FaveColors.FacebookBlue,
                          textAlignment: .center,
                          numberOfLines: 0)

        _ = label.tapped { recognizer in
            self.delegate?.didSelectSignUp()
        }

        label.isUserInteractionEnabled = true

        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)

        scrollView.backgroundColor = FaveColors.White
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true

        return scrollView
    }()

    init() {
        super.init(frame: CGRect.zero)

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(scrollView)
        addSubview(signUpWithFacebookLabel)

        constrain(titleLabel, self) { titleLabel, view in
            titleLabel.top == view.top + 32
            titleLabel.centerX == view.centerX
        }

        constrain(subtitleLabel, titleLabel, self) { subtitleLabel, titleLabel, view in
            subtitleLabel.top == titleLabel.bottom + 8
            subtitleLabel.left == view.left + 32
            subtitleLabel.right == view.right - 32
        }

        constrain(scrollView, subtitleLabel, self) { collectionView, subtitleLabel, view in
            collectionView.top == subtitleLabel.bottom + 16

            collectionView.left == view.left
            collectionView.right == view.right

            let height = UIScreen.main.bounds.width

            collectionView.height == height + 16
        }

        constrain(signUpWithFacebookLabel, scrollView, self) { signUpWithFacebookLabel, scrollView, view in
            signUpWithFacebookLabel.centerX == view.centerX
            signUpWithFacebookLabel.top == scrollView.bottom + 16
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withTopLists lists: [List], dependencyGraph: DependencyGraphType) {
        self.topLists = lists
        self.dependencyGraph = dependencyGraph
    }

    private func closestOffsetForPointInDirection(point: CGPoint, direction: ScrollDirection) -> CGPoint {

        if direction == .Left {
            for offsetPoint in offsets {
                if offsetPoint > Float(point.x) {
                    return CGPoint.init(x: Int(offsetPoint), y: 0)
                }
            }

            if let lastOffset = offsets.last {
                return CGPoint.init(x: Int(lastOffset), y: 0)
            } else {
                return CGPoint.init(x: 0, y: 0)
            }
        } else {
            for offsetPoint in offsets.reversed() {
                if offsetPoint < Float(point.x) {
                    return CGPoint.init(x: Int(offsetPoint), y: 0)
                }
            }

            if let firstOffset = offsets.first {
                return CGPoint.init(x: Int(firstOffset), y: 0)
            } else {
                return CGPoint.init(x: 0, y: 0)
            }
        }
    }

    private func setOffsets(count: Int) {
        offsets = []

        let width = UIScreen.main.bounds.width
        let initialOffset: Float = 32
        let padding: Float = 16

        for index in 0..<count {
            if index == 0 {
                offsets.append(0)
            } else if index == 1 {
                let pageOffset = initialOffset + padding
                let pageWidth = Float(width) * Float(index)

                let offset: Float = pageWidth - pageOffset

                offsets.append(offset)
            } else {
                if let last = offsets.last {
                    let offset = Float(last) + Float(width) - Float(Float(initialOffset + Float(padding)))

                    offsets.append(offset)
                } else {
                    offsets.append(0)
                }
            }
        }
    }
}

extension FaveLoggedOutWelcomeView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var currentHistory = history
        currentHistory.append(scrollView.contentOffset)
        history = currentHistory
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if lastScrollDirection == .Left {
//            print("\nLeft\n")
//
//            let offset = closestOffsetForPointInDirection(point: scrollView.contentOffset, direction: .Left)
//            print("Offset: \(offset)")
//
//            DispatchQueue.main.async {
//                scrollView.setContentOffset(offset, animated: true)
//            }
//        } else {
//            print("\nRight\n")
//
//            let offset = closestOffsetForPointInDirection(point: scrollView.contentOffset, direction: .Right)
//            print("Offset: \(offset)")
//
//            DispatchQueue.main.async {
//                scrollView.setContentOffset(offset, animated: true)
//            }
//        }
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        if lastScrollDirection == .Left {
//            print("\nLeft\n")
//
//            let offset = closestOffsetForPointInDirection(point: scrollView.contentOffset, direction: .Left)
//            print("Offset: \(offset)")
//
//            DispatchQueue.main.async {
//                scrollView.setContentOffset(offset, animated: true)
//            }
//        } else {
//            print("\nRight\n")
//
//            let offset = closestOffsetForPointInDirection(point: scrollView.contentOffset, direction: .Right)
//            print("Offset: \(offset)")
//
//            DispatchQueue.main.async {
//                scrollView.setContentOffset(offset, animated: true)
//            }
//        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("DID END DECELERATING")
    }
}

extension FaveLoggedOutWelcomeView: TopListViewDelegate {
    func didSelectUser(user: User) {
        delegate?.didSelectUser(user: user)
    }

    func didSelectList(list: List) {
        delegate?.didSelectList(list: list)
    }

    func didSelectItem(item: Item, list: List) {
        delegate?.didSelectItem(item: item, list: list)
    }
}
