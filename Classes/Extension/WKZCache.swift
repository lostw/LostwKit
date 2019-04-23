//
//  WKZCache.swift
//  Zhangzhilicai
//
//  Created by william on 19/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public class WKZCache: NSObject {
    class WKZCacheItem {
        var content: Any!
        var expire: TimeInterval!
    }

    public static let shared = WKZCache()

    let cache = NSCache<NSString, WKZCacheItem>()

    override init() {
        super.init()
        self.createCacheDir()
    }

    public func object<T>(forKey key: String) -> T? {
        if let item = self.cache.object(forKey: key as NSString) {
            if item.expire > Date().timeIntervalSince1970 {
                return item.content as? T
            }
        }

        return nil
    }

    public func setObject<T>(_ obj: T, forKey key: String, expiredAt: TimeInterval = Double.infinity) {
        if expiredAt <= 0 {
            return
        }

        let item = WKZCacheItem()
        item.content = obj
        item.expire = expiredAt

        self.cache.setObject(item, forKey: key as NSString)
    }

    public func setObject<T>(_ obj: T, forKey key: String, duration: TimeInterval) {
        if duration <= 0 {
            return
        }

        let expired = Date().timeIntervalSince1970 + duration
        self.setObject(obj, forKey: key, expiredAt: expired)
    }

    @objc func clear() {
        self.cache.removeAllObjects()
    }

    // MARK: - file cache
    public func isExistFileNamed(_ name: String) -> Bool {
        var url = self.fileCacheURL()
        url.appendPathComponent(name)

        return FileManager.default.fileExists(atPath: url.path)
    }

    @objc public func imageNamed(_ name: String) -> UIImage? {
        return UIImage(contentsOfFile: self.fileURLByName(name).path)
    }

    @objc public func cacheData(_ data: Data, withName name: String) {
        var url = self.fileCacheURL()
        url.appendPathComponent(name)
        try? data.write(to: url)
    }

    @objc func removeFileNamed(_ name: String) {
        var url = self.fileCacheURL()
        url.appendPathComponent(name)

        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    public func files() -> [URL]? {
        let url = self.fileCacheURL()
        let result = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [])
        return result
    }

    private func createCacheDir() {
        let url = self.fileCacheURL()
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }
    }

    public func fileCacheURL() -> URL {
        let fileManager = FileManager.default

        var cacheDir = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        cacheDir!.appendPathComponent("WKZ")

        return cacheDir!
    }

    private func fileURLByName(_ name: String) -> URL {
        var url = self.fileCacheURL()
        url.appendPathComponent(name)
        return url
    }
}
