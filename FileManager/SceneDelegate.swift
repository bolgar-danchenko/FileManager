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

        let window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController(rootViewController: DocumentsViewController(
            rootURL: getURL(),
            directoryTitle: getURL().lastPathComponent
        ))
        self.window = window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
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
