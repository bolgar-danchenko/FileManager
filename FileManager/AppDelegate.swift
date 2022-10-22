//
//  AppDelegate.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 22.10.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        func getURL() -> URL {
            let urlArray = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )
            let url = urlArray[0]
            return url
        }

        let navigationController = UINavigationController(rootViewController: DocumentsViewController(
            rootURL: getURL(),
            directoryTitle: getURL().lastPathComponent
        ))
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

