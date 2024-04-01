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
    let result: Double
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
    
    var resaltbetSum: Double {
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

final class BetsService {
    let disposeBag = DisposeBag()
    
    func load() -> Single<[BetSection]> {
        let time = Date()
        let queryBets: Observable<[Bet]> = Repository.selectObservable(Bet.table.order(Bet.eventDateField.desc))
        let queryTeams: Observable<[Team]> = Repository.selectObservable(Team.table)
        return Observable.combineLatest(queryBets, queryTeams) {[weak self] (allBets, teams) -> [BetSection] in
            let data = self?.createData(allBets: allBets, teams: teams) ?? []
            printAppEvent("time=\(-time.timeIntervalSinceNow)", marker: ">>betServ ")
            return data
        }.asSingle()
    }
    
    func createData(allBets: [Bet], teams: [Team]) -> [BetSection] {
        printAppEvent("start update bets data in \(Thread.isMainThread ? "main" : "background")", marker: ">>betServ")
        
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
                         resultText: bet.outcome == nil ? "?" : (bet.result < 0 ? bet.result * -1 : bet.result).roundedString)
        }
        let activeGroups = activeBetViewModels.map { bet in
            BetGroup(eventDate: bet.eventDate, active: true, bets: [bet])
        }
        let groups = bets.map { $0.eventDate.withoutTimeStamp }.distinct().map { date in
            BetGroup(eventDate: date, active: false, bets: betViewModels.filter { $0.eventDate.withoutTimeStamp == date })
        }
        
        let betSections = groups.map({$0.eventDate.withoutDays}).distinct().map {date in
            let filtered = groups.filter { $0.eventDate.withoutDays == date }
            
            return BetSection(eventDate: date.withoutDays, sum: Int(filtered.map { $0.resaltbetSum }.sum.rounded()), bets: filtered)
        }
        return [BetSection(eventDate: nil, sum: nil, bets: activeGroups)] + betSections
    }
}
