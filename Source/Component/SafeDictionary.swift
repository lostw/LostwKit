//
//  SafeDictionary.swift
//  LostwKit
//
//  Created by William on 2021/5/10.
//

import Foundation

public class SafeDictionary<Key: Hashable, Value: Any> {
    private let queue = DispatchQueue(label: "lostw.safe-dictionary", attributes: .concurrent)

    private var storage: Dictionary<Key, Value>

    public var isEmpty: Bool {
        var result: Bool = false
        queue.sync {
            result = storage.isEmpty
        }
        return result
    }

    public init(dictionary: Dictionary<Key, Value> = [:]) {
        storage = dictionary
    }

    public subscript(key: Key) -> Value? {
        get {
            var result: Value? = nil
            queue.sync {
                result = storage[key]
            }
            return result
        }
        set {
            queue.async(flags: .barrier) {
                self.storage[key] = newValue
            }
        }
    }

    public func removeAll() {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }

    public func assign(_ incoming: [Key: Value]) {
        queue.async(flags: .barrier) {
            for (key, value) in incoming {
                self.storage[key] = value
            }
        }
    }
}
