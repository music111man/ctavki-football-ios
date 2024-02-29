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
    
    var router: UINavigationController? {
        window.rootViewController as? UINavigationController
    }
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        mainCoordinator = MainCoordinator()
        mainCoordinator.delegate = self
    }
    
    func start() {
        NetProvider.makeRequest(ApiResponseData.self, .checkForUpdates) { responseData in
            print("update=\(responseData.isSubscribedToTgChannel), bets count=\(responseData.bets.count)")
            print("lastUpdate=\(responseData.newLastTimeDataUpdated), teams count=\(responseData.teams.count)")
            print("bet type count=\(responseData.betTypes.count), event date=\(responseData.bets[0].outcome ?? .lost )")
            print("faq count=\(responseData.faqs.count)")
        }
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
