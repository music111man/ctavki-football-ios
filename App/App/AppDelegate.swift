//
//  AppDelegate.swift
//  App
//
//  Created by Denis Shkultetskyy on 21.02.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var mainCoordinator: PMainCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mainCoordinator = MainCoordinator()
        mainCoordinator.start()
        
        return true
    }

}

