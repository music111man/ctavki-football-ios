//
//  BetOutcome.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

enum BetOutcome: String, Decodable {
    case won = "1"
    case lost = "2"
    case `return` = "3"
}
