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
    
    @SecureString("tokenFoSignIn")
    static var tokenFoSignIn: String?
    @SecureString("appleUserName")
    static var appleUserName: String?
    @SecureString("appleUserEmail")
    static var appleUserEmail: String?
    @Storage(key: "signInMethod", defaultValue: 0)
    static var signInMethod: Int
    
    

    static  var signMethod: SignMethod {
        set {
            switch newValue {
            case .non:
                Self.signInMethod = 0
                Self.tokenFoSignIn = nil
            case let .google(idToken):
                Self.signInMethod = 1
                Self.tokenFoSignIn = idToken
            case let .telegram(uuid):
                Self.signInMethod = 2
                Self.tokenFoSignIn = uuid
            case .apple(let idToken, let userName, let userEmail):
                Self.signInMethod = 3
                Self.tokenFoSignIn = idToken
                if !userName.isEmpty {
                    Self.appleUserName = userName
                }
                if !userEmail.isEmpty {
                    Self.appleUserEmail = userEmail
                }
            case .singOutFromApple:
                Self.signInMethod = 4
            }
        }
        get {
            guard let tokenFoSignIn = Self.tokenFoSignIn else { return Self.signInMethod == 4 ? .singOutFromApple : .non }
            switch Self.signInMethod {
            case 1: 
                return .google(idToken: tokenFoSignIn)
            case 2: 
                return .telegram(uuid: tokenFoSignIn)
            case 3:
                let userName = Self.appleUserName ?? ""
                let userEmail = Self.appleUserEmail ?? ""
                return .apple(idToken: tokenFoSignIn, userName: userName, userEmail: userEmail)
                
            case 4:
                return .singOutFromApple
            default:
                break
            }
            
            return .non
            
        }
    }
    
    
    
    
    @Storage(key: "userName", defaultValue: "")
    static var userName: String
    
    static let clientVersion = "2.0.0"
    
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
    
    @SecureString("userToken")
    static var secureToken: String?

    @Storage(key: "wasSignIn", defaultValue: false)
    private static var wasSignIn: Bool
    
    static var userToken: String {
        get {
            return wasSignIn ? (Self.secureToken ?? "") : ""
        }
        set {
            Self.secureToken = newValue
            wasSignIn = true
            lastTimeSynced = ""
            userName = ""
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
