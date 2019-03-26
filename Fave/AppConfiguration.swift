import Foundation

protocol AppConfigType {
    var baseUrl: String { get }
}

struct AppConfiguration: AppConfigType {
    let baseUrl: String

    init() {
        self.baseUrl = Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String

        print("BASE URL: \(self.baseUrl)")
    }
}
