//
//  SyncService.swift
//  App
//
//  Created by Denis Shkultetskyy on 01.03.2024.
//

import Foundation
import RxSwift
import RxCocoa
import SQLite

extension Notification.Name {
    static let needUpdateApp = Notification.Name("needUpdateApp")
    static let badServerResponse = Notification.Name("badServerResponse")
    static let tryToRefreshData = Notification.Name("tryToRefreshData")
    static let noDataForBetsScreen = Notification.Name("noDataForBetsScreen")
    static let wasSyncBetTypeData = Notification.Name("wasSyncBetTypeData")
    static let wasSyncTeamData = Notification.Name("wasSyncTeamData")
    static let wasSyncFaqData = Notification.Name("wasSyncFaqData")
    static let needUpdateBetsScreen = Notification.Name("needUpdateBetsScreen")
    static let needUpdatFaqsScreen = Notification.Name("needUpdatFaqsScreen")
}

final class SyncService {
    
    private let disposeBag = DisposeBag()
    var isStartRefreshCircle = false
    init() {
        NotificationCenter.default.rx.notification(.tryToRefreshData)
            .subscribe {[weak self] _ in
                printAppEvent("tryToRefreshData event")
                guard let self = self else { return }
                if self.isStartRefreshCircle {
                    self.refresh()
                } else {
                    self.isStartRefreshCircle = true
                    self.startRefreshCircle()
                }
            }.disposed(by: disposeBag)
            
    }
    
    func refresh(_ complite: ((Bool) -> ())? = nil ) {
        printAppEvent("start sync")
        NetProvider.makeRequest(ApiResponseData.self, .checkForUpdates) { responseData in
            guard let responseData = responseData else {
                complite?(false)
                return
            }
            if responseData.code != 200 {
                NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
                complite?(false)
                return
            }
            if responseData.appupdate != .none {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdateApp, object: responseData.appupdate)
                
            }
            if responseData.appupdate == .required {
                complite?(false)
                return
            }
            AppSettings.lastTimeSynced = responseData.newLastTimeDataUpdated
            AppSettings.lastLocaleThenUpdate = Locale.current.identifier
            AppSettings.defaultFreeBetsCount = responseData.defaultFreeBetsCount
            AppSettings.giftFreeBetsCount = responseData.giftFreeBetsCount
            AppSettings.userBetsLeft = responseData.userBetsLeft
            AppSettings.isSubscribedToTgChannel = responseData.isSubscribedToTgChannel
            
            Repository.refreshData(responseData.teams)
            Repository.refreshData(responseData.bets)
            Repository.refreshData(responseData.faqs)
            Repository.refreshData(responseData.betTypes)
            
//            if !responseData.teams.isEmpty {
//                NotificationCenter.default.post(name: NSNotification.Name.wasSyncTeamData, object: nil)
//            }
            if !responseData.faqs.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdatFaqsScreen, object: nil)
            }
//            
//            if !responseData.betTypes.isEmpty {
//                NotificationCenter.default.post(name: NSNotification.Name.wasSyncBetTypeData, object: nil)
//            }
            if !responseData.teams.isEmpty || !responseData.bets.isEmpty || !responseData.betTypes.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdateBetsScreen, object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.noDataForBetsScreen, object: nil)
            }
            let noData = responseData.teams.isEmpty
                        && responseData.bets.isEmpty
                        && responseData.betTypes.isEmpty
                        && responseData.faqs.isEmpty
            printAppEvent("Refresh data \(!noData)")
            complite?(!noData)
        }
    }
    
    func startRefreshCircle() {
        self.refresh()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + AppSettings.syncInterval) { [weak self] in
            self?.startRefreshCircle()
        }
    }
}
