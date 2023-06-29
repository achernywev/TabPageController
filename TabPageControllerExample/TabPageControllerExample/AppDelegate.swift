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
    
    private typealias BasePageVC = TabPageController<TabPageCell>
    private func createAndReturnTabPageController() -> BasePageVC {
        let controller1 = UIViewController()
        controller1.view.backgroundColor = UIColor.red
        let item1 = TabPageItem(viewController: controller1, title: "Title 1")
        
        let controller2 = UIViewController()
        controller2.view.backgroundColor = UIColor.green
        let item2 = TabPageItem(viewController: controller2, title: "Title 2")
        
        let controller3 = UIViewController()
        controller3.view.backgroundColor = UIColor.purple
        let item3 = TabPageItem(viewController: controller3, title: "Title 3")
        
        let controller4 = UIViewController()
        controller4.view.backgroundColor = UIColor.magenta
        let item4 = TabPageItem(viewController: controller4, title: "Title 4")
        
        let controller5 = UIViewController()
        controller5.view.backgroundColor = UIColor.blue
        let item5 = TabPageItem(viewController: controller5, title: "Title 5")
        
        let tabController = BasePageVC()
        tabController.title = "TabPageController"
        tabController.updatePageItems([item1, item2, item3, item4, item5])
        return tabController
    }
}

