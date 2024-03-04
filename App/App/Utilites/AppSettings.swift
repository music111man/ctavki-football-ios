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
    
    static var baseUrl: URL {
        URL(string: "https://leader4015.work/ctavki_football/api")!
    }
    
    static let clientVersion = "2.0"
    
    static let apiKey = "QPejRtrJ9dv7u@8p4hrA4eY!P3XYyu"
    
    static var locale: String {
        Locale.current.identifier.split(separator: "_").first?.lowercased() ?? "en"
    }
    
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
            isAutorized.accept(newValue.isEmpty)
        }
    }
    
    static var isAutorized = BehaviorRelay<Bool>(value: !userToken.isEmpty)
}
