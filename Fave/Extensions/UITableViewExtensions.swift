import Foundation
import UIKit

extension UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        self.register(cellClass, forCellReuseIdentifier: NSStringFromClass(cellClass))
    }

    func dequeue<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        let cellClassAsString = NSStringFromClass(cellClass)
        guard let cell = dequeueReusableCell(withIdentifier: cellClassAsString, for: indexPath) as? T else {
            fatalError("Cell with identifier \(cellClassAsString) for \(indexPath) was not properly registered with the table view.")
        }
        return cell
    }
}

extension UITableView {
    func register<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) {
        self.register(viewClass, forHeaderFooterViewReuseIdentifier: NSStringFromClass(viewClass))
    }

    func dequeue<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        let viewClassAsString = NSStringFromClass(viewClass)
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: viewClassAsString) as? T else {
            fatalError("Header/Footer with identifier \(viewClassAsString) was not properly registered with the table view.")
        }
        return view
    }
}
