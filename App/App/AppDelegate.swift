//
//  AppDelegate.swift
//  App
//
//  Created by Denis Shkultetskyy on 21.02.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: ViewController()) // Your initial view controller.
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

}

