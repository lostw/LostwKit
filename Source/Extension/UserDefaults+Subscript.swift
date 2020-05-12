//
//  UserDefaults+Subscript.swift
//  HealthTaiZhou
//
//  Created by William on 2019/10/28.
//  Copyright © 2019 Wonders. All rights reserved.
//

import Foundation

// MARK: - subscript
public extension UserDefaults {
    struct Key<Type> {
        public var name: String

        public init(name: String) {
            self.name = name
        }
    }

    static subscript(key: String) -> Any? {
        get {
            UserDefaults.standard.value(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    static subscript<Type>(key: Key<Type>) -> Type? {
        get {
            UserDefaults.standard.value(forKey: key.name) as? Type
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key.name)
        }
    }

    static subscript<Type>(key: Key<Type>, default: @autoclosure () -> Type) -> Type {
        (UserDefaults.standard.value(forKey: key.name) as? Type) ?? `default`()
    }

    // Codable 支持
    static subscript<Type>(key: Key<Type>) -> Type? where Type: Codable {
        get {
            guard let data = UserDefaults.standard.data(forKey: key.name) else {
                return nil
            }
            do {
                return try JSONDecoder().decode(Type.self, from: data)
            } catch {
                return nil
            }
        }
        set {
            if let model = newValue {
                do {
                    let data = try JSONEncoder().encode(model)
                    UserDefaults.standard.set(data, forKey: key.name)
                } catch {
                    // do nothing
                }
            } else {
                UserDefaults.standard.removeObject(forKey: key.name)
            }
        }
    }

    static subscript<Type>(key: Key<Type>, default: @autoclosure () -> Type) -> Type where Type: Codable {
        (UserDefaults.standard.value(forKey: key.name) as? Type) ?? `default`()
    }
}

// MARK: - propertyWrapper
/// A type safe property wrapper to set and get values from UserDefaults with support for defaults values.
///
/// Usage:
/// ```
/// @UserDefault("has_seen_app_introduction", defaultValue: false)
/// static var hasSeenAppIntroduction: Bool
/// ```
///
/// [Apple documentation on UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)
@propertyWrapper
public struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var userDefaults: UserDefaults

    public init(_ key: String, defaultValue: Value, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    public var wrappedValue: Value {
        get {
            return userDefaults.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

/// A type than can be stored in `UserDefaults`.
///
/// - From UserDefaults;
/// The value parameter can be only property list objects: NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary.
/// For NSArray and NSDictionary objects, their contents must be property list objects. For more information, see What is a
/// Property List? in Property List Programming Guide.
public protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension NSData: PropertyListValue {}

extension String: PropertyListValue {}
extension NSString: PropertyListValue {}

extension Date: PropertyListValue {}
extension NSDate: PropertyListValue {}

extension NSNumber: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Int8: PropertyListValue {}
extension Int16: PropertyListValue {}
extension Int32: PropertyListValue {}
extension Int64: PropertyListValue {}
extension UInt: PropertyListValue {}
extension UInt8: PropertyListValue {}
extension UInt16: PropertyListValue {}
extension UInt32: PropertyListValue {}
extension UInt64: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
#if os(macOS)
extension Float80: PropertyListValue {}
#endif

extension Array: PropertyListValue where Element: PropertyListValue {}

extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}
