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

struct ActualBetVModel {
    let homeTeam: Team?
    let goustTeam: Team?
    let result: String
    
}

struct BetSection {
    
}

final class BetsViewModel {
    let disposeBag = DisposeBag()
    var actualBetList = BehaviorRelay<[ActualBetVModel]>(value: [])
    
    init() {
        NotificationCenter.default.rx.notification(Notification.Name.wasSyncBetData).subscribe {[weak self] _ in
            self?.updateData()
        }.disposed(by: disposeBag)
    }
    
    func updateData() {
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let self = self else { return }
            let bets:[Bet] = Repository.selectData(Bet.table.where(Bet.typeIdField == nil).order(Bet.eventDateField.desc))
            let teams: [Team] = Repository.selectData(Team.table)
            let betTypes: [BetType] = Repository.selectData(BetType.table.filter(bets.compactMap({$0.typeId}).contains(BetType.idField)))
            
            actualBetList.accept(bets.map { bet in
                ActualBetVModel(homeTeam: teams.first(where: { team in team.id == bet.homeTeamId }),
                                goustTeam: teams.first(where: { team in team.id == bet.team2Id }),
                                result: betTypes.first(where: { type in
                                                                    type.id == bet.typeId
                                                                })?.shortTitle ?? String(format: "%2.2f", bet.factor ?? 0))})
        }
    }
}
