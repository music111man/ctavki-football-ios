//
//  AppSettings.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

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
        Locale.current.identifier
    }
    
    @Storage(key: "lastTimeSynced", defaultValue: "")
    static var lastTimeSynced: String
    
    @Storage(key: "fcmToken", defaultValue: "")
    static var fcmToken: String
}
