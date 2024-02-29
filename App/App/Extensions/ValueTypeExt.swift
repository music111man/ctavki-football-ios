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
}

extension String: PDefaultValue {
    typealias T = String
    static var defaultValue: T {
        ""
    }
}
