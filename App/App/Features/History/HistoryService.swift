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
        }
    }
    let teamModel: BehaviorRelay<TeamHistoryViewModel>
    let betGroups = BehaviorRelay<[BetGroup]>(value: [])
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
            guard let self = self else { return }
            self.teamModel.accept(TeamHistoryViewModel(title: self.team.title, betsCount: 0, amount: 0))
            let bets: [Bet] = Repository.selectData(Bet.table.filter((Bet.homeTeamIdField == team.id
                                                                         || Bet.team2IdField == team.id)
                                                                        && Bet.outcomeField != nil)
                                                    .order(Bet.eventDateField.desc))
            let teams: [Team] = Repository.selectData(Team.table)
            let betViewModels = bets.map { bet in
                BetViewModel(id: bet.id,
                             result: bet.result,
                             eventDate: bet.eventDate,
                             betOutCome: bet.outcome,
                             homeTeam: teams.first(where: { team in team.id == bet.homeTeamId }),
                             goustTeam: teams.first(where: { team in team.id == bet.team2Id }),
                             resultText: "\(bet.result)")
            }
            
            let groups = bets.map { $0.eventDate.withoutTimeStamp }.distinct().map { date in
                BetGroup(eventDate: date, active: false, bets: betViewModels.filter { $0.eventDate.withoutTimeStamp == date })
            }
            var amount = 0
            groups.forEach { amount += $0.resaltbetSum }
            self.teamModel.accept(TeamHistoryViewModel(title: self.team.title, betsCount: bets.count, amount: amount))
            self.betGroups.accept(groups)
            self.refreshActivity?(false)
        }
    }
}

