import Foundation

protocol AppConfigType {
    var baseUrl: String { get }
}

struct AppConfiguration: AppConfigType {
    let baseUrl: String

    init() {
        self.baseUrl = ProcessInfo().environment["BASE_URL"] ?? ""
    }
}
