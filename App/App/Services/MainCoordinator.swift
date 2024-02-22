//
//  MainCoordinator.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit

protocol PMainCoordinator {
    func start()
}

final class MainCoordinator: PMainCoordinator {
    var window: UIWindow?
    var picksRouter: UINavigationController?
    var teamsRouter: UINavigationController?
    var currentRouter:UINavigationController?
    
    init() {
        
    }
    
    func start() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = MainVController()
        controller.delegate = self
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
    }
    
    
}

extension MainCoordinator: MainViewDelegate {
    func pushView(_ action: ToolBarView.MenuAction) {
        print("tap \(action)")
    }
    
    
}
