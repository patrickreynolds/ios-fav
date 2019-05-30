import Foundation

protocol DependencyGraphType {
    var appConfiguration: AppConfiguration { get }
    var analytics: Analytics { get }
    var authenticator: Authenticator { get }
    var storage: TemporaryStorage { get }
    var faveService: FaveServiceType { get }
    var analyticsService: AnalyticsService { get }
}

struct DependencyGraph: DependencyGraphType {
    let appConfiguration: AppConfiguration
    let analytics: Analytics
    let authenticator: Authenticator
    let storage: TemporaryStorage
    let faveService: FaveServiceType
    let analyticsService: AnalyticsService

    init() {
        let appConfiguration = AppConfiguration()
        let storage = TemporaryStorage(appConfiguration: appConfiguration)
        let authenticator = Authenticator(storage: storage)
        let networking: Networking = Networking(appConfiguration: appConfiguration, authenticator: authenticator)

        self.appConfiguration = appConfiguration
        self.analytics = Analytics()
        self.authenticator = authenticator
        self.storage = storage
        self.faveService = FaveGraphQLService(networking: networking)
        self.analyticsService = AnalyticsService(networking: networking)
    }
}
