import UIKit

func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension UIApplication {
    @objc var appDelegate: AppDelegate {
        guard let d = delegate as? AppDelegate else {
            fatalError("App delegate not found. Did you change the name of the class?")
        }

        return d
    }
}

protocol VersionManager {}

extension VersionManager {
    func shouldForceUpgrade(version remoteVersion: String) -> Bool {
        let currentVersion = UIApplication.shared.appDelegate.dependencyGraph.appConfiguration.currentVersion

        return currentVersion.isVersion(lessThan: remoteVersion)
    }
}
