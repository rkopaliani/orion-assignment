//
//  Optionals+Auxiliary.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Foundation

extension Optional {

    /// Builds description string of a generic optional.
    ///
    /// - parameter nil: Optional "nil" value.
    /// - returns: Either some `"\(value)"`, or `nil` argument.
    ///
    /// Example outputs:
    /// ```
    /// var value: Bool?
    /// print("\(value.description())")         // → nil
    /// print("\(value.description(nil: "-"))") // → -
    ///
    /// value = true
    /// print("\(value.description())")         // → true
    /// ```
    ///
    /// Note! There are specifications for some wrapped types,
    /// like for `Date` and `StringProtocol`.
    ///
    public func description(nil none: String = "nil") -> String {

        switch self {
        case .none: return none
        case let .some(value): return "\(value)"
        }
    }
}

extension Optional where Wrapped: StringProtocol {

    /// Builds description of an optional string.
    /// Non-nil value is wrapped in single quotes.
    ///
    /// - parameter nil: Optional "nil" value.
    /// - returns: Either some `"'\(text)'"`, or `nil` argument.
    ///
    /// Example outputs:
    /// ```
    /// var text: String?
    /// print("\(text.description())")          // → nil
    /// print("\(text.description(nil: "-"))")  // → -
    ///
    /// text = "Foo Bar"
    /// print("\(text.description())")          // → 'Foo Bar'
    /// ```
    ///
    public func description(nil none: String = "nil") -> String {

        switch self {
        case .none: return none
        case let .some(value): return "'\(value)'"
        }
    }
}

extension Optional where Wrapped == Date {

    /// Builds description of an optional string.
    /// Non-nil value is wrapped in single quotes.
    ///
    /// - parameter nil: Optional "nil" value.
    /// - returns: Either some `"'\(date)'"`, or `nil` argument.
    ///
    /// Example outputs:
    /// ```
    /// var date: Date?
    /// print("\(date.description())")          // → nil
    /// print("\(date.description(nil: "-"))")  // → -
    ///
    /// date = Date()
    /// print("\(date.description())")          // → '2021-12-13 06:47:56 +0000'
    /// ```
    ///
    public func description(nil none: String = "nil") -> String {

        switch self {
        case .none: return none
        case let .some(value): return "'\(value)'"
        }
    }
}

extension Optional where Wrapped: CustomDebugStringConvertible {

    /// Builds DEBUG description string of a generic optional.
    ///
    /// - parameter nil: Optional "nil" value.
    /// - returns: Either some `value.debugDescription`, or `nil` argument.
    ///
    /// Example outputs:
    /// ```
    /// struct Test: CustomDebugStringConvertible {
    ///
    ///     var debugDescription: String { "foo bar" }
    /// }
    /// var value: Test?
    ///
    /// print("\(value.description())")         // → nil
    /// print("\(value.description(nil: "-"))") // → -
    ///
    /// value = Test()
    /// print("\(value.description())")         // → foo bar
    /// ```
    ///
    public func debugDescription(nil none: String = "nil") -> String {

        switch self {
        case .none: return none
        case let .some(value): return value.debugDescription
        }
    }
}
