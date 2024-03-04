//
//  Team.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation
import SQLite

struct Team: Decodable {
    
    @StringDecodable
    var id: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
    }
}

extension Team: DBComparable {
    init(row: SQLite.Row) {
        _id = StringDecodable(row[Self.idField])
        title = row[Self.titleField]
    }
    
    
    static var table: Table { Table("teams") }
    
    static var idField: Expression<Int> { Expression<Int>(CodingKeys.id.rawValue) }
    static var titleField: Expression<String> { Expression<String>(CodingKeys.title.rawValue) }
    
    static func createColumns(builder: TableBuilder) {
        builder.column(idField, primaryKey: true)
        builder.column(titleField)
    }
    
    var setters: [Setter] {
        [
            Self.idField <- id,
            Self.titleField <- title
        ]
    }
}
