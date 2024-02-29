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
}

@propertyWrapper
struct MutableStringDecodable<Wrapped: LosslessStringConvertible>: Decodable {
    let wrappedValue: Wrapped?

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
}

@propertyWrapper
struct IntToBoolDecodable: Decodable {
    let wrappedValue: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Int.self) > 0
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
}
