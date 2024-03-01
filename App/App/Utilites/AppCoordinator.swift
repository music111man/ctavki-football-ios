//
//  MainCoordinator.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit

protocol PCoordinator {
    func start()
}

final class AppCoordinator: PCoordinator {
    let window: UIWindow
    let mainCoordinator: MainCoordinator
    let syncService = SyncService()
    
    var router: UINavigationController? {
        window.rootViewController as? UINavigationController
    }
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        mainCoordinator = MainCoordinator()
        mainCoordinator.delegate = self
    }
    
    func start() {
        syncService.startRefreshCircle()
        
        window.rootViewController = mainCoordinator.start()
        router?.navigationBar.isHidden = true
        window.makeKeyAndVisible()
    }
    
}

extension AppCoordinator: MainCoordinatorDelegate {
    func startGuidTour() {
        guard let vc = TourGuidVController.create() else { return }
        vc.modalPresentationStyle = .overCurrentContext
        vc.endAction = { [weak self] in
            self?.router?.dismiss(animated: false)
        }
        router?.present(vc, animated: false)
    }
}
