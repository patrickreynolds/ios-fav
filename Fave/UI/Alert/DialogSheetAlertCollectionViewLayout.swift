import UIKit

class DialogAlertCollectionViewLayout: UICollectionViewLayout {
    // MARK: - Structs

    private struct LayoutInfo {
        let yOrigin: CGFloat
        let height: CGFloat
    }

    // MARK: - Properties

    private let sectionInset: UIEdgeInsets
    private let layoutInfoForActions: [LayoutInfo]
    private let height: CGFloat

    // MARK: - Initializers

    init(actions: [AlertVC.Action]) {
        sectionInset = UIEdgeInsets(top: 32,
                                    left: 24,
                                    bottom: 24,
                                    right: 24)

        var currentYOffset = sectionInset.top
        layoutInfoForActions = actions.enumerated().map { (index, action) in
            let height = CGFloat(action.type == .neutral ? 40 : 56)

            currentYOffset += CGFloat(index == 0 ? 0 : 16)

            let layoutInfo = LayoutInfo(yOrigin: currentYOffset, height: height)

            currentYOffset += height

            return layoutInfo
        }
        height = currentYOffset + sectionInset.bottom

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UICollectionViewLayout Methods

    override var collectionViewContentSize: CGSize {
        var collectionViewContentSize = super.collectionViewContentSize

        collectionViewContentSize.height = height

        return collectionViewContentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // NOTE: This can obviously be improved because it creates the layout attributes for all actions. Currently all actions are visible so it does not pose a problem but in the future if things become scrollable we should update this.
        let layoutAttributes = layoutInfoForActions.enumerated().map { (index, layoutInfo) -> UICollectionViewLayoutAttributes in
            let indexPath = IndexPath(row: index, section: 0)
            return createLayoutAttributesForItem(atIndexPath: indexPath, layoutInfo: layoutInfo)
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutInfo = layoutInfoForActions[indexPath.row]
        return createLayoutAttributesForItem(atIndexPath: indexPath, layoutInfo: layoutInfo)
    }

    // MARK: - Private Methods

    private func createLayoutAttributesForItem(atIndexPath indexPath: IndexPath, layoutInfo: LayoutInfo) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        var frame = layoutAttributes.frame

        frame.origin.x = sectionInset.left
        frame.origin.y = layoutInfo.yOrigin
        frame.size.height = layoutInfo.height

        if let collectionView = collectionView {
            frame.size.width = collectionView.bounds.width - sectionInset.left - sectionInset.right
        }

        layoutAttributes.frame = pixelAlign(frame: frame)

        return layoutAttributes
    }

    private func pixelAlign(frame: CGRect) -> CGRect {
        let scale = UIScreen.main.scale
        return CGRect(x: floor(frame.origin.x * scale) / scale,
                      y: floor(frame.origin.y * scale) / scale,
                      width: ceil(frame.size.width * scale) / scale,
                      height: ceil(frame.size.height * scale) / scale)
    }
}
