//
//  AppDelegate.swift
//  FoodViewer
//
//  Created by arnaud on 30/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // let pageViewController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UIPageViewController
        // pageViewController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        
        // sometimes the AppDelegate must act as splitViewController delegate
        // only if the first and second viewcontrollers are a splitViewVC
        guard let tabBarVC = self.window!.rootViewController as? UITabBarController else { fatalError() }
        guard let splitViewController1 = tabBarVC.viewControllers?[1] as? UISplitViewController else { fatalError() }
                splitViewController1.delegate = self
        guard let splitViewController2 = tabBarVC.viewControllers?[2] as? UISplitViewController else { fatalError() }
                splitViewController2.delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: UISplitViewControllerDelegate {
    
    // MARK: - Split view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        // print("appDelegate", splitViewController.viewControllers, primaryViewController, secondaryViewController)
        guard secondaryViewController as? ProductPageViewController != nil else { return false }
        return false
    }
    
    // Correctly Handle Portrait to Landscape transition for iPhone 6+ when TableView2 is open in Portrait. Comment and see for yourself, what happens when you don't write this.
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if let primaryAsNavController = primaryViewController as? UINavigationController {
            if let _ = primaryAsNavController.topViewController as? AllProductsTableViewController {
                //Return Navigation controller containing Product ID to be used as secondary view for Split View
                return (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaunchDetailViewController") )
            }
        }
        return nil
    }
    
}
