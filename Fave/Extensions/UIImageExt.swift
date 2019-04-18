import Foundation
import UIKit

extension UIImage {
    convenience init?(base64String string: String) {
        if let url = URL(string: string) {
            do {
                let imageData = try Data(contentsOf: url)
                self.init(data: imageData)

                return
            } catch {
                print(error)
            }
        }

        return nil
    }
}
