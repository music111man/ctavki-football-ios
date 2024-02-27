//
//  AppDelegate.swift
//  App
//
//  Created by Denis Shkultetskyy on 21.02.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var mainCoordinator: PCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mainCoordinator = AppCoordinator()
        mainCoordinator.start()
        
        return true
    }

}

