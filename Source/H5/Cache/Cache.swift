//
//  NYH5FileCache.swift
//  NYOpenH5Demo
//
//  Created by 陈良静 on 2019/7/30.
//  Copyright © 2019 陈良静. All rights reserved.
//

import Foundation

/// h5 页面资源缓存
public final class Cache: Storage {
    /// 内存缓存大小：10M
    private let kMemoryCacheCostLimit: UInt = 10 * 1024 * 1024
    /// 磁盘文件缓存大小： 10M
    private let kDiskCacheCostLimit: UInt = 10 * 1024 * 1024
    /// 磁盘文件缓存时长：30 分钟
    private let kDiskCacheAgeLimit: TimeInterval = 30 * 60

    public var memoryCache: MemoryCache
    public var diskCache: DiskFileCache

    public init() {
        memoryCache = MemoryCache.shared
        memoryCache.costLimit = kMemoryCacheCostLimit

        diskCache = DiskFileCache(cacheDirectoryName: "Cache")
        diskCache.costLimit = kDiskCacheCostLimit
        diskCache.ageLimit = kDiskCacheAgeLimit
    }

    public func exist(for key: String) -> Bool {
        return memoryCache.contain(forKey: key) || diskCache.contain(forKey: key)
    }

    @discardableResult
    public func setData(_ data: Data, for key: String) -> Bool {
        memoryCache.setObject(data, forKey: key, withCost: UInt(data.count))
        diskCache.setObject(data, forKey: key, withCost: UInt(data.count))
        return true
    }

    public func data(for key: String) -> Data? {
        if let data = memoryCache.object(forKey: key) {
            return data as? Data
        } else {
            guard let data = diskCache.object(forKey: key) else { return nil}
            memoryCache.setObject(data, forKey: key, withCost: UInt(data.count))
            return data
        }
    }

    @discardableResult
    public func remove(for key: String) -> Bool {
        memoryCache.removeObject(forKey: key)
        diskCache.removeObject(forKey: key)
        return true
    }

    public func removeAll() {
        memoryCache.removeAllObject()
        diskCache.removeAllObject()
    }
}
