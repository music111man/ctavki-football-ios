//
//  ForecastService.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 17.03.2024.
//

import Foundation
import RxSwift
import RxCocoa
import SQLite

final class ForecastService {
    
    var betId: Int!
    
    let disposeBag = DisposeBag()
    
    let model = PublishRelay<ForecastViewModel>()
    
    func loadData() {
        DispatchQueue.global(qos: .userInteractive).async {[weak self] in
            guard let self = self,
                  let bet: Bet = Repository.selectTop(Bet.table.filter(Bet.idField == self.betId)),
                  let typeId = bet.typeId,
                  let betType: BetType = Repository.selectTop(BetType.table.filter(BetType.idField == typeId))
                    else { return }

            let activeBets: [Bet] = Repository.select(Bet.table.filter( Bet.outcomeField == nil
                                                                        && Bet.eventDateField > Date().matchTime ).order(Bet.eventDateField))
            let teams: [Team] = Repository.select(Team.table.where([bet.team1Id, bet.team2Id].contains(Team.idField)))
            guard teams.count == 2,
                    let team1 = teams.first(where: { $0.id == bet.team1Id }),
                    let team2 = teams.first(where: { $0.id == bet.team2Id }) else { return }
            let filter1 = Bet.table.filter(Bet.team1IdField == team1.id || Bet.team2IdField == team1.id)
            let filter2 = Bet.table.filter(Bet.team1IdField == team2.id || Bet.team2IdField == team2.id)
            let betCount1 = Repository.count(filter1)
            let betCount2 = Repository.count(filter2)
            let winCount1 = Repository.count(filter1.where(Bet.outcomeField == BetOutcome.won.rawValue))
            let winCount2 = Repository.count(filter2.where(Bet.outcomeField == BetOutcome.won.rawValue))
            let lostCount1 = Repository.count(filter1.where(Bet.outcomeField == BetOutcome.lost.rawValue))
            let lostCount2 = Repository.count(filter2.where(Bet.outcomeField == BetOutcome.lost.rawValue))
            let avg1: Double? = try? Repository.db?.scalar(filter1.select(Bet.factorField.average))
            let avg2: Double? = try? Repository.db?.scalar(filter2.select(Bet.factorField.average))
            var titleIndex = 0
            for b in activeBets {
                titleIndex += 1
                if b.id == self.betId { break }
            }
            model.accept(ForecastViewModel(titleIndex: titleIndex, 
                                           titleCount: activeBets.count,
                                           team1: team1,
                                           team2: team2,
                                           bet: bet,
                                           betType: betType,
                                           betCount1: betCount1,
                                           betCount2: betCount2,
                                           winCount1: winCount1,
                                           winCount2: winCount2,
                                           lostCount1: lostCount1,
                                           lostCount2: lostCount2,
                                           avg1: avg1 ?? 0,
                                           avg2: avg2 ?? 0,
                                           roi1: 0,
                                           roi2: 0,
                                           seria1: 1,
                                           seria2: 1))
        }
    }
}
