//
//  HistoryService.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import Foundation
import RxSwift
import RxCocoa
import SQLite

struct TeamHistoryViewModel {
    let title: String
    let betsCount: Int
    let amount: Int
}

final class HistoryService {
    typealias RefreshActivity = (Bool) -> ()
    var team: Team {
        didSet {
            teamModel.accept(TeamHistoryViewModel(title: team.title, betsCount: 0, amount: 0))
            betGroups.accept([])
            activeBetGroups.accept([])
        }
    }
    let teamModel: BehaviorRelay<TeamHistoryViewModel>
    let betGroups = BehaviorRelay<[BetGroup]>(value: [])
    let activeBetGroups = BehaviorRelay<[BetGroup]>(value: [])
    let disposeBag = DisposeBag()
    var refreshActivity: RefreshActivity?
    
    init(team: Team,_ refreshActivity: RefreshActivity? = nil) {
        self.refreshActivity = refreshActivity
        self.team = team
        teamModel = BehaviorRelay(value: TeamHistoryViewModel(title: team.title, betsCount: 0, amount: 0))
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen).subscribe {[weak self] _ in
                    self?.updateData()
        }.disposed(by: disposeBag)
    }
    
    
    func updateData() {
        refreshActivity?(true)
        DispatchQueue.global(qos: .background).async {[weak self] in
            defer { self?.refreshActivity?(false) }
            guard let self = self else { return }
            
            let allBets: [Bet] = Repository.select(Bet.table.filter(Bet.homeTeamIdField == team.id
                                                                         || Bet.team2IdField == team.id)
                                                    .order(Bet.eventDateField.desc))
            let activeBets = allBets.filter { $0.isActive }.sorted { $0.eventDate < $01.eventDate }
            let betTypes: [BetType] = AppSettings.isAuthorized ? Repository.select(BetType.table
                                                                                            .filter(activeBets.compactMap({$0.typeId})
                                                                                            .contains(BetType.idField))) : []
            let bets:[Bet] = allBets.filter { !$0.isActive }
            let teams: [Team] = Repository.select(Team.table)
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
                             resultText:  bet.outcome == nil ? "?" : (bet.result < 0 ? bet.result * -1 : bet.result).formattedString)
            }
            
            let activeGroups = activeBetViewModels.map { bet in
                BetGroup(eventDate: bet.eventDate, active: true, bets: [bet])
            }
            
            let groups = bets.map { $0.eventDate.withoutTimeStamp }.distinct().map { date in
                BetGroup(eventDate: date, active: false, bets: betViewModels.filter { $0.eventDate.withoutTimeStamp == date })
            }
            var amount = 0
            groups.forEach { amount += $0.resaltbetSum }
            self.teamModel.accept(TeamHistoryViewModel(title: self.team.title, betsCount: bets.count, amount: amount))
            self.betGroups.accept(groups)
            self.activeBetGroups.accept(activeGroups)
        }
    }
}

