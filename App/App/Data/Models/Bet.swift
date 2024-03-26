//
//  Bet.swift
//  App
//
//  Created by Denis Shkultetskyy on 28.02.2024.
//

import Foundation
import UIKit
import SQLite

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
    
    var isActive: Bool {
        outcome == nil && eventDate > Date().matchTime
    }
    
    var result: Double {
        guard let outcome = self.outcome, let factor = self.factor, outcome != .return else { return 0 }
        
        return outcome == .lost ? -100 : factor.winCalcValue
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

extension Bet: DBComparable {
    init(row: SQLite.Row) {
        self._id = StringDecodable(row[Self.idField])
        self._eventDate = StringDateDecodable(row[Self.eventDateField])
        self._team1Id = StringDecodable(row[Self.team1IdField])
        self._team2Id = StringDecodable(row[Self.team2IdField])
        self._homeTeamId = StringDecodable(row[Self.homeTeamIdField])
        self._typeId = MutableStringDecodable(row[Self.typeIdField])
        self._typeArg = MutableStringDecodable(row[Self.typeArgField])
        self._factor = MutableStringDecodable(row[Self.factorField])
        self.outcome = BetOutcome.init(rawValue: row[Self.outcomeField] ?? "")
        self._reliability = StringDecodable(row[Self.reliabilityField])
    }
    
   
    static var table: Table { Table("bets") }
    
    static var idField: Expression<Int> { Expression<Int>(CodingKeys.id.rawValue) }
    static var eventDateField: Expression<Date> { Expression<Date>(CodingKeys.eventDate.rawValue) }
    static var team1IdField: Expression<Int> { Expression<Int>(CodingKeys.team1Id.rawValue) }
    static var team2IdField: Expression<Int> { Expression<Int>(CodingKeys.team2Id.rawValue) }
    static var homeTeamIdField: Expression<Int> { Expression<Int>(CodingKeys.homeTeamId.rawValue) }
    static var typeIdField: Expression<Int?> { Expression<Int?>(CodingKeys.typeId.rawValue) }
    static var typeArgField: Expression<Double?> { Expression<Double?>(CodingKeys.typeArg.rawValue) }
    static var factorField: Expression<Double?> { Expression<Double?>(CodingKeys.factor.rawValue) }
    static var outcomeField: Expression<String?> { Expression<String?>(CodingKeys.outcome.rawValue) }
    static var reliabilityField: Expression<Int> { Expression<Int>(CodingKeys.reliability.rawValue) }
    
    static func createColumns(builder: SQLite.TableBuilder) {
        builder.column(Self.idField, primaryKey: true)
        builder.column(eventDateField)
        builder.column(team1IdField)
        builder.column(team2IdField)
        builder.column(homeTeamIdField)
        builder.column(typeIdField)
        builder.column(typeArgField)
        builder.column(factorField)
        builder.column(outcomeField)
        builder.column(reliabilityField)
    }
    
    var setters: [Setter] {
        [
            Self.idField <- id,
            Self.eventDateField <- eventDate,
            Self.team1IdField <- team1Id,
            Self.team2IdField <- team2Id,
            Self.homeTeamIdField <- homeTeamId,
            Self.typeIdField <- typeId,
            Self.typeArgField <- typeArg,
            Self.factorField <- factor,
            Self.outcomeField <- outcome?.rawValue,
            Self.reliabilityField <- reliability
        ]
    }
}
