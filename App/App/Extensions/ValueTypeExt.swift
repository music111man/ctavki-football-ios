//
//  ValueTypeExt.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

protocol PDefaultValue {
    associatedtype T
    static var defaultValue: T { get }
}

extension Int: PDefaultValue {
    typealias T = Int
    static var defaultValue: Int {
        0
    }
}

extension Double {
    typealias T = Double
    static var defaultValue: T {
        0.0
    }
    
    var formattedString: String {
        String(format: "%2.2f", self)
    }
}

extension String: PDefaultValue {
    typealias T = String
    static var defaultValue: T {
        ""
    }
}

extension Sequence where Iterator.Element: Hashable {
    func distinct() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension Date {
    public var withoutTimeStamp : Date {
       Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self))!
    }
    
    public var withoutDays : Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    var monthAsString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: self)
    }
    
    func format(_ formatString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        
        return formatter.string(from: self)
    }
}
