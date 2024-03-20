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
import FirebaseCore
import FirebaseMessaging

protocol PCoordinator {
    func start()
}

final class AppCoordinator: NSObject, PCoordinator {
    let window: UIWindow
    let mainCoordinator: MainCoordinator
    let syncService = SyncService()
    let disposeBag = DisposeBag()
    var activeBetToShow: Int?
    var isAuthorized = false
    var router: UINavigationController? {
        window.rootViewController as? UINavigationController
    }
    
    init(_ application: UIApplication) {
        Repository.initTable(t: Bet.self)
        Repository.initTable(t: BetType.self)
        Repository.initTable(t: Team.self)
        Repository.initTable(t: Faq.self)
        window = UIWindow(frame: UIScreen.main.bounds)
        mainCoordinator = MainCoordinator()
        super.init()
        configureFireBase(application)
        
        mainCoordinator.delegate = self
        initNotificationEventHandlers()
        isAuthorized = AppSettings.isAuthorized
        AppSettings.authorizeEvent.bind { [weak self] isAuthorized in
            if let self = self, isAuthorized != self.isAuthorized {
                self.isAuthorized = isAuthorized
                self.syncService.refresh()
            }
        }.disposed(by: disposeBag)
    }
    
    func start() {
        AccountService.share.signIn()
//        syncService.startRefreshCircle()
        
        window.rootViewController = mainCoordinator.start()
        router?.navigationBar.isHidden = true
        window.makeKeyAndVisible()
    }
    
    func initNotificationEventHandlers() {
        NotificationCenter.default.rx.notification(Notification.Name.tapAutozire).subscribe {[weak self] _ in
           self?.showAuthScreen()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.needOpenBetDetails).subscribe {[weak self] event in
            guard let betId = event.element?.userInfo?[BetView.betIdKeyForUserInfo] as? Int else { return }
            printAppEvent("tap to show bet id=\(betId)")
            self?.showBetDetails(betId: betId)
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.needOpenActiveBetDetails).subscribe {[weak self] event in
            self?.activeBetToShow = event.element?.userInfo?[BetView.betIdKeyForUserInfo] as? Int
            guard AppSettings.isAuthorized  else {
                self?.showAuthScreen { [weak self] in
                    self?.showActiveBetDetails()
                }
                return
            }
            self?.showActiveBetDetails()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.needOpenNoActiveBetDetails).subscribe {[weak self] event in
            guard let betId = event.element?.userInfo?[BetView.betIdKeyForUserInfo] as? Int else { return }
            printAppEvent("tap to show bet id=\(betId)")
            guard AppSettings.isAuthorized  else {
                self?.showAuthScreen { [weak self] in
                    self?.showActiveBetDetails()
                }
                return
            }
            self?.showBetDetails(betId: betId)
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
    
    func showActiveBetDetails() {
        if (router?.topViewController as? MainVController) == nil {
            router?.popToRootViewController(animated: false)
        }
        
        guard let topVC = router?.topViewController as? MainVController, let betId = activeBetToShow else { return }
        let vc: ForecastVController = ForecastVController.createFromNib() { vc in
            vc.betId = betId
        }
        topVC.animate { [weak self] in
            self?.router?.pushViewController(vc, animated: false)
        }
    }
    
    func showAuthScreen(_ disposed: (() -> ())? = nil) {
        let vc: SignInVController = .createFromNib()
        vc.disposed = disposed
        self.router?.present(vc, animated: true)
    }
    
    func showHistory(team: Team, animationDirectionLeft: Bool?) {
        guard let topVC = router?.topViewController as? MainVController else { return }
        let vc: HistoryVController = .createFromNib { vc in
            vc.configure(team: team)
        }
        topVC.animate(onLeft: animationDirectionLeft) { [weak self] in
            self?.router?.pushViewController(vc, animated: false)
        }
    }
}

extension AppCoordinator: MainCoordinatorDelegate {
    func startGuidTour() {
        guard AppSettings.needTourGuidShow, AppSettings.isRelease, let vc = TourGuidVController.create() else { return }
        vc.modalPresentationStyle = .overCurrentContext
        vc.endAction = { [weak self] in
            AppSettings.needTourGuidShow = false
            self?.router?.dismiss(animated: false)
        }
        router?.present(vc, animated: false)
    }
}

extension AppCoordinator: UNUserNotificationCenterDelegate {
    func configureFireBase(_ application: UIApplication) {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            guard error == nil else{
                printAppEvent(error!.localizedDescription)
                return
            }
        }
        application.registerForRemoteNotifications()
    }
}

extension AppCoordinator: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AppSettings.fcmToken = fcmToken ?? ""
    }
}
