//
//  Sequence.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 18.03.2024.
//

import Foundation
import UIKit

extension Sequence where Iterator.Element: Hashable {
    func distinct() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
protocol Addable: ExpressibleByIntegerLiteral {
    static func + (lhs: Self, rhs: Self) -> Self
}

extension Int   : Addable {}
extension Double: Addable {}
extension Float: Addable {}
extension CGFloat: Addable {}

extension Sequence where Iterator.Element: Addable {
    var sum: Iterator.Element {
        return reduce(0, +)
    }
}
