//
//  MainCoordinator.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

protocol PCoordinator {
    func start()
}

final class AppCoordinator: PCoordinator {
    let window: UIWindow
    let mainCoordinator: MainCoordinator
    let syncService = SyncService()
    let disposeBag = DisposeBag()
    
    var router: UINavigationController? {
        window.rootViewController as? UINavigationController
    }
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        mainCoordinator = MainCoordinator()
        mainCoordinator.delegate = self
        initNotificationEventHandlers()
    }
    
    func start() {
        syncService.startRefreshCircle()
        
        window.rootViewController = mainCoordinator.start()
        router?.navigationBar.isHidden = true
        window.makeKeyAndVisible()
    }
    
    func initNotificationEventHandlers() {
        NotificationCenter.default.rx.notification(Notification.Name.tapAutozire).subscribe {[weak self] _ in
            if !AppSettings.isAuthorized {
                self?.showAuthScreen()
            }
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.needOpenBetDetails).subscribe {[weak self] event in
            guard let betId = event.element?.userInfo?[BetView.betIdKeyForUserInfo] as? Int else { return }
            printAppEvent("tap to show bet id=\(betId)")
            self?.showBetDetails(betId: betId)
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.needOpenActiveBetDetails).subscribe {[weak self] event in
            guard AppSettings.isAuthorized, let betId = event.element?.userInfo?[BetView.betIdKeyForUserInfo] as? Int else {
                self?.showAuthScreen()
                return
            }
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.needOpenHistory).subscribe {[weak self] event in
            guard let team = event.element?.userInfo?[BetView.teamKeyUserInfo] as? Team else {
                printAppEvent("Unable open history - no arguments")
                return
            }
            let tapLeft = event.element?.userInfo?[BetView.tapLeftUserInfo] as? Bool
            self?.showHistory(team: team, animationDirectionLeft: tapLeft)
        }.disposed(by: disposeBag)
    }
    
    func showBetDetails(betId: Int) {
        let vc: BetDetailsVController = BetDetailsVController.createFromNib() { vc in
            vc.configure(betId: betId)
        }
        vc.modalPresentationStyle = .overFullScreen
        self.router?.present(vc, animated: false)
    }
    
    func showAuthScreen() {
        let alert = UIAlertController(title: "Need autorization", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.router?.present(alert, animated: true)
    }
    
    func showHistory(team: Team, animationDirectionLeft: Bool?) {
        guard let topVC = router?.topViewController as? MainVController else { return }
        let vc: HistoryVController = .createFromNib { vc in
            vc.configure(team: team)
        }
        topVC.animate(onLeft: animationDirectionLeft) { [weak self] in
            self?.router?.pushViewController(vc, animated: false)
        }
//        
//        if let onLeft = animationDirectionLeft {
//            UIView.transition(with: topVC.view,
//                              duration: 0.4,
//                              options: [onLeft ? .transitionFlipFromRight : .transitionFlipFromLeft],
//                              animations: {
//                topVC.view.layer.opacity = 0
//            }) {[weak self] _ in
//                topVC.view.layer.opacity = 1
//                self?.router?.pushViewController(vc, animated: false)
//            }
//            
//            return
//        }
//        UIView.animate(withDuration: 0.3) {
//            topVC.view.transform = .init(scaleX: 0.01, y: 0.01)
//        } completion: { [weak self] _ in
//            topVC.view.transform = .identity
//            self?.router?.pushViewController(vc, animated: false)
//        }
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
