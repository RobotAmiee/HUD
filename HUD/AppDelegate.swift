//
//  AppDelegate.swift
//  HUD
//
//  Created by 张龙 on 2024/1/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tabBarController: UITabBarController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        tabBarController = UITabBarController()
        let navi = UINavigationController(rootViewController: ViewController())
        tabBarController.viewControllers = [navi]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}
