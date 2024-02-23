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
    var factories: [PVCFactory] = [PicksFactory(), TeamsFactory(), PurchesFactory(), FaqFactory()]
    let mainVC = MainVController()
    init() {
        
    }
    
    func start() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        mainVC.delegate = self
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
        pushView(.bets)
        self.window = window
    }
    
    private func addBetsVC() {
        
    }
}

extension MainCoordinator: MainViewDelegate {
    func pushView(_ action: ToolBarView.MenuAction) {
        print("tap \(action)")
        factories.forEach { $0.clear() }
        switch action {
        case .bets:
            mainVC.setChildVC(vc: factories[0].create())
        case .teams:
            mainVC.setChildVC(vc: factories[1].create())
        case .pay:
            mainVC.setChildVC(vc: factories[2].create())
        case .faq:
            mainVC.setChildVC(vc: factories[3].create())
        }
    }
    
    
}
