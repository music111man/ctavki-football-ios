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

    func load() -> Single<ForecastViewModel?> {
        let time = Date()
        let betQ: Observable<Bet?> = Repository.selectTopObservable(Bet.table.filter(Bet.idField == self.betId))
        let activeBetsQ: Observable<[Bet]> = Repository.selectObservable(Bet.table.filter( Bet.outcomeField == nil
                                                                                           && Bet.eventDateField > Date().matchTime ).order(Bet.eventDateField))
        
        return Observable.combineLatest(betQ, activeBetsQ).flatMap { (bet, activeBets) -> Observable<ForecastViewModel?> in
            guard let bet = bet, let typeId = bet.typeId else {
                return .just(nil)
            }
            let betType: Observable<BetType?> = Repository.selectTopObservable(BetType.table.filter(BetType.idField == typeId))
            let teams: Observable<[Team]> = Repository.selectObservable(Team.table.where([bet.team1Id, bet.team2Id].contains(Team.idField)))

            return Observable.combineLatest(Observable.just(bet),Observable.just(activeBets), betType, teams)
                .flatMap { (bet, activeBets, betType, teams) -> Observable<ForecastViewModel?> in
                    guard teams.count == 2,
                          let betType = betType,
                          let team1 = teams.first(where: { $0.id == bet.team1Id }),
                          let team2 = teams.first(where: { $0.id == bet.team2Id }) else { return .just(nil) }
                    let filter1 = Bet.table.filter(Bet.team1IdField == team1.id || Bet.team2IdField == team1.id)
                        .filter(Bet.outcomeField != nil)
                    let filter2 = Bet.table.filter(Bet.team1IdField == team2.id || Bet.team2IdField == team2.id)
                        .filter(Bet.outcomeField != nil)
                    let bets1: Observable<[Bet]> = Repository.selectObservable(filter1.order(Bet.eventDateField.desc))
                    let bets2: Observable<[Bet]> = Repository.selectObservable(filter2.order(Bet.eventDateField.desc))
                    let winCount1: Observable<Int> = Repository.countObservable(filter1.where(Bet.outcomeField == BetOutcome.won.rawValue))
                    let winCount2: Observable<Int> = Repository.countObservable(filter2.where(Bet.outcomeField == BetOutcome.won.rawValue))
                    let lostCount1: Observable<Int> = Repository.countObservable(filter1.where(Bet.outcomeField == BetOutcome.lost.rawValue))
                    let lostCount2: Observable<Int> = Repository.countObservable(filter2.where(Bet.outcomeField == BetOutcome.lost.rawValue))
                    let avg1: Observable<Double?> = Repository.scalarObservable(filter1.select(Bet.factorField.average))
                    let avg2: Observable<Double?> = Repository.scalarObservable(filter2.select(Bet.factorField.average))
                    let latest1 = Observable.combineLatest(Observable.just(bet), Observable.just(activeBets),
                                                           Observable.just(betType), Observable.just(team1), Observable.just(team2))
                    let latest2 = Observable.combineLatest(bets1, bets2, winCount1, winCount2, lostCount1, lostCount2, avg1, avg2)
                    return Observable.combineLatest(latest1, latest2)
                    .flatMap { (res1, res2) -> Observable<ForecastViewModel?> in
                        let bet = res1.0
                        let activeBets = res1.1
                        let betType = res1.2
                        let team1 = res1.3
                        let team2 = res1.4
                        let bets1 = res2.0
                        let bets2 = res2.1
                        let winCount1 = res2.2
                        let winCount2 = res2.3
                        let lostCount1 = res2.4
                        let lostCount2 = res2.5
                        let avg1 = res2.6 ?? 0
                        let avg2 = res2.7 ?? 0
                        let roi1 = bets1.isEmpty ? 0 : bets1.map {$0.result}.sum / Double(bets1.count)
                        let roi2 = bets2.isEmpty ? 0 : bets2.map {$0.result}.sum / Double(bets2.count)
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
                            
                        let model = ForecastViewModel(titleIndex: titleIndex,
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
                                                 avg1: avg1,
                                                 avg2: avg2,
                                                 roi1: roi1,
                                                 roi2: roi2,
                                                 seria1: seria1,
                                                 seria2: seria2)
                        printAppEvent("time=\(-time.timeIntervalSinceNow)", marker: ">>forcastServ RX ")
                        return .just(model)
                    }
                }
        }.asSingle()
    }
}
