//
//  MainCoordinator.swift
//  App
//
//  Created by Denis Shkultetskyy on 26.02.2024.
//

import UIKit

final class MainCoordinator {
    let router: UINavigationController
    var factories: [PVCFactory] = [PicksFactory(), TeamsFactory(), PurchesFactory(), FaqFactory()]
    let mainVC = MainVController()
    
    var lastMenuAction: ToolBarView.MenuAction?
    
    init() {
        self.router = UINavigationController(rootViewController: mainVC)
        mainVC.delegate = self
    }
    
    func start() -> UINavigationController {
        mainVC.setChildVC(vc: factories[0].create())
        
        return router
    }
}

extension MainCoordinator: MainViewDelegate {
    func pushView(_ action: ToolBarView.MenuAction, needSelectMenu: Bool) {
        factories.forEach { $0.clear() }
        lastMenuAction = action
        let selectAction = needSelectMenu ? action : nil
        switch action {
        case .bets:
            mainVC.setChildVC(vc: factories[0].create(), action: selectAction)
        case .teams:
            mainVC.setChildVC(vc: factories[1].create(), action: selectAction)
        case .pay:
            mainVC.setChildVC(vc: factories[2].create(), action: selectAction)
        case .faq:
            mainVC.setChildVC(vc: factories[3].create(), action: selectAction)
        }
    }
}
