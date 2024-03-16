//
//  AccounResponseData.swift
//  App
//
//  Created by Denis Shkultetskyy on 14.03.2024.
//

import Foundation

struct SignInResponseEntity: Decodable {
    let code: Int
    let msg: String
    @StringDecodable
    var userId: Int
    let email: String
    let name: String
    @StringDecodable
    var betsLeft: Int
    let alreadyRegistered: Int
    let subscribed: Int?
    let jwt: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case userId = "user_id"
        case email
        case name
        case betsLeft
        case alreadyRegistered
        case subscribed
        case jwt
    }
}
