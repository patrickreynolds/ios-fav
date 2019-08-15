import UIKit
import UserNotifications

import FacebookCore
import FacebookLogin

import FBSDKCoreKit
import FBSDKLoginKit

import GooglePlaces

import Fabric
import Crashlytics

enum FaveUITabBarTabs: Int {
    case FeedTab
    case DiscoverTab
    case RecommendationsTab
    case ProfileTab
}

enum FaveNotificationType: String {
    case RecommendationGeneral = "recommendation-general"
    case ListNewRecommendation = "list-new-recommendation"
    case ListNewFollower = "list-new-follower"
    case NotificationsClear = "notifications-clear"

    init?(type: String) {
        switch type {
        case FaveNotificationType.RecommendationGeneral.rawValue: self = FaveNotificationType.RecommendationGeneral
        case FaveNotificationType.ListNewRecommendation.rawValue: self = FaveNotificationType.ListNewRecommendation
        case FaveNotificationType.ListNewFollower.rawValue: self = FaveNotificationType.ListNewFollower
        case FaveNotificationType.NotificationsClear.rawValue: self = FaveNotificationType.NotificationsClear
        default: return nil
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dependencyGraph = DependencyGraph()
    let tabBarController = UITabBarController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        /*
            Crashlytics & Fabric.io
            https://fabric.io/kits/ios/crashlytics/install
         */
        Fabric.with([Crashlytics.self])


        /*
            Facebook authentication call from these docs:
            https://developers.facebook.com/docs/swift/getting-started/#cocoapods
            This initializes the SDK when your app launches, and lets the SDK handle results from the native Facebook app when you perform a Login or Share action.
        */
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        /*
         Step 4: Add the API key to your application
         https://developers.google.com/places/ios-sdk/start
        */
        GMSPlacesClient.provideAPIKey(dependencyGraph.appConfiguration.googleAPIKey)


        // Setup main tab bar
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: FaveColors.Black100,
             NSAttributedString.Key.font: FaveFontStyle.h5.withWeight(.regular)]

        UIBarButtonItem.appearance().tintColor = FaveColors.Black90
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: FaveFontStyle.h5.withWeight(.bold)], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: FaveFontStyle.h5.withWeight(.bold)], for: .highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: FaveFontStyle.h5.withWeight(.bold)], for: .disabled)


        // Create View Controllers
        let feedViewController = FeedViewController(dependencyGraph: dependencyGraph)
        let feedNavigationViewController = UINavigationController(rootViewController: feedViewController)

        let discoverViewController = DiscoverViewController(dependencyGraph: dependencyGraph)
        let discoverNavigationViewController = UINavigationController(rootViewController: discoverViewController)

        let recommendationsViewController = RecommendationsViewController(dependencyGraph: dependencyGraph)
        let recommendationsNavigationViewController = UINavigationController(rootViewController: recommendationsViewController)

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: nil)
        let profileNavigationViewController = UINavigationController(rootViewController: profileViewController)


        // Add tabs
        tabBarController.viewControllers = [feedNavigationViewController, discoverNavigationViewController, recommendationsNavigationViewController, profileNavigationViewController]

        if let tabBarItem = tabBarController.tabBar.items?[0] {
            tabBarItem.image = UIImage(named: "tab-icon-home")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-home-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }

        if let tabBarItem = tabBarController.tabBar.items?[1] {
            tabBarItem.image = UIImage(named: "tab-icon-search")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-search-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }

        if let tabBarItem = tabBarController.tabBar.items?[2] {
            tabBarItem.image = UIImage(named: "tab-icon-recommendations")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-recommendations-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }

        if let tabBarItem = tabBarController.tabBar.items?[3] {
            tabBarItem.image = UIImage(named: "tab-icon-profile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-profile-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }


        // Assign and set root
        let rootViewController = tabBarController
        window?.rootViewController = rootViewController
        window?.backgroundColor = FaveColors.Accent

        window?.makeKeyAndVisible()

        let splashScreenViewController = SplashScreenViewController(dependencyGraph: dependencyGraph)
        splashScreenViewController.modalPresentationStyle = .overFullScreen
        tabBarController.present(splashScreenViewController, animated: false, completion: nil)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.


        /*
         Source: https://developers.facebook.com/docs/swift/appevents
         Description: Logging app activations as an app event enables most other functionality and should be the first thing that you add to your app. The SDK provides a helper method to log app activation. By logging an activation event, you can observe how frequently users activate your app, how much time they spend using it, and view other demographic information through Facebook Analytics.
        */
        AppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Facebook Delegate Methods

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        /*
         Facebook authentication call from these docs:
         https://developers.facebook.com/docs/swift/getting-started/#cocoapods
         This initializes the SDK when your app launches, and lets the SDK handle results from the native Facebook app when you perform a Login or Share action.
         */

        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }

    // MARK: Push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
//        print("APNs device token: \(deviceTokenString)")

        // POST device token
        dependencyGraph.faveService.addDeviceToken(deviceToken: deviceTokenString) { success, error in
            guard let success = success else {
                return
            }

            if success {
                print("\n\nAPNS device token saved: true\n\n")
            } else {
                print("\n\nAPNS device token saved: false\n\n")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 1
        let userInfo = response.notification.request.content.userInfo

        // 2
        if let userInfo = userInfo as? [String: AnyObject] {
            print("\(userInfo)")
        }

        // 4
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == UIApplication.State.active {

            if let userInfo = userInfo as? [String: AnyObject] {
                print("\(userInfo)")
            }

        } else if application.applicationState == UIApplication.State.background {

            if let userInfo = userInfo as? [String: AnyObject] {

                print("\(userInfo)")
            }

        } else if application.applicationState == UIApplication.State.inactive {

            if let userInfo = userInfo as? [String: AnyObject] {

                handleNotification(userInfo: userInfo)

                print("\(userInfo)")
            }
        }
    }

    func handleNotification(userInfo: [String: AnyObject]) {
        guard let notificationTypeString = userInfo["notification-type"] as? String, let notificationType = FaveNotificationType.init(rawValue: notificationTypeString) else {
            return
        }

        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            return
        }

        switch notificationType {
        case .RecommendationGeneral:
            tabBarController.selectedIndex = FaveUITabBarTabs.RecommendationsTab.rawValue

            return
        case .ListNewRecommendation:

            return

            guard let profileViewController = tabBarController.viewControllers?[FaveUITabBarTabs.ProfileTab.rawValue] as? ProfileViewController else {
                return
            }

            guard let listId = userInfo["listId"] as? Int else {
                return
            }

            handleNavigateToList(profileViewController: profileViewController, listId: listId)

        case .ListNewFollower:

            return

            guard let profileViewController = tabBarController.viewControllers?[FaveUITabBarTabs.ProfileTab.rawValue] as? ProfileViewController else {
                return
            }

            guard let listId = userInfo["listId"] as? Int else {
                return
            }

            handleNavigateToList(profileViewController: profileViewController, listId: listId)

            return
        case .NotificationsClear:

            return
        }
    }

    func handleNavigateToList(profileViewController: ProfileViewController, listId: Int) {
        dependencyGraph.faveService.getList(listId: listId) { list, error in
            guard let list = list else {
                return
            }

            let listViewController = ListViewController(dependencyGraph: self.dependencyGraph, list: list)

            listViewController.delegate = profileViewController

            let titleViewLabel = Label(text: "List", font: FaveFont(style: .h5, weight: .bold), textColor: FaveColors.Black90, textAlignment: .center, numberOfLines: 1)
            listViewController.navigationItem.titleView = titleViewLabel

            profileViewController.navigationController?.pushViewController(listViewController, animated: true)
        }
    }
}
