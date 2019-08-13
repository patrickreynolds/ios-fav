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

// MARK: - Display Error Alert

//extension AlertVC {
//
//    //convenience helper for the ServiceError's .unknown case
//    static func displayError(_ error: NSError? = nil,
//                             responseObject: NSDictionary? = nil,
//                             headline: String? = nil,
//                             fromViewController: UIViewController,
//                             onDismiss: @escaping AlertVC.Action.DidDismissClosure = {}) {
//        if error?.code == NSURLErrorCancelled || error?.code == NSURLErrorNetworkConnectionLost {
//            return // Cancelled by us or see http://stackoverflow.com/a/25996971 for why we don't popup for -1005
//        }
//
//        let detail: String?
//
//        if error?.domain == NSURLErrorDomain {
//            detail = "There was a problem with your internet connection. Please try again."
//        } else if error?.domain == AffirmNetworkingErrorDomain {
//            detail = error?.localizedDescription
//        } else if let r = responseObject {
//            if let m = r.object(forKey: "message") as? String {
//                detail = m
//            } else if AppConfig.internalBuild() {
//                if let c = r.object(forKey: "code") as? String {
//                    detail = c
//                } else {
//                    detail = r.description
//                }
//            } else {
//                detail = nil
//            }
//        } else if let decodingError = error as? DecodingError, AppConfig.internalBuild() {
//            let decodingDetails: String
//            switch decodingError {
//            case .dataCorrupted(let context):
//                decodingDetails = context.debugDescription
//            case .keyNotFound(_, let context):
//                decodingDetails = "\(context.debugDescription) \n\n \(context.codingPath)"
//            case .typeMismatch(_, let context):
//                decodingDetails = "\(context.debugDescription) \n\n \(context.codingPath)"
//            case .valueNotFound(let type, let context):
//                decodingDetails = "no value was found for \(type) \n\n \(context.debugDescription)"
//            @unknown default:
//                decodingDetails = "New Unknown Kind Of Decoding Error"
//            }
//            detail = "Problem decoding JSON:\n\n \(decodingDetails) \n\n"
//        } else if let response = error?.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse, let failedURL = error?.userInfo["NSErrorFailingURLKey"], AppConfig.internalBuild() && !AppConfig.fixturesEnabled() {
//            detail = "\(response.statusCode) received for \(failedURL)"
//        } else {
//            detail = nil
//        }
//
//        let alertVC = AlertVC(title: headline, body: detail, type: .errorDialog, onDismiss: onDismiss)
//        fromViewController.present(alertVC, animated: true)
//    }
//
//    //convenience helper for the ServiceError's .known case
//    static func displayError(_ httpError: HTTPError,
//                             headline: String? = nil,
//                             suppressCode: Bool = false,
//                             fromViewController: UIViewController,
//                             onDismiss: @escaping AlertVC.Action.DidDismissClosure = {}) {
//
//        let body: String
//        if AppConfig.internalBuild(), let code = httpError.code, !suppressCode {
//            body = "\(httpError.message)\n\(code)"
//        } else {
//            body = httpError.message
//        }
//
//        let alertVC = AlertVC(title: headline, body: body, type: .errorDialog, onDismiss: onDismiss)
//        fromViewController.present(alertVC, animated: true)
//    }
//
//    static func displayError(serviceError: ServiceError,
//                             title: String = "Error",
//                             responseObject: NSDictionary? = nil,
//                             fromViewController: UIViewController,
//                             onDismiss: @escaping AlertVC.Action.DidDismissClosure = {}) {
//        switch serviceError {
//        case .known(let error):
//            AlertVC.displayError(error, headline: title, fromViewController: fromViewController, onDismiss: onDismiss)
//        case .unknown(let error):
//            AlertVC.displayError(error as NSError?, responseObject: responseObject, headline: title, fromViewController: fromViewController, onDismiss: onDismiss)
//        }
//    }
//
//    /// This function only exists as a temporary workaround for the Objective-C code in AFRNetwork to be able to create
//    /// an error alert.
//    @objc static func displayErrorAlert(headline: String,
//                                        detail: String? = nil) {
//        let alertVC = AlertVC(title: headline, body: detail, type: .errorDialog)
//        UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true)
//    }
//}
