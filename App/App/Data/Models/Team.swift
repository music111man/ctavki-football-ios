//
//  Team.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

struct Team: Decodable {
    @StringDecodable var id: Int
    let title: String
}
