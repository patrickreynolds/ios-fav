import UIKit
import UserNotifications

class PushNotifications {
    struct Constants {
        static let hasSeenEnableNotificationsPrompt = "HasSeenEnableNotificationsPrompt"
    }

    static func updateNotificationPreferences(dependencyGraph: DependencyGraphType, enableNotifications: Bool) {
        let updatedPreferences = ["account_alert": enableNotifications]

        // Update notification preferences

//        dependencyGraph.settingsService.updateNotificationPreferences(preferences: updatedPreferences)
//            .onSuccess { _ in
//                dependencyGraph.analytics.logEvent(AnalyticsEvents.UpdateNotificationPreferencesSuccess)
//            }.onFailure { _ in
//                dependencyGraph.analytics.logError(AnalyticsEvents.UpdateNotificationPreferencesFailed)
//        }
    }

    static func promptForPushNotifications(dependencyGraph: DependencyGraphType, fromViewController: FaveVC, completion: (() -> Void)?) {
        let disableNotifications = {
            dependencyGraph.analytics.logEvent(title: AnalyticsEvents.pushPermissionDialogNo.rawValue)

            DispatchQueue.main.async {
                PushNotifications.updateNotificationPreferences(dependencyGraph: dependencyGraph, enableNotifications: false)
                completion?()
            }
        }

        let enableOSLevelNotifications = {
            dependencyGraph.analytics.logEvent(title: AnalyticsEvents.pushPermissionDialogYes.rawValue)

                // Present OS permission prompt
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { granted, _ in
                    dependencyGraph.analytics.logEvent(title: AnalyticsEvents.systemPushPermissionDialogShown.rawValue)

                    DispatchQueue.main.async {
                        PushNotifications.updateNotificationPreferences(dependencyGraph: dependencyGraph, enableNotifications: granted)
                    }

                    // Selected Yes in OS prompt
                    if granted {
                        dependencyGraph.analytics.logEvent(title: AnalyticsEvents.systemPushPermissionDialogYes.rawValue)
                        DispatchQueue.main.async(execute: {
                            UIApplication.shared.registerForRemoteNotifications()
                        })
                    } else {
                        dependencyGraph.analytics.logEvent(title: AnalyticsEvents.systemPushPermissionDialogNo.rawValue)
                    }

                    completion?()
                }
        }

        let userDefaults = UserDefaults.standard
        let hasSeenPrompt = userDefaults.bool(forKey: Constants.hasSeenEnableNotificationsPrompt)

        guard !hasSeenPrompt else {
            completion?()

            return
        }

        userDefaults.set(true, forKey: Constants.hasSeenEnableNotificationsPrompt)

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:

                DispatchQueue.main.async(execute: {
                    let contentView = DefaultDialogContentView(imageInfo: nil, title: "Never miss an update!", body: "Enable push notifications to receive important updates from Fave.", titleAlignment: .center)

                    let notNowAction = AlertVC.Action(title: "Not now",
                                                      type: .neutral,
                                                      didDismiss: disableNotifications)

                    let enableOSNotificationsAction = AlertVC.Action(title: "Yes, enable",
                                                                     type: .positive,
                                                                     didDismiss: enableOSLevelNotifications)

                    let enableNotificationsAlert = AlertVC(dependencyGraph: dependencyGraph,
                                                           contentView: contentView,
                                                           actions: [notNowAction, enableOSNotificationsAction])

                    dependencyGraph.analytics.logEvent(title: AnalyticsEvents.favePushPermissionDialogShown.rawValue)

                    fromViewController.present(enableNotificationsAlert, animated: true)
                })

            case .authorized:
                PushNotifications.updateNotificationPreferences(dependencyGraph: dependencyGraph, enableNotifications: true)

                completion?()
            case .denied, .provisional:
                completion?()
            @unknown default:
                completion?()

                dependencyGraph.analytics.logEvent(title: "UNUserNotificationError unknown auth status")
            }
        }
    }

    static func shouldPromptToRegisterForNotifications(dependencyGraph: DependencyGraphType, completion: @escaping (_ shouldPrompt: Bool) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let shouldPrompt = (settings.authorizationStatus == .notDetermined)
            completion(shouldPrompt)
        }
    }
}
