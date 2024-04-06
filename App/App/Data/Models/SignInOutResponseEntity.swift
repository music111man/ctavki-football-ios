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
    var userId: String?
    let email: String?
    let name: String?
    var betsLeft: String?
    let alreadyRegistered: Int?
    let subscribed: Int?
    let jwt: String?
    
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
struct SignOutResponseEntity: Decodable {
    let code: Int
    let msg: String
}
