//
//  BetsViewModel.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import Foundation
import RxSwift
import RxCocoa
import SQLite
import UIKit

struct BetViewModel {
    let id: Int
    let result: Int
    let eventDate: Date
    let betOutCome: BetOutcome
    let homeTeam: Team?
    let goustTeam: Team?
    let resultText: String
}

struct BetGroup {
    let eventDate: Date
    let active: Bool
    let bets: [BetViewModel]
    
    var resaltbetSum: Int {
        bets.map {$0.result}.sum
    }
    var cellHeigth: CGFloat {
        BetsCell.heightOfTitle + BetView.cellHeigth * CGFloat(bets.count)
    }
}

struct BetSection {
    let eventDate: Date?
    let sum: Int?
    let bets: [BetGroup]
    var cellHeight: CGFloat {
        bets.map { $0.cellHeigth }.sum
    }
}

final class BetsViewModel {
    typealias Callback = ([BetSection]) -> ()
    typealias BeginRefresh = () -> ()
    let disposeBag = DisposeBag()
    var callback: Callback?
    var beginRefrech: BeginRefresh?
    
    init() {
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen).subscribe {[weak self] _ in
            if self?.callback == nil { return }
            printAppEvent("call needUpdateBetsScreen at BetsViewModel handler")
            self?.updateData()
        }.disposed(by: disposeBag)
    }
    
    func updateData() {
        beginRefrech?()
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let self = self else { return }
            let allBets: [Bet] = Repository.select(Bet.table.order(Bet.eventDateField.desc))
            let activeBets = allBets.filter { $0.isActive }.sorted { $0.eventDate < $01.eventDate }
            let bets:[Bet] = allBets.filter { !$0.isActive }
            let teams: [Team] = Repository.select(Team.table)
            let betTypes: [BetType] = AppSettings.isAuthorized ? Repository.select(BetType.table
                                                                                            .filter(activeBets.compactMap({$0.typeId})
                                                                                            .contains(BetType.idField))) : []
            
            let activeBetViewModels = activeBets.map { bet in
                BetViewModel(id: bet.id,
                             result: Int(bet.result),
                             eventDate: bet.eventDate,
                             betOutCome: .active,
                             homeTeam: teams.first(where: { team in team.id == bet.team1Id }),
                             goustTeam: teams.first(where: { team in team.id == bet.team2Id }),
                             resultText: betTypes.first(where: { type in
                                                                type.id == bet.typeId
                                                            })?.shortTitle ?? bet.factor?.formattedString ?? "0.0")
            }
            let betViewModels = bets.map { bet in
                BetViewModel(id: bet.id,
                             result: Int(bet.result),
                             eventDate: bet.eventDate,
                             betOutCome: bet.outcome ?? .unknow,
                             homeTeam: teams.first(where: { team in team.id == bet.homeTeamId }),
                             goustTeam: teams.first(where: { team in team.id == bet.team2Id }),
                             resultText: bet.outcome == nil ? "?" : bet.result.formattedString)
            }
            let activeGroups = activeBetViewModels.map { bet in
                BetGroup(eventDate: bet.eventDate, active: true, bets: [bet])
            }
            let groups = bets.map { $0.eventDate.withoutTimeStamp }.distinct().map { date in
                BetGroup(eventDate: date, active: false, bets: betViewModels.filter { $0.eventDate.withoutTimeStamp == date })
            }
            
            let betSections = groups.map({$0.eventDate.withoutDays}).distinct().map {date in
                let filtered = groups.filter { $0.eventDate.withoutDays == date }
                var sum: Int = 0
                filtered.forEach { sum += $0.resaltbetSum }
                
                return BetSection(eventDate: date.withoutDays, sum: sum, bets: filtered)
            }
            
            self.callback?([BetSection(eventDate: nil, sum: nil, bets: activeGroups)] + betSections)
        }
    }
}
