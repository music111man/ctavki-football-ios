//
//  AppDelegate.swift
//  App
//
//  Created by Denis Shkultetskyy on 21.02.2024.
//

import UIKit
import GoogleSignIn

func printAppEvent(_ event: String, marker: String = ">>>") {
    print("\(Date().format("HH:mm:ss"))-\(marker)\(event)")
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var mainCoordinator: PCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mainCoordinator = AppCoordinator(application)
        mainCoordinator.start()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

