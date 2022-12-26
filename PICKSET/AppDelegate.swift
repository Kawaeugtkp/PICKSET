//
//  AppDelegate.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/07.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import IQKeyboardManagerSwift
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        // Override point for customization after application launch.
//        if #available(iOS 15.0, *) {
//            // disable UINavigation bar transparent
//            let navigationBarAppearance = UINavigationBarAppearance()
//            navigationBarAppearance.configureWithDefaultBackground()
//            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
//            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
//            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
//        }
//        if #available(iOS 15.0, *) {
//            // disable UITab bar transparent
//            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
//            tabBarAppearance.configureWithDefaultBackground()
//            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//            UITabBar.appearance().standardAppearance = tabBarAppearance
//        } この上のいろいろなコメントアウト部分ない方が良い説出てる今
        
//        let backButtonBackgroundImage = UIImage(systemName: "arrow.backward")
//        let barAppearance =
//            UINavigationBar.appearance(whenContainedInInstancesOf: [LikeUsersController.self])
//        barAppearance.backIndicatorImage = backButtonBackgroundImage
//        barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
//
//        // Nudge the back UIBarButtonItem image down a bit.
//        let barButtonAppearance =
//            UIBarButtonItem.appearance(whenContainedInInstancesOf: [LikeUsersController.self])
//        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -5), for: .default)
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.enable = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PICKSET")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

//extension AppDelegate: UINavigationControllerDelegate {
//    // MARK: - UINavigationControllerDelegate
//    
//    /** Force the navigation controller to defer to the topViewController for its supportedInterfaceOrientations.
//        This allows some of the demos to rotate into landscape while keeping the rest in portrait.
//    */
//    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
//        return navigationController.topViewController!.supportedInterfaceOrientations
//    }
//}
