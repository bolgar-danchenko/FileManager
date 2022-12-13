//
//  SceneDelegate.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 22.10.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session:
        UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = createTabBarController()
        window?.makeKeyAndVisible()
    }

    private enum TabItemType {
        case documents
        case settings

        var title: String {
            switch self {
            case .documents:
                return "Documents"
            case .settings:
                return "Settings"
            }
        }

        var tabBarItem: UITabBarItem {
            switch self {
            case .documents:
                return UITabBarItem(title: "Documents",
                                    image: UIImage(systemName: "doc"),
                                    tag: 0)
            case .settings:
                return UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)
            }
        }
    }

    private func createNavController(for tabItemType: TabItemType) -> UINavigationController {
        let vc: UIViewController
        switch tabItemType {
        case .documents:
            vc = DocumentsViewController(rootURL: getURL(),
                                         directoryTitle: getURL().lastPathComponent)
        case .settings:
            vc = SettingsViewController()
        }
        vc.title = tabItemType.title
        vc.tabBarItem = tabItemType.tabBarItem
        return UINavigationController(rootViewController: vc)
    }

    private func createTabBarController() -> UITabBarController {
        let controller = UITabBarController()
        UITabBar.appearance().backgroundColor = .systemGray6
        controller.viewControllers = [
            self.createNavController(for: .documents),
            self.createNavController(for: .settings)
        ]
        return controller
    }

    func getURL() -> URL {
        let urlArray = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        let url = urlArray[0]
        return url
    }
}
