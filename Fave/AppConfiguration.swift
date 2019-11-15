import Foundation

protocol AppConfigType {
    var baseUrl: String { get }
}

struct AppConfiguration: AppConfigType {
    let baseUrl: String
    let googleAPIKey: String
    let production: Bool
    let currentVersion: String

    init() {
        self.baseUrl = Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String
        self.googleAPIKey = Bundle.main.infoDictionary!["GOOGLE_API_KEY"] as! String

        let productionString = Bundle.main.infoDictionary!["PRODUCTION"] as! String
        self.production = productionString == "YES" ? true : false

        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        self.currentVersion = version
    }
}
