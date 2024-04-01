//
//  TeamsService.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import Foundation
import RxSwift
import RxCocoa

struct TeamsViewModel {
    internal init(title: String, teams: [TeamViewModel]) {
        self.title = title
        self.teams = teams
    }
    
    let title: String
    let teams: [TeamViewModel]
    
    init(_ title: String,
         _ teams: [TeamViewModel],
         _ activeBets: [Bet], _ filter: @escaping(_ count: Int) -> Bool) {
        self.title = title
        self.teams = teams.filter { team in
            let id = team.team.id
            return filter(team.betCount) && !activeBets.contains(where: {$0.team1Id == id || $0.team2Id == id })
        }.sorted(by: {$0.betCount > $1.betCount})
    }
}

struct TeamViewModel {
    let betCount: Int
    let team: Team
    var toString: String{
        team.title
    }
}

final class TeamsService {
    typealias RefreshActivity = () -> ()
    
    let disposeBag = DisposeBag()
    
    func load() -> Single<[TeamsViewModel]> {
        let queryBets: Observable<[Bet]> = Repository.selectObservable(Bet.table.order(Bet.eventDateField.desc))
        let queryTeams: Observable<[Team]> = Repository.selectObservable(Team.table)
        return Observable.combineLatest(queryBets, queryTeams) {[weak self] (allBets, teams) -> [TeamsViewModel] in
            let data = self?.createModels(allBets: allBets, teams: teams) ?? []
            
            return data
        }.asSingle()
    }
    
    private func createModels(allBets: [Bet], teams: [Team]) -> [TeamsViewModel] {
        let matchTime = Date().matchTime
        let activeBets = allBets.filter { $0.isActive && $0.eventDate > matchTime }.sorted { $0.eventDate < $01.eventDate }
        let bets:[Bet] = allBets.filter { !$0.isActive }
        let activeTeams = teams.filter { team in
            activeBets.contains(where: { $0.team2Id == team.id || $0.team1Id == team.id })
        }.map {TeamViewModel(betCount: 1, team: $0)}
        
        let teamSet = teams.map { team in
            TeamViewModel(betCount: bets.filter({ $0.team2Id == team.id || $0.team1Id == team.id }).count, team: team)
        }.filter({ $0.betCount > 0 })
        
        var models = [TeamsViewModel]()
        if !activeBets.isEmpty {
            models.append(TeamsViewModel(title: R.string.localizable.with_current_picks(),
                                         teams: activeTeams))
        }
        models.append(TeamsViewModel(R.string.localizable.with_bets_history_n_and_more(15),
                                     teamSet,
                                     activeBets) { $0 >= 15 })
        models.append(TeamsViewModel(R.string.localizable.with_bets_history_n_and_more(10),
                                     teamSet,
                                     activeBets) { $0 >= 10 && $0 < 15 })
        models.append(TeamsViewModel(R.string.localizable.with_bets_history_n_and_more(5),
                                     teamSet,
                                     activeBets) { $0 >= 5 && $0 < 10 })
        models.append(TeamsViewModel(R.string.localizable.with_bets_history_4_and_less(),
                                     teamSet,
                                     activeBets) { $0 < 5 })
        
        return models
    }
}
