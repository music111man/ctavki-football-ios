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
    case signInByTelegram(uuid: String)
    case signInByGoogle(idToken: String)
    case signInByApple(idToken: String, userName: String, userEmail: String)
    case signOut
}

extension ApiRequest: TargetType {
    var baseURL: URL {
        AppSettings.baseUrl
    }
     
    var path: String {
        switch self {
        case .checkForUpdates:
            return "check-for-updates.php"
        case .signInByTelegram:
            return "login/sign-in-with-telegram2.php"
        case .signInByGoogle:
            return "login/sign-in-with-google.php"
        case .signInByApple:
            return "login/sign-in-with-apple.php"
        case .signOut:
            return "login/sign-out.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .checkForUpdates:
            return .get
        case .signInByTelegram, .signInByGoogle, .signInByApple, .signOut:
            return .post
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Moya.Task {
        switch self {
        case .checkForUpdates:
            return Moya.Task.requestParameters(parameters: ["lastTimeSynced" : AppSettings.lastTimeForUpdate,
                                                            "fcmToken": AppSettings.fcmToken],
                                               encoding: URLEncoding.default)
        case let .signInByTelegram(uuid):
            return Moya.Task.requestParameters(parameters: ["uuid": uuid,
                                                            "fcmToken": AppSettings.fcmToken],
                                               encoding: JSONEncoding.default)
        case let .signInByGoogle(idToken):
            return Moya.Task.requestParameters(parameters: ["idToken": idToken,
                                                           "fcmToken": AppSettings.fcmToken],
                                               encoding: JSONEncoding.default)
        case .signInByApple(let idToken, let userName, let userEmail):
            return Moya.Task.requestParameters(parameters: ["idToken": idToken,
                                                            "user_name": userName,
                                                            "user_email": userEmail,
                                                           "fcmToken": AppSettings.fcmToken],
                                               encoding: JSONEncoding.default)
        case .signOut:
            return Moya.Task.requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .checkForUpdates, .signOut:
            return ["ApiKey" : AppSettings.apiKey,
                    "Authorization" : AppSettings.userToken,
                    "ClientVersion" : AppSettings.clientVersion,
                    "Locale" : AppSettings.locale,
                    "PLATFORM" : AppSettings.platform]
        case .signInByTelegram, .signInByGoogle, .signInByApple:
            return ["ApiKey" : AppSettings.apiKey,
                    "ClientVersion" : AppSettings.clientVersion,
                    "Locale" : AppSettings.locale,
                    "PLATFORM" : AppSettings.platform]
        }
    }
    
    
}
