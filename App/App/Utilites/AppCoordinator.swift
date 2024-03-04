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
            let alert = UIAlertController(title: "Autorization", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self?.router?.present(alert, animated: true)
        }.disposed(by: disposeBag)
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
