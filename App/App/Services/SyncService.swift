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
                DispatchQueue.main.async {[weak self] in
                    self?.compliteTasks.compactMap{$0}.forEach{ complite in
                        complite(false)
                    }
                    self?.compliteTasks.removeAll()
                }
                return
            }
            guard responseData.code == 200,
                  let newLastTimeDataUpdated = responseData.newLastTimeDataUpdated,
                  let teams = responseData.teams,
                  let bets = responseData.bets,
                  let betTypes = responseData.betTypes,
                  let faqs = responseData.faqs else {
                NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
                DispatchQueue.main.async {[weak self] in
                    self?.compliteTasks.compactMap{$0}.forEach{ complite in
                        complite(false)
                    }
                    self?.compliteTasks.removeAll()
                }
                return
            }
            
            if responseData.appupdate == .required {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdateApp, object: nil)
                
            }
            AppSettings.lastTimeSynced = newLastTimeDataUpdated
            AppSettings.lastLocaleThenUpdate = Locale.current.identifier
            AppSettings.defaultFreeBetsCount = Int(responseData.defaultFreeBetsCount ?? "0") ?? 0
            AppSettings.giftFreeBetsCount = Int(responseData.giftFreeBetsCount ?? "0") ?? 0
            //AppSettings.userBetsLeft = Int(responseData.userBetsLeft ?? "0") ?? 0
            AppSettings.isSubscribedToTgChannel = (responseData.isSubscribedToTgChannel ?? 0) > 0

            Repository.async {[weak self] in
                Repository.refreshData(teams)
                Repository.refreshData(bets)
                Repository.refreshData(faqs)
                Repository.refreshData(betTypes)
                
                
                
                if !faqs.isEmpty {
                    NotificationCenter.default.post(name: NSNotification.Name.needUpdatFaqsScreen, object: nil)
                }
                if !teams.isEmpty || !bets.isEmpty || !betTypes.isEmpty {
                    NotificationCenter.default.post(name: NSNotification.Name.needUpdateBetsScreen, object: nil)
                }
                let newData = !(teams.isEmpty
                                && bets.isEmpty
                                && betTypes.isEmpty
                                && faqs.isEmpty)
                self?.lastUpdateDate = Date()
                DispatchQueue.main.async {[weak self] in
                    self?.compliteTasks.compactMap{$0}.forEach{ complite in
                        complite(newData)
                    }
                }
            
                printAppEvent("refresh data \(newData)")
                self?.compliteTasks.removeAll()
            }
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
