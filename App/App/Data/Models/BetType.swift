//
//  BetType.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

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
