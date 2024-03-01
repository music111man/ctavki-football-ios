//
//  Faq.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation
import SQLite

struct Faq: Decodable {
    
    @StringDecodable var id: Int
    let question: String
    let answer: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case question
        case answer
    }
    
    
}

extension Faq: DBComparable {
    
    static var table: Table { Table("faqs") }
    
    static var idField: Expression<Int> { Expression<Int>(CodingKeys.id.rawValue) }
    static var questionField: Expression<String> { Expression<String>(CodingKeys.question.rawValue) }
    static var answerField: Expression<String> { Expression<String>(CodingKeys.answer.rawValue) }
    
    static func createTable(db: Connection) throws {
        try db.run(Self.table.create(ifNotExists: true) { table in
            table.column(idField, primaryKey: true)
            table.column(questionField)
            table.column(answerField)
        })
    }
    
    var setters: [Setter] {
        [
            Self.idField <- id,
            Self.questionField <- question,
            Self.answerField <- answer
        ]
    }
}
