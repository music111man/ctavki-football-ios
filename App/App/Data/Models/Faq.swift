//
//  Faq.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation
import SQLite

struct Faq: Decodable {
    
    @StringDecodable
    var id: Int
    let question: String
    let answer: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case question
        case answer
    }
}

extension Faq: DBComparable {
    init(row: SQLite.Row) {
        _id = StringDecodable(row[Self.idField])
        question = row[Self.questionField]
        answer = row[Self.answerField]
    }
    
    
    static var table: Table { Table("faqs") }
    
    static var idField: Expression<Int> { Expression<Int>(CodingKeys.id.rawValue) }
    static var questionField: Expression<String> { Expression<String>(CodingKeys.question.rawValue) }
    static var answerField: Expression<String> { Expression<String>(CodingKeys.answer.rawValue) }
    
    static func createColumns(builder: SQLite.TableBuilder) {
        builder.column(idField, primaryKey: true)
        builder.column(questionField)
        builder.column(answerField)
    }
    
    var setters: [Setter] {
        [
            Self.idField <- id,
            Self.questionField <- question,
            Self.answerField <- answer
        ]
    }
}
