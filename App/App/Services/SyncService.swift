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
    static let wasSyncBetData = Notification.Name("wasSyncBetData")
    static let wasSyncBetTypeData = Notification.Name("wasSyncBetTypeData")
    static let wasSyncTeamData = Notification.Name("wasSyncTeamData")
    static let wasSyncFaqData = Notification.Name("wasSyncFaqData")
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
            if responseData.appupdate == .required {
                return
            }
            AppSettings.lastTimeSynced = responseData.newLastTimeDataUpdated
            AppSettings.lastLocaleThenUpdate = Locale.current.identifier
            AppSettings.defaultFreeBetsCount = responseData.defaultFreeBetsCount
            AppSettings.giftFreeBetsCount = responseData.giftFreeBetsCount
            AppSettings.userBetsLeft = responseData.userBetsLeft
            AppSettings.isSubscribedToTgChannel = responseData.isSubscribedToTgChannel
            
            if Repository.refreshData(responseData.teams) {
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncTeamData, object: nil)
            }
            if Repository.refreshData(responseData.faqs) {
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncFaqData, object: nil)
            }
            if Repository.refreshData(responseData.bets) {
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncBetData, object: nil)
            }
            if Repository.refreshData(responseData.betTypes) {
                NotificationCenter.default.post(name: NSNotification.Name.wasSyncBetTypeData, object: nil)
            }
            
            let bets:[Bet] = Repository.selectData(Bet.table.where(Bet.team1IdField == 29 && Bet.team2IdField == 289))
            for bet in bets {
                print("\(bet.eventDate) \(bet.typeId ?? 0)")
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
