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
    static let needAuthorize = Notification.Name("needAuthorize")
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
    var activeBets: [Bet]?
    
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
                self?.compliteAll(false)
                return
            }
            //user not authorized
            if responseData.code == 401 {
                NotificationCenter.default.post(name: NSNotification.Name.needAuthorize, object: nil)
                self?.compliteAll(false)
                return
            }
            guard responseData.code == 200,
                  let newLastTimeDataUpdated = responseData.newLastTimeDataUpdated,
                  let teams = responseData.teams,
                  let bets = responseData.bets,
                  let betTypes = responseData.betTypes,
                  let faqs = responseData.faqs else {
                NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
                self?.compliteAll(false)
                return
            }
            
            if responseData.appupdate == .required {
                NotificationCenter.default.post(name: NSNotification.Name.needUpdateApp, object: nil)
                
            }
            AppSettings.lastTimeSynced = newLastTimeDataUpdated
            AppSettings.lastLocaleThenUpdate = Locale.current.identifier
            AppSettings.defaultFreeBetsCount = Int(responseData.defaultFreeBetsCount ?? "0") ?? 0
            AppSettings.giftFreeBetsCount = Int(responseData.giftFreeBetsCount ?? "0") ?? 0
            if let tgBotLink = responseData.tgBotLink {
                AppSettings.tgBotLink = tgBotLink
            }
            //AppSettings.userBetsLeft = Int(responseData.userBetsLeft ?? "0") ?? 0
            AppSettings.isSubscribedToTgChannel = (responseData.isSubscribedToTgChannel ?? 0) > 0

            Repository.async {[weak self] in
                guard let self else { return }
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
                self.lastUpdateDate = Date()
                self.compliteAll(newData)
                if !bets.isEmpty {
                    self.activeBets = bets.filter({$0.isActive})
                    self.dispatchQueue.asyncAfter(deadline: .now() + 1) {[weak self] in
                        self?.observeActiveBets()
                    }
                } else {
                    if self.activeBets == nil || self.activeBets!.isEmpty {
                        self.activeBets = Repository.select(Bet.table.filter(Bet.eventDateField > Date.matchTime))
                        self.dispatchQueue.asyncAfter(deadline: .now() + 1) {[weak self] in
                            self?.observeActiveBets()
                        }
                    }
                }
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
    
    func observeActiveBets() {
        guard let activeBets = self.activeBets, !activeBets.isEmpty  else { return }
//        printAppEvent("active bets: \(activeBets.count)", marker: "}}=}")
        if !activeBets.allSatisfy({ $0.isActive}) {
            self.activeBets = activeBets.filter { $0.isActive }
            NotificationCenter.default.post(name: NSNotification.Name.needUpdateBetsScreen, object: nil)
        }
        dispatchQueue.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.observeActiveBets()
        }
    }
    
    private func compliteAll(_ newData: Bool) {
        DispatchQueue.main.async {[weak self] in
            self?.compliteTasks.compactMap{$0}.forEach{ complite in
                complite(newData)
            }
            printAppEvent("refresh data \(newData)")
            self?.compliteTasks.removeAll()
        }
    }
}
