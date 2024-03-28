//
//  GoogleAnaliticsService.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 28.03.2024.
//

import Foundation
import FirebaseAnalytics
import FirebaseCore

final class GoogleAnaliticsService {
    enum AnaliticsParam {
        case betId(Int)
        
        var toString: String {
            switch self {
            case .betId:
                return "bet_id"
            }
        }
    }
    
    private static let ANALYTICS_EVENT_TAPPED_ON_BET_PUSH = "bet_push_tapped"
    private static let ANALYTICS_EVENT_BET_VISITED = "bet_visited"
    
    private init(){}
    
    static func logTapPush(param: AnaliticsParam) {
        if FirebaseApp.app() == nil {
            fatalError("FirebaseApp.configure() must be call  at start App!!!")
        }
        switch param {
        case let .betId(id):
            let params = [param.toString: id]
            Analytics.logEvent(ANALYTICS_EVENT_TAPPED_ON_BET_PUSH, parameters: params)
            Analytics.logEvent("\(ANALYTICS_EVENT_TAPPED_ON_BET_PUSH)_id\(id)", parameters: nil)
        }
    }
    
    static func logViewVisited(param: AnaliticsParam) {
        if FirebaseApp.app() == nil {
            fatalError("FirebaseApp.configure() must be call at start App!!!")
        }
        switch param {
        case let .betId(id):
            let params = [param.toString: id]
            Analytics.logEvent(ANALYTICS_EVENT_BET_VISITED, parameters: params)
            Analytics.logEvent("\(ANALYTICS_EVENT_BET_VISITED)_id\(id)", parameters: nil)
        }
    }
}
