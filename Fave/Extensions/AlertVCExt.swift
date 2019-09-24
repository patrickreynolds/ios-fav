// MARK: - Common Alerts

extension AlertVC {
    convenience init(dependencyGraph: DependencyGraphType,
                     analyticsImpressionEvent: AnalyticsImpressionEvent = .alertShown,
                     imageInfo: ImageInfo? = nil,
                     title: String? = nil,
                     body: String? = nil,
                     actions: [Action]) {

        let contentView = DefaultDialogContentView(imageInfo: imageInfo, title: title, body: body)

        self.init(dependencyGraph: dependencyGraph,
                  analyticsImpressionEvent: analyticsImpressionEvent,
                  contentView: contentView,
                  actions: actions)
    }
}
