import Foundation

protocol DependencyGraphType {
    var analytics: Analytics { get }
    var authenticator: Authenticator { get }
    var storage: TemporaryStorage { get }
    var faveService: FaveService { get }
    var analyticsService: AnalyticsService { get }
}

struct DependencyGraph: DependencyGraphType {
    let analytics: Analytics
    let authenticator: Authenticator
    let storage: TemporaryStorage
    let faveService: FaveService
    let analyticsService: AnalyticsService

    init() {
        let appConfiguration = AppConfiguration()
        let storage = TemporaryStorage(appConfiguration: appConfiguration)
        let authenticator = Authenticator(storage: storage)
        let networking: Networking = Networking(appConfiguration: appConfiguration, authenticator: authenticator)

        self.analytics = Analytics()
        self.authenticator = authenticator
        self.storage = storage
        self.faveService = FaveService(networking: networking)
        self.analyticsService = AnalyticsService(networking: networking)
    }
}
