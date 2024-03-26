//
//  MainCoordinator.swift
//  App
//
//  Created by Denis Shkultetskyy on 26.02.2024.
//

import UIKit

protocol MainCoordinatorDelegate: AnyObject {
    func startGuidTour()
}

final class MainCoordinator {
    let router: UINavigationController
    var factories: [PVCFactory] = [PicksFactory(), TeamsFactory(), PurchesFactory(), FaqFactory()]
    let mainVC = MainVController()
    weak var delegate: MainCoordinatorDelegate?
    
    var lastMenuAction: ToolBarView.MenuAction?
    
    init() {
        self.router = UINavigationController(rootViewController: mainVC)
        mainVC.delegate = self
    }
    
    func start() -> UINavigationController {
        mainVC.setChildVC(vc: factories[0].create()) {[weak self] in
            self?.delegate?.startGuidTour()
        }
        
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
            mainVC.setChildVC(vc: factories[0].create(), action: selectAction, flipFromRight: true)
        case .teams:
            mainVC.setChildVC(vc: factories[1].create(), action: selectAction, flipFromRight: true)
        case .pay:
            mainVC.setChildVC(vc: factories[2].create(), action: selectAction, flipFromRight: false)
        case .faq:
            mainVC.setChildVC(vc: factories[3].create(), action: selectAction, flipFromRight: false)
        }
    }
}
