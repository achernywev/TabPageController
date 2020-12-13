//
//  AppDelegate.swift
//  TabPageControllerExample
//
//  Created by Aleksandr Chernyshev on 13.12.2020.
//

import UIKit
import TabPageController

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let navigationController = UINavigationController(rootViewController: createAndReturnTabPageController())
        navigationController.navigationBar.isTranslucent = false
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    func createAndReturnTabPageController() -> TabPageController {
        let controller1 = UIViewController()
        controller1.view.backgroundColor = UIColor.red
        let item1 = TabPageItem(viewController: controller1, viewControllerTitle: "Title 1")
        
        let controller2 = UIViewController()
        controller2.view.backgroundColor = UIColor.green
        let item2 = TabPageItem(viewController: controller2, viewControllerTitle: "Title 2")
        
        let controller3 = UIViewController()
        controller3.view.backgroundColor = UIColor.purple
        let item3 = TabPageItem(viewController: controller3, viewControllerTitle: "Title 3")
        
        let controller4 = UIViewController()
        controller4.view.backgroundColor = UIColor.magenta
        let item4 = TabPageItem(viewController: controller4, viewControllerTitle: "Title 4")
        
        let controller5 = UIViewController()
        controller5.view.backgroundColor = UIColor.blue
        let item5 = TabPageItem(viewController: controller5, viewControllerTitle: "Title 5")
        
        let tabController = TabPageController(pageItems: [item1, item2, item3, item4, item5])
        tabController.title = "TabPageController"
        return tabController
    }
}

