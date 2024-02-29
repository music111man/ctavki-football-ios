//
//  Bet.swift
//  App
//
//  Created by Denis Shkultetskyy on 28.02.2024.
//

import Foundation
import UIKit

struct Bet: Decodable {
    @StringDecodable
    var id: Int
    @StringDateDecodable
    var eventDate: Date
    @StringDecodable
    var team1Id: Int
    @StringDecodable
    var team2Id: Int
    @StringDecodable
    var homeTeamId: Int
    @MutableStringDecodable
    var typeId: Int?
    @MutableStringDecodable
    var typeArg: Double?
    @MutableStringDecodable
    var factor: Double?
    let outcome: BetOutcome?
    @StringDecodable
    var reliability: Int
    
    var isOpened: Bool {
        typeId != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventDate = "event_date"
        case team1Id = "team1_id"
        case team2Id = "team2_id"
        case homeTeamId = "home_team_id"
        case typeId = "type_id"
        case typeArg = "type_arg"
        case factor
        case outcome = "outcome_id"
        case reliability
    }
}
