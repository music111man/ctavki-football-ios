//
//  SyncService.swift
//  App
//
//  Created by Denis Shkultetskyy on 01.03.2024.
//

import Foundation
import RxSwift
import RxCocoa

extension Notification.Name {
    static let needUpdateApp = Notification.Name("needUpdateApp")
    static let badServerResponse = Notification.Name("badServerResponse")
    static let tryToRefreshData = Notification.Name("tryToRefreshData")
    static let wasSyncData = Notification.Name("wasSyncData")
}

final class SyncService {
    private let disposeBag = DisposeBag()
    init() {
        NotificationCenter.default.rx.notification(.tryToRefreshData)
            .subscribe {[weak self] _ in
                DispatchQueue.global(qos: .background).async { [ weak self] in
                    self?.refresh()
                }
            }.disposed(by: disposeBag)
            
    }
    
    func refresh() {
        print("\(Date()) >> start sync")
        NetProvider.makeRequest(ApiResponseData.self, .checkForUpdates) { responseData in
            if responseData.code != 200 {
                NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
                return
            }
            if responseData.appupdate != .none {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdateApp, object: responseData.appupdate)
            }
            AppSettings.lastTimeSynced = responseData.newLastTimeDataUpdated
            AppSettings.lastLocaleThenUpdate = Locale.current.identifier
            AppSettings.defaultFreeBetsCount = responseData.defaultFreeBetsCount
            AppSettings.giftFreeBetsCount = responseData.giftFreeBetsCount
            AppSettings.userBetsLeft = responseData.userBetsLeft
            AppSettings.isSubscribedToTgChannel = responseData.isSubscribedToTgChannel
            
            if Repository.refreshData(responseData.teams) {
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncData, object: Team.self)
            }
            if Repository.refreshData(responseData.faqs){
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncData, object: Faq.self)
            }
            if Repository.refreshData(responseData.bets) {
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncData, object: Bet.self)
            }
            if Repository.refreshData(responseData.betTypes) {
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncData, object: BetType.self)
            }
        }
    }
    
    func startRefreshCircle() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + AppSettings.syncInterval) { [weak self] in
            self?.refresh()
            self?.startRefreshCircle()
        }
    }
}
