import Foundation
import UIKit

import FacebookCore
import FacebookLogin

import FBSDKCoreKit
import FBSDKLoginKit

import GooglePlaces

import Fabric
import Crashlytics

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

//        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
//        Crashlytics.sharedInstance().setUserIdentifier("12345")
//        Crashlytics.sharedInstance().setUserName("Test User")


        /*
            Facebook authentication call from these docs:
            https://developers.facebook.com/docs/swift/getting-started/#cocoapods
            This initializes the SDK when your app launches, and lets the SDK handle results from the native Facebook app when you perform a Login or Share action.
        */
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        /*
         Step 4: Add the API key to your application
         https://developers.google.com/places/ios-sdk/start
        */
        GMSPlacesClient.provideAPIKey("AIzaSyDwGmB--Y1D3D4CllP2L0QXmx2WPtrvHgc")


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
//        feedViewController.title = "Home".uppercased()
        let feedNavigationViewController = UINavigationController(rootViewController: feedViewController)

        let discoverViewController = DiscoverViewController(dependencyGraph: dependencyGraph)
//        discoverViewController.title = "Discover".uppercased()
        let discoverNavigationViewController = UINavigationController(rootViewController: discoverViewController)

        let profileViewController = ProfileViewController(dependencyGraph: dependencyGraph, user: dependencyGraph.storage.getUser())
        let profileNavigationViewController = UINavigationController(rootViewController: profileViewController)
//        profileViewController.title = "Profile".uppercased()


        // Add tabs
        tabBarController.viewControllers = [feedNavigationViewController, discoverNavigationViewController, profileNavigationViewController]

        if let tabBarItem = tabBarController.tabBar.items?[0] {
            tabBarItem.image = UIImage(named: "tab-icon-home")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-home-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }

        if let tabBarItem = tabBarController.tabBar.items?[1] {
            tabBarItem.image = UIImage(named: "tab-icon-search")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-search-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }

        if let tabBarItem = tabBarController.tabBar.items?[2] {
            tabBarItem.image = UIImage(named: "tab-icon-profile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            tabBarItem.selectedImage = UIImage(named: "tab-icon-profile-selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }


        // Assign and set root
        let rootViewController = tabBarController
        window?.rootViewController = rootViewController

        window?.makeKeyAndVisible()

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
        AppEventsLogger.activate(application)
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
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
}
