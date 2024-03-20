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
    
    let needUpdate = PublishRelay<Void>()
    
    init() {
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen).subscribe {[weak self] _ in
            self?.needUpdate.accept(())
            self?.loadData()
        }.disposed(by: disposeBag)
    }
    
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
                                   .filter(Bet.outcomeField != nil)
            let filter2 = Bet.table.filter(Bet.team1IdField == team2.id || Bet.team2IdField == team2.id)
                                   .filter(Bet.outcomeField != nil)
            let bets1: [Bet] = Repository.select(filter1.order(Bet.eventDateField.desc))
            let bets2: [Bet] = Repository.select(filter2.order(Bet.eventDateField.desc))
            let roi1 = bets1.isEmpty ? 0 : bets1.map {$0.result}.sum / Double(bets1.count)
            let roi2 = bets2.isEmpty ? 0 : bets2.map {$0.result}.sum / Double(bets2.count)
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
            var typeTitle = betType.longTitle.regReplace(pattern: "(?i)\\хозяев\\w*", replaceWith: team1.title)
                                             .regReplace(pattern: "(?i)\\гост\\w*", replaceWith: team2.title)
                                             .regReplace(pattern: "(?i)home\\s+team", replaceWith: team1.title)
                                             .regReplace(pattern: "(?i)away\\s+team", replaceWith: team2.title)
            if var typeArg = bet.typeArg {
                if [34, 38].contains(betType.id) {
                    typeArg += 0.5
                } else {
                    typeArg -= 0.5
                }
                typeTitle =  typeTitle.replace("%x%", with: "\(typeArg)")
            }
            var seria1 = 0
            for bet in bets1 {
                if bet.outcome != .won { break }
                seria1 += 1
            }
            var seria2 = 0
            for bet in bets2 {
                if bet.outcome != .won { break }
                seria2 += 1
            }
            model.accept(ForecastViewModel(titleIndex: titleIndex,
                                           titleCount: activeBets.count,
                                           team1: team1,
                                           team2: team2,
                                           bet: bet,
                                           betTypeTitle: typeTitle,
                                           betCount1: bets1.count,
                                           betCount2: bets2.count,
                                           winCount1: winCount1,
                                           winCount2: winCount2,
                                           lostCount1: lostCount1,
                                           lostCount2: lostCount2,
                                           avg1: avg1 ?? 0,
                                           avg2: avg2 ?? 0,
                                           roi1: roi1,
                                           roi2: roi2,
                                           seria1: seria1,
                                           seria2: seria2))
        }
    }
}
