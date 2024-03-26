//
//  BetType.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation
import SQLite

struct BetType: Decodable {
    @StringDecodable
    var id: Int
    let shortTitle: String
    let longTitle: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case shortTitle = "short_title"
        case longTitle = "long_title"
        case description
    }
}

extension BetType: DBComparable {
    init(row: SQLite.Row) {
        _id = StringDecodable(row[Self.idField])
        shortTitle = row[Self.shortTitleField]
        longTitle = row[Self.longTitleField]
        description = row[Self.descriptionField]
    }
    
    static var table: Table { Table("bet_types")}
    
    static var idField: Expression<Int> { Expression<Int>(CodingKeys.id.rawValue) }
    static var shortTitleField: Expression<String> { Expression<String>(CodingKeys.shortTitle.rawValue) }
    static var longTitleField: Expression<String> { Expression<String>(CodingKeys.longTitle.rawValue) }
    static var descriptionField: Expression<String> { Expression<String>(CodingKeys.description.rawValue) }
    
    static func createColumns(builder: SQLite.TableBuilder) {
        builder.column(idField, primaryKey: true)
        builder.column(shortTitleField)
        builder.column(longTitleField)
        builder.column(descriptionField)
    }
    
    var setters: [Setter] {
        [
            Self.idField <- id,
            Self.shortTitleField <- shortTitle,
            Self.longTitleField <- longTitle,
            Self.descriptionField <- description
        ]
    }
}
