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
    let betGroups: [BetGroup]
}

final class HistoryService {
    typealias RefreshActivity = (Bool) -> ()
    var teamId: Int
    let disposeBag = DisposeBag()
    
    init(teamId: Int) {
        self.teamId = teamId
    }
    
    func load() -> Single<TeamHistoryViewModel?> {
        let teams: Observable<[Team]> = Repository.selectObservable(Team.table)
        let allBets: Observable<[Bet]> = Repository.selectObservable(Bet.table.filter(Bet.homeTeamIdField == self.teamId
                                                                || Bet.team2IdField == self.teamId)
                                                .order(Bet.eventDateField.desc))
        
        return Observable.combineLatest(teams, allBets).map {[weak self](teams, allBets) -> TeamHistoryViewModel? in
            guard let self = self, let team = teams.first(where: {$0.id == self.teamId}) else { return nil }
            
            let activeBets = allBets.filter { $0.isActive }.sorted { $0.eventDate < $01.eventDate }

            let bets:[Bet] = allBets.filter { !$0.isActive }
            
            let activeBetViewModels = activeBets.map { bet in
                BetViewModel(id: bet.id,
                             result: bet.result,
                             eventDate: bet.eventDate,
                             betOutCome: .active,
                             homeTeam: teams.first(where: { team in team.id == bet.team1Id }),
                             goustTeam: teams.first(where: { team in team.id == bet.team2Id }),
                             resultText: bet.factor?.formattedString ?? "0.0")
            }
            let betViewModels = bets.map { bet in
                BetViewModel(id: bet.id,
                             result: bet.result,
                             eventDate: bet.eventDate,
                             betOutCome: bet.outcome ?? .unknow,
                             homeTeam: teams.first(where: { team in team.id == bet.homeTeamId }),
                             goustTeam: teams.first(where: { team in team.id == bet.team2Id }),
                             resultText:  bet.outcome == nil ? "?" : (bet.result < 0 ? bet.result * -1 : bet.result).roundedString)
            }
            
            let activeGroups = activeBetViewModels.map { bet in
                BetGroup(eventDate: bet.eventDate, active: true, bets: [bet])
            }
            
            let groups = bets.map { $0.eventDate.withoutTimeStamp }.distinct().map { date in
                BetGroup(eventDate: date, active: false, bets: betViewModels.filter { $0.eventDate.withoutTimeStamp == date })
            }
            let amount = Int(groups.map { $0.resaltbetSum }.sum.rounded())
            return TeamHistoryViewModel(title: team.title,
                                        betsCount: bets.count,
                                        amount: amount,
                                        betGroups: activeGroups + groups)

        }.asSingle()
    }
}

