//
//  WKZCache.swift
//  Zhangzhilicai
//
//  Created by william on 19/09/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

class WKZCacheItem: NSObject {
    var content: Any!
    var expire: TimeInterval!
}

public class WKZCache: NSObject {
    @objc public static let shared = WKZCache()
    
    let cache = NSCache<NSString, AnyObject>()
    
    override init() {
        super.init()
        self.createCacheDir()
    }
    
    @objc func object(forKey key: String) -> Any? {
        if let item = self.cache.object(forKey: key as NSString) as? WKZCacheItem {
            if item.expire > Date().timeIntervalSince1970 {
                return item.content
            }
        }
        
        return nil
    }
    
    @objc func setObject(_ obj: Any, forKey key: String, expiredAt: TimeInterval = Double.infinity) {
        if expiredAt <= 0 {
            return
        }
        
        let item = WKZCacheItem()
        item.content = obj
        item.expire = expiredAt
        
        self.cache.setObject(item, forKey: key as NSString)
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
    
    public func files() -> [URL]?{
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
        
        var cacheDir = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        cacheDir.appendPathComponent("WKZ")
        
        return cacheDir
    }
    
    private func fileURLByName(_ name: String) -> URL {
        var url = self.fileCacheURL()
        url.appendPathComponent(name)
        return url
    }
}
