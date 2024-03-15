//
//  JSONWrapHelpers.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

@propertyWrapper
struct StringDecodable<Wrapped: LosslessStringConvertible>: Decodable {
    let wrappedValue: Wrapped

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let value = Wrapped(string) {
            wrappedValue = value
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Value \(string) is not convertible to \(Wrapped.self)"
            )
        }
    }
    init(_ value: Wrapped) {
        wrappedValue = value
    }
}

@propertyWrapper
struct MutableStringDecodable<Wrapped: LosslessStringConvertible>: Decodable {
    var wrappedValue: Wrapped?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = nil
        } else {
            let string = try container.decode(String.self)
            if let value = Wrapped(string) {
                wrappedValue = value
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Value \(string) is not convertible to \(Wrapped.self)"
                )
            }
        }
    }
    
    init(_ value: Wrapped?) {
        wrappedValue = value
    }
}

@propertyWrapper
struct IntOrStringDecodable: Decodable {
    let wrappedValue: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let valInt = try? container.decode(Int.self) {
            wrappedValue = valInt
            return
        }
        if let valString = try? container.decode(String.self), let valInt = Int(valString) {
            wrappedValue = valInt
            return
        }
        wrappedValue = 0
    }
    
    init(_ value: Int) {
        wrappedValue = value
    }
}

@propertyWrapper
struct IntToBoolDecodable: Decodable {
    let wrappedValue: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Int.self) > 0
    }
    
    init(_ value: Bool) {
        wrappedValue = value
    }
}

@propertyWrapper
struct StringDateDecodable: Decodable {
    let wrappedValue: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        wrappedValue = Date(timeIntervalSince1970: Double(str) ?? 0)
    }
    init(_ value: Date) {
        wrappedValue = value
    }
}
