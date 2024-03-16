//
//  Account.swift
//  App
//
//  Created by Denis Shkultetskyy on 14.03.2024.
//

import Foundation
import SQLite

struct Account {
    let id: Int
    let email: String
    let name: String
    let betsLeft: Int
    let alreadyRegistered: Int
    let subscribed: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case betsLeft
        case alreadyRegistered
        case subscribed
    }
}

extension Account: DBComparable {
    init(row: SQLite.Row) {
        id = row[Self.idField]
        email = row[Self.emailField]
        name = row[Self.nameField]
        betsLeft = row[Self.betsLeftField]
        alreadyRegistered = row[Self.alreadyRegisteredField]
        subscribed = row[Self.subscribedField]
    }
    
    
    static var table: Table { Table("account") }
    
    static var idField: Expression<Int> { Expression<Int>(CodingKeys.id.rawValue) }
    static var emailField: Expression<String> { Expression<String>(CodingKeys.email.rawValue) }
    static var nameField: Expression<String> { Expression<String>(CodingKeys.name.rawValue) }
    static var betsLeftField: Expression<Int> {
        Expression<Int>(CodingKeys.betsLeft.rawValue) }
    static var alreadyRegisteredField: Expression<Int> { Expression<Int>(CodingKeys.alreadyRegistered.rawValue) }
    static var subscribedField: Expression<Int?> { Expression<Int?>(CodingKeys.subscribed.rawValue) }
    
    static func createColumns(builder: TableBuilder) {
        builder.column(idField, primaryKey: true)
        builder.column(emailField)
        builder.column(nameField)
        builder.column(betsLeftField)
        builder.column(alreadyRegisteredField)
        builder.column(subscribedField)
    }
    
    var setters: [Setter] {
        [
            Self.idField <- id,
            Self.emailField <- email,
            Self.nameField <- name,
            Self.betsLeftField <- betsLeft,
            Self.alreadyRegisteredField <- alreadyRegistered,
            Self.subscribedField <- subscribed
        ]
    }
}
