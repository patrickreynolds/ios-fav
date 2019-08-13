import UIKit

protocol ReuseableCollectionViewCellType {
    static func defaultReuseIdentifier() -> String
}

extension UICollectionViewCell: ReuseableCollectionViewCellType {
    @objc class func defaultReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        self.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
    }

    func dequeue<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        let cellClassAsString = NSStringFromClass(cellClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellClassAsString, for: indexPath) as? T else {
            fatalError("Cell with identifier \(cellClassAsString) for \(indexPath) was not properly registered with the table view.")
        }
        return cell
    }
}
