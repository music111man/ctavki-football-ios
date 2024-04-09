//
//  ResponseData.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

struct ApiResponseData: Decodable {
    let code: Int
    var appupdate: AppUpdateAvailable?
    //@StringDecodable
    var defaultFreeBetsCount: String?
    //@StringDecodable
    var giftFreeBetsCount: String?
    var newLastTimeDataUpdated: String?
    //@IntOrStringDecodable
    //var userBetsLeft: String?
    //@IntToBoolDecodable
    var isSubscribedToTgChannel: Int?
    
    let betTypes: [BetType]?
    let teams: [Team]?
    let faqs: [Faq]?
    let bets: [Bet]?
    
}
