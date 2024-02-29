//
//  Faq.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

struct Faq: Decodable {
    @StringDecodable var id: Int
    let question: String
    let answer: String
}
