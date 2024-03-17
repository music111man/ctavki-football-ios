//
//  ForecastViewMpdel.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 17.03.2024.
//

import Foundation

struct ForecastViewModel {
    
    let titleIndex: Int
    let titleCount: Int
    let team1: Team
    let team2: Team
    let bet: Bet
    let betType: BetType
    let betCount1: Int
    let betCount2: Int
    let winCount1: Int
    let winCount2: Int
    let lostCount1: Int
    let lostCount2: Int
    let avg1: Double
    let avg2: Double
    let roi1: Double
    let roi2: Double
    let seria1: Int
    let seria2: Int
}
