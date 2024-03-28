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
    static let wasSyncBetTypeData = Notification.Name("wasSyncBetTypeData")
    static let wasSyncTeamData = Notification.Name("wasSyncTeamData")
    static let wasSyncFaqData = Notification.Name("wasSyncFaqData")
    static let needUpdateBetsScreen = Notification.Name("needUpdateBetsScreen")
    static let needUpdatFaqsScreen = Notification.Name("needUpdatFaqsScreen")
}

final class SyncService {
    typealias Complite = (Bool) -> Void
    private let disposeBag = DisposeBag()
    var compliteTasks = [Complite?]()
    var lastUpdateDate: Date?
    static let shared = SyncService()
    let dispatchQueue = DispatchQueue(label: "syncService", qos: .background)
    var dispatchWorkItem: DispatchWorkItem?
    
    private init() {
    }
    
    func refresh(_ complite: Complite? = nil ) {
        compliteTasks.append(complite)
        if compliteTasks.count > 1 {
            return
        }
        
        printAppEvent("start sync")
        NetProvider.makeRequest(ApiResponseData.self, .checkForUpdates) {[weak self] responseData in
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
            if !responseData.faqs.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdatFaqsScreen, object: nil)
            }
            if !responseData.teams.isEmpty || !responseData.bets.isEmpty || !responseData.betTypes.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdateBetsScreen, object: nil)
            }
            let newData = !(responseData.teams.isEmpty
                        && responseData.bets.isEmpty
                        && responseData.betTypes.isEmpty
                        && responseData.faqs.isEmpty)
            self?.lastUpdateDate = Date()
            self?.compliteTasks.compactMap{$0}.forEach{ complite in
                complite(newData)
            }
            printAppEvent("refresh data \(newData)")
            self?.compliteTasks.removeAll()
            self?.dispatchWorkItem?.cancel()
            let item = DispatchWorkItem {[weak self] in
                self?.refresh()
            }
            self?.dispatchWorkItem = item
            self?.dispatchQueue.asyncAfter(deadline: .now() + AppSettings.syncInterval,
                                           execute: item)
        }
    }
}
