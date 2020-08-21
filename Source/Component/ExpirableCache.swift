//
//  WKZCache.swift
//  Zhangzhilicai
//
//  Created by william on 19/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public final class ExpirableCache {
    public enum ExpireStrategy {
        case duration(TimeInterval)
        case at(TimeInterval)

        var expireAt: TimeInterval {
            switch self {
            case .duration(let d):
                return Date().timeIntervalSince1970 + d
            case .at(let t):
                return t
            }
        }
    }

    struct CacheItem<T> {
        var content: T
        var expireAt: TimeInterval = 0
    }

    public static let shared = ExpirableCache()

    public func save<T>(_ obj: T, for key: String, strategy: ExpireStrategy) {
        let item = CacheItem<T>(content: obj, expireAt: strategy.expireAt)
        MemoryCache.shared.setObject(obj, forKey: key, withCost: UInt(MemoryLayout.stride(ofValue: obj)))
    }

    public func retrieve<T>(for key: String) -> T? {
        guard let item = MemoryCache.shared.object(forKey: key) as? CacheItem<T> else {
            return nil
        }

        if item.expireAt <= Date().timeIntervalSince1970 {
            return nil
        }

        return item.content
    }
}
