//
//  ResponseData.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

struct ApiResponseData: Decodable {
    let code: Int
    let appupdate: AppUpdateAvailable
    @StringDecodable 
    var defaultFreeBetsCount: Int
    @StringDecodable
    var giftFreeBetsCount: Int
    let newLastTimeDataUpdated: String
    @IntOrStringDecodable
    var userBetsLeft: Int
    @IntToBoolDecodable
    var isSubscribedToTgChannel: Bool
    
    let betTypes: [BetType]
    let teams: [Team]
    let faqs: [Faq]
    let bets: [Bet]
    
}
