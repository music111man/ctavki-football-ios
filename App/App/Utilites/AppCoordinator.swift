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
