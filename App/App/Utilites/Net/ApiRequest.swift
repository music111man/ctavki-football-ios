//
//  ApiRequest.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation
import Moya

enum ApiRequest {
    case checkForUpdates
}

extension ApiRequest: TargetType {
    var baseURL: URL {
        AppSettings.baseUrl
    }
    
    var path: String {
        switch self {
        case .checkForUpdates:
            return "check-for-updates.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .checkForUpdates:
            return .get
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Moya.Task {
        switch self {
        case .checkForUpdates:
            return Moya.Task.requestParameters(parameters: ["lastTimeSynced" : AppSettings.lastTimeForUpdate,
                                                            "fcmToken" : AppSettings.fcmToken], 
                                               encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .checkForUpdates:
            return ["ApiKey" : AppSettings.apiKey,
                    "ClientVersion" : AppSettings.clientVersion,
                    "Locale" : AppSettings.locale]
        }
    }
    
    
}
