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
    var wasUpdated = false
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
        FirebaseApp.configure()
        IAPService.default.requestProducts()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        PushService.config(application, self)
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
            guard let teamId = event.element?.userInfo?[BetView.teamIdKeyUserInfo] as? Int else {
                printAppEvent("Unable open history - no arguments")
                return
            }
            let tapLeft = event.element?.userInfo?[BetView.tapLeftUserInfo] as? Bool
            self?.showHistory(teamId: teamId, animationDirectionLeft: tapLeft)
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.tryToShowTourGuid).subscribe {[weak self] _ in
            self?.startGuidTour()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).subscribe {_ in
            UIApplication.shared.applicationIconBadgeNumber = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
                printAppEvent("willEnterForegroundNotification event")
                self?.syncService.refresh()
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
    
    func showActiveBetDetails(betId: Int? = nil) {
        if (router?.topViewController as? MainVController) == nil {
            router?.popToRootViewController(animated: false)
        }
        
        guard let betId = betId ?? activeBetToShow else { return }
        let vc: ForecastVController = ForecastVController.createFromNib() { vc in
            vc.betId = betId
        }

        router?.pushViewController(vc, animated: true)
    }
    
    func showAuthScreen(_ disposed: (() -> ())? = nil) {
        let vc: SignInVController = .createFromNib()
        vc.disposed = disposed
        self.router?.present(vc, animated: true)
    }
    
    func showHistory(teamId: Int, animationDirectionLeft: Bool?) {
        if (router?.topViewController as? MainVController) == nil {
            router?.popToRootViewController(animated: false)
        }
        
        let vc: HistoryVController = .createFromNib { vc in
            vc.configure(teamId: teamId)
        }
        router?.pushViewController(vc, animated: true)
    }

    func startGuidTour() {
        guard AppSettings.needTourGuidShow, let vc = TourGuidVController.create() else { return }
        vc.modalPresentationStyle = .overCurrentContext
        vc.endAction = { [weak self] in
            AppSettings.needTourGuidShow = false
            self?.router?.dismiss(animated: false)
        }
        router?.present(vc, animated: false)
    }
}

extension AppCoordinator: PushManagerDelegate {
    func canShow(pushRedirect: PushRedirect) -> Bool {
        switch pushRedirect {
        case let .bet(betId):
            if let vc = mainCoordinator.router.topViewController as? ForecastVController, vc.betId == betId {
                return false
            }
            return true
        default:
            return true
        }
    }
    
    func openScreen(pushRedirect: PushRedirect) {
        printAppEvent("try open fby tap push")
        syncService.refresh() { [weak self] _ in
            self?.processPushDirect(pushRedirect)
        }
    }
    
    private func processPushDirect(_ pushRedirect: PushRedirect) {
        switch pushRedirect {
        case .paid:
            self.openByMenuAction(.pay)
        case .faq:
            self.openByMenuAction(.faq)
        case let .team(id):
            self.showHistory(teamId: id, animationDirectionLeft: nil)
        case .teams:
            self.openByMenuAction(.teams)
        case let .url(urlStr):
            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case let .bet(id):
            GoogleAnaliticsService.logTapPush(param: .betId(id))
            if AppSettings.isAuthorized {
                self.showActiveBetDetails(betId: id)
            } else {
                self.activeBetToShow = id
                self.showAuthScreen() { [weak self] in
                    self?.showActiveBetDetails()
                }
            }
        }
    }
    
    func openByMenuAction(_ action: ToolBarView.MenuAction) {
        if (router?.topViewController as? MainVController) == nil {
            router?.popToRootViewController(animated: false)
        }
        mainCoordinator.pushView(action, needSelectMenu: true)
    }
}
