//
//  AppSettings.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation
import RxCocoa

@propertyWrapper
struct Storage<T> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}



final class AppSettings {
    
    private static let signInMethodKey = "signInMethodKey"
    private static let tokenFoSignInKey = "tokenForSignIn"
    private static let appleJWTKey = "appleJWTKey"
    private static let appleUserEmail = "appleUserEmail"
    private static let appleUserName = "appleUserName"
    
    private init(){}
    
//    public static var isRelease: Bool {
//        #if DEBUG
//        return false
//        #else
//        return true
//        #endif
//    }
    
    static var baseUrl: URL {
        URL(string: "https://leader4015.work/ctavki_football/api")!
    }
    
    static func telegramBotUrl(_ uuid: String) -> URL {
        URL(string: "https://tg.pulse.is/Ctavki_com_bot?start=656da09a90e51fa8e30af51c|uuid=\(uuid)")!
    }

    static  var signInMethod: SignInMethod {
        set {
            switch newValue {
            case .non:
                UserDefaults.standard.setValue(0, forKey: Self.signInMethodKey)
            case let .google(idToken):
                UserDefaults.standard.setValue(1, forKey: Self.signInMethodKey)
                UserDefaults.standard.setValue(idToken, forKey: Self.tokenFoSignInKey)
            case let .telegram(uuid):
                UserDefaults.standard.setValue(2, forKey: Self.signInMethodKey)
                UserDefaults.standard.setValue(uuid, forKey: Self.tokenFoSignInKey)
            case .apple(let idToken, let jwt, let userName, let userEmail):
                UserDefaults.standard.setValue(3, forKey: Self.signInMethodKey)
                UserDefaults.standard.setValue(idToken, forKey: Self.tokenFoSignInKey)
                UserDefaults.standard.setValue(jwt, forKey: Self.appleJWTKey)
                if !userName.isEmpty {
                    UserDefaults.standard.setValue(userName, forKey: Self.appleUserName)
                }
                if !userEmail.isEmpty {
                    UserDefaults.standard.setValue(userEmail, forKey: Self.appleUserEmail)
                }
            case .singOut:
                UserDefaults.standard.setValue(4, forKey: Self.signInMethodKey)
            }
        }
        get {
            let method =  UserDefaults.standard.integer(forKey: Self.signInMethodKey)
            switch method {
            case 1:
                if let token = UserDefaults.standard.string(forKey: Self.tokenFoSignInKey) {
                    return .google(idToken: token)
                }
                break
            case 2:
                if let token = UserDefaults.standard.string(forKey: Self.tokenFoSignInKey) {
                    return .telegram(uuid: token)
                }
            case 3:
                if let token = UserDefaults.standard.string(forKey: Self.tokenFoSignInKey),
                 let jwt = UserDefaults.standard.string(forKey: Self.appleJWTKey) {
                    let userName = UserDefaults.standard.string(forKey: Self.appleUserName) ?? ""
                    let userEmail = UserDefaults.standard.string(forKey: Self.appleUserEmail) ?? ""
                    return .apple(idToken: token, jwt: jwt, userName: userName, userEmail: userEmail)
                }
            case 4:
                return .singOut
            default:
                break
            }
            
            return .non
            
        }
    }
    
    @Storage(key: "userName", defaultValue: "")
    static var userName: String
    
    static let clientVersion = "1.0"
    
    static let apiKey = "QPejRtrJ9dv7u@8p4hrA4eY!P3XYyu"
    
    static var locale: String {
        Locale.current.identifier.split(separator: "_").first?.lowercased() ?? "en"
    }
    
    static let platform = "ios"
    
    @Storage(key: "lastLocaleThenUpdate", defaultValue: Locale.current.identifier)
    static var lastLocaleThenUpdate: String
    
    @Storage(key: "lastTimeSynced", defaultValue: "")
    static var lastTimeSynced: String
    
    static var lastTimeForUpdate: String {
        
        return Locale.current.identifier != Self.lastLocaleThenUpdate ? "" : Self.lastTimeSynced
    }
    
    @Storage(key: "fcmToken", defaultValue: "")
    static var fcmToken: String
    
    static var syncInterval: TimeInterval { 60.0 * 5 }
    
    @Storage(key: "defaultFreeBetsCount", defaultValue: 0)
    static var defaultFreeBetsCount: Int
    
    @Storage(key: "giftFreeBetsCount", defaultValue: 0)
    static var giftFreeBetsCount: Int
    
    @Storage(key: "userBetsLeft", defaultValue: 0)
    static var userBetsLeft: Int
    
    @Storage(key: "isSubscribedToTgChannel", defaultValue: false)
    static var isSubscribedToTgChannel: Bool

    static var userToken: String {
        get {
            return UserDefaults.standard.string(forKey: "userToken") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userToken")
            lastTimeSynced = ""
            authorizeEvent.accept(!newValue.isEmpty)
        }
    }
    
    @Storage(key: "enableSignOut", defaultValue: false)
    static var enableSignOut: Bool
    
    static var isAuthorized: Bool {
        !Self.userToken.isEmpty
    }
    @Storage(key: "needTourGuidShow1", defaultValue: true)
    static var needTourGuidShow: Bool
    
    static var authorizeEvent = BehaviorRelay<Bool>(value: !userToken.isEmpty)
}
