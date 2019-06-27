import UIKit

import Cartography

protocol ListSegmentedControlDelegate {
    func didSelectItemAtIndex(index: Int)
}

struct ListSegmentedControlTab {
    var title: String
    let index: Int
    var selected: Bool
}

protocol ListSegmentedControlTabViewDelegate {
    func didSelectTab(tab: ListSegmentedControlTab)
}

class ListSegmentedControlTabView: UIView {

    var delegate: ListSegmentedControlTabViewDelegate?

    var tab: ListSegmentedControlTab {
        didSet {
            updateUI()
        }
    }

    private lazy var title: Label = {
        let label = Label.init(text: tab.title, font: FaveFont.init(style: .h5, weight: .semiBold), textColor: tab.selected ? FaveColors.Accent : FaveColors.Black70, textAlignment: .center
            , numberOfLines: 1)

        return label
    }()

    init(tab: ListSegmentedControlTab) {
        self.tab = tab

        super.init(frame: .zero)

        addSubview(title)

        clipsToBounds = true
        layer.masksToBounds = true

        constrain(title, self) { titleLabel, view in
            titleLabel.centerX == view.centerX
            titleLabel.centerY == view.centerY
        }

        _ = tapped { _ in
            self.delegate?.didSelectTab(tab: self.tab)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.title.text = self.tab.title
            self.title.textColor = self.tab.selected ? FaveColors.Accent : FaveColors.Black70
        }, completion: nil)
    }
}

class ListSegmentedControl: UIView {

    var delegate: ListSegmentedControlDelegate?

    var selectedBorderViewLeftMarginConstraint: NSLayoutConstraint?

    var tabModels: [ListSegmentedControlTab] {
        didSet {
            tabViews.enumerated().forEach { index, view in
                view.tab = tabModels[index]
            }
        }
    }

    let tabViews: [ListSegmentedControlTabView]

    lazy private var topDividerView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 1
        }

        return view
    }()

    lazy private var bottomDividerView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Black20

        constrain(view) { view in
            view.height == 1
        }

        return view
    }()

    private lazy var selectedBorderView: UIView = {
        let view = UIView.init(frame: .zero)

        view.backgroundColor = FaveColors.Accent

        constrain(view) { view in
            view.height == 2
        }

        return view
    }()

    init(tabs: [String]) {
        self.tabModels = tabs.enumerated().map { index, tab in
            return ListSegmentedControlTab.init(title: tab, index: index, selected: index == 0)
        }

        self.tabViews = tabModels.enumerated().map { index, tab in
            return ListSegmentedControlTabView.init(tab: tab)
        }

        super.init(frame: CGRect.zero)

        backgroundColor = FaveColors.White

        self.tabViews.forEach { tabView in
            tabView.delegate = self
        }

        let tabsStackView = UIStackView.init(frame: .zero)

        self.tabViews.forEach { view in
            tabsStackView.addArrangedSubview(view)
        }

        tabsStackView.axis = .horizontal
        tabsStackView.distribution = .fillEqually

        addSubview(topDividerView)
        addSubview(tabsStackView)
        addSubview(selectedBorderView)
        addSubview(bottomDividerView)

        constrainToSuperview(topDividerView, exceptEdges: [.bottom])
        constrainToSuperview(tabsStackView, exceptEdges: [.top, .bottom])
        constrainToSuperview(bottomDividerView, exceptEdges: [.top])

        constrain(topDividerView, bottomDividerView, selectedBorderView, tabsStackView) { topDividerView, bottomDividerView, selectedBorderView, stackView in
            topDividerView.bottom == stackView.top
            selectedBorderView.top == stackView.bottom
            bottomDividerView.top == selectedBorderView.bottom
        }

        let width = (UIScreen.main.bounds.width / CGFloat(tabViews.count))
        let offset = 0 * width
        constrain(selectedBorderView, self) { selectedBorderView, view in
            selectedBorderViewLeftMarginConstraint = selectedBorderView.left == view.left + offset
            selectedBorderView.width == width
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTitleAtIndex(title: String, index: Int) {
        if index >= 0 && index < tabModels.count {
            var tab = tabModels[index]

            tab.title = title

            tabViews[index].tab = tab
        }
    }

    func didSelectItemAtIndex(tab: ListSegmentedControlTab) {
        delegate?.didSelectItemAtIndex(index: tab.index)

        tabModels = tabModels.enumerated().map { tabIndex, tabModel in
            return ListSegmentedControlTab.init(title: tabModel.title, index: tabIndex, selected: tabIndex == tab.index)
        }

        let selectedOffset = CGFloat(tab.index) * (UIScreen.main.bounds.width / CGFloat(tabViews.count))
        self.selectedBorderViewLeftMarginConstraint?.constant = selectedOffset

        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ListSegmentedControl: ListSegmentedControlTabViewDelegate {
    func didSelectTab(tab: ListSegmentedControlTab) {
        didSelectItemAtIndex(tab: tab)
    }
}
