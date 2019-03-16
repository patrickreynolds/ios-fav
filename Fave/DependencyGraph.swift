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

    init(analytics: Analytics = Analytics(),
         authenticator: Authenticator = Authenticator(),
         storage: TemporaryStorage = TemporaryStorage(appConfiguration: AppConfiguration()),
         networking: Networking = Networking(appConfiguration: AppConfiguration(), authenticator: Authenticator())) {
        self.analytics = analytics
        self.authenticator = authenticator
        self.storage = storage
        self.faveService = FaveService(networking: networking)
        self.analyticsService = AnalyticsService(networking: networking)
    }
}
