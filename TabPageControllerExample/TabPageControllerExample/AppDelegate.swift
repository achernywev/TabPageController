import UIKit
import TabPageController

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [createRegularPageVC(), createScrollPageVC()]
        tabBarController.tabBar.isTranslucent = false
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }
    
    private typealias BasePageVC = TabPageController<TabPageCell>
    
    private func createNavigation(title: String, constructor: () -> BasePageVC) -> UINavigationController {
        let rootVC = constructor()
        rootVC.title = title
        let navController = UINavigationController(rootViewController: rootVC)
        navController.title = title
        navController.navigationBar.isTranslucent = false
        return navController
    }
    
    private func createRegularPageVC() -> UIViewController {
        return createNavigation(title: "Regular", constructor: {
            let controller1 = ExampleViewController()
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
            tabController.updatePageItems([item1, item2, item3, item4, item5])
            return tabController
        })
    }
    
    private func createScrollPageVC() -> UIViewController {
        return createNavigation(title: "Scroll", constructor: {
            let viewController = ScrollableHeaderTabPageController<TabPageCell>()
            let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue, .systemPurple, .systemPink, .systemTeal]
            viewController.updatePageItems(colors.enumerated().map {
                let viewController = ExampleViewController()
                viewController.view.backgroundColor = $0.element
                return TabPageItem(viewController: viewController, title: "Some title #\($0.offset + 1)")
            })
            
            let headerHeight = 200.0
            let headerView = UIView()
            headerView.backgroundColor = .systemIndigo
            headerView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
            viewController.headerView = headerView
            
            return viewController
        })
    }
}
