//
//  MainCoordinator.swift
//  App
//
//  Created by Denis Shkultetskyy on 26.02.2024.
//

import UIKit
import RxSwift

final class MainCoordinator {
    let router: UINavigationController
    var factories = [PVCFactory]()
    let mainVC = MainVController()
    let disposeBag = DisposeBag()
    
    var lastMenuAction: ToolBarView.MenuAction?
    
    init() {
        self.router = UINavigationController(rootViewController: mainVC)
        mainVC.delegate = self
    }
    
    func start() -> UINavigationController {
        factories.append(contentsOf: [PicksFactory(), TeamsFactory(), PurchesFactory(), FaqFactory()])
        mainVC.setChildVC(vc: factories[0].create())
        
        return router
    }
    func openByPush(_ action: ToolBarView.MenuAction) {
        factories.forEach { $0.clear() }
        lastMenuAction = action
        switch action {
        case .bets:
            mainVC.setChildVC(vc: factories[0].create(), action: action, needScrollToTop: true)
        case .teams:
            mainVC.setChildVC(vc: factories[1].create(), action: action, needScrollToTop: true)
        case .pay:
            mainVC.setChildVC(vc: factories[2].create(), action: action, needScrollToTop: true)
        case .faq:
            mainVC.setChildVC(vc: factories[3].create(), action: action, needScrollToTop: true)
        }
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
