//
//  NYDiskFileCache.swift
//  NiuYan
//
//  Created by 陈良静 on 2019/8/7.
//  Copyright © 2019 niuyan.com. All rights reserved.
//

import Foundation

/// 磁盘文件缓存
public class DiskFileCache: NSObject, Cacheable {

    /// 缓存总大小
    public var totalCost: UInt {
        if !self.isValidFileDir(fileCacheDir) {
            return 0
        }

        var fileSize: UInt = 0
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: fileCacheDir!.path)
            for file in files {
                let fileUrl = fileCacheDir!.appendingPathComponent(file)
                if let attributes = try? FileManager.default.attributesOfItem(atPath: fileUrl.path) {
                    fileSize += (attributes[FileAttributeKey.size] as? UInt) ?? 0
                }
            }

            return fileSize
        } catch {

            return 0
        }
    }

    /// 缓存总数量
    public var totalCount: UInt {
        if !self.isValidFileDir(fileCacheDir) {
            return 0
        }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: fileCacheDir!.path)

            return UInt(files.count)
        } catch {
            return 0
        }

    }

    /// 缓存限制
    public var costLimit: UInt
    public var countLimit: UInt
    public var ageLimit: TimeInterval

    /// 串行队列
    private var queue: DispatchQueue
    private var fileCacheDir: URL?

    // MARK: - lifeCycle
    init(cacheDirectoryName directoryName: String) {
        let folder = _lostw.folder.cache.appendingPathComponent(directoryName)
        let exist = FileManager.default.fileExists(atPath: folder.path)
        if !exist {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        }

        self.fileCacheDir = folder

        costLimit = UInt.max
        countLimit = UInt.max
        ageLimit = Double.greatestFiniteMagnitude
        queue = DispatchQueue(label: String(describing: type(of: DiskFileCache.self)))

        super.init()
    }

    // MARK: - privateFunc
    private func isValidFileDir(_ dir: URL?) -> Bool {
        guard let dir = dir else { return false }
        if dir.path.count == 0 { return false }
        if !FileManager.default.fileExists(atPath: dir.path) { return false }

        return true
    }

    private func creatFileUrl(_ fileName: String) -> URL? {
        let fileUrl = fileCacheDir?.appendingPathComponent(fileName)
        return fileUrl
    }
}

// MARK: - 缓存操作
extension DiskFileCache {
    func contain(forKey key: AnyHashable) -> Bool {
        guard let fileUrl = creatFileUrl(key as! String) else {
            return false
        }

        let contains = FileManager.default.fileExists(atPath: fileUrl.path)
        return contains
    }

    func object(forKey key: AnyHashable) -> Data? {
        guard let fileUrl = creatFileUrl(key as! String) else { return nil }
        do {

            let dataString = try String(contentsOf: fileUrl, encoding: .utf8)
            let data = dataString.data(using: .utf8)

            return data
        } catch let error {
            ZLog.debug("缓存读取 error = \(error)")
            return nil
        }
    }

    func setObject(_ object: Data, forKey key: AnyHashable, withCost cost: UInt) {
        guard let fileUrl = creatFileUrl(key as! String) else { return }
        do {
            let dataString = String(data: object, encoding: .utf8)
            try dataString?.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch let error {
            ZLog.debug("缓存写入 error = \(error)")
        }

        if totalCost > costLimit {
            queue.async {
                self.trim(withCost: self.costLimit)
            }
        }

        if totalCount > countLimit {
            queue.async {
                self.trim(withCount: self.countLimit)
            }
        }

        queue.async {
            self.trim(withAge: self.ageLimit)
        }
    }

    func removeObject(forKey key: AnyHashable) {
        guard let dir = fileCacheDir else {  return }
        let fileName = key as! String
        let fileUrl = dir.path + "/\(fileName)"
        try? FileManager.default.removeItem(atPath: fileUrl)
    }

    func removeAllObject() {
        guard let dir = fileCacheDir else {  return }
        guard let fileArray = FileManager.default.subpaths(atPath: dir.path) else {  return }
        for fileName in fileArray {
            try? FileManager.default.removeItem(atPath: dir.path + "/\(fileName)")
        }
    }
}

// MARK: - trim 清理缓存逻辑
extension DiskFileCache {
    func trim(withCost cost: UInt) {
        if totalCost <= cost {  return }
        if cost == 0 {
            removeAllObject()
        }

        while totalCost > cost {
            guard let dir = fileCacheDir else {  return }
            guard let fileArray = FileManager.default.subpaths(atPath: dir.path) else {  return }
            let lastFileName = fileArray.last
            removeObject(forKey: lastFileName)
        }
    }

    func trim(withCount count: UInt) {
        if totalCount <= count {
            return
        }

        if count == 0 {
            removeAllObject()
        }

        while totalCount > count {
            guard let dir = fileCacheDir else {  return }
            guard let fileArray = FileManager.default.subpaths(atPath: dir.path) else {  return }
            let lastFileName = fileArray.last
            removeObject(forKey: lastFileName)
        }
    }

    func trim(withAge age: TimeInterval) {
        if age == 0 {
            removeAllObject()
        }

        guard let dir = fileCacheDir else { return }
        // 清理掉过期时间的缓存
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
            for file in files {
                let fileUrl = dir.appendingPathComponent(file)
                if let attributes = try? FileManager.default.attributesOfItem(atPath: fileUrl.path) {
                    guard let modifyDate = attributes[FileAttributeKey.modificationDate] as? Date else {  return }
                    if Date().timeIntervalSince1970 - modifyDate.timeIntervalSince1970 > age {
                        // 过期的，删除掉
                        removeObject(forKey: file)
                    }
                }
            }
        } catch {

        }
    }
}

extension DiskFileCache: Storage {
    func hashedKey(_ key: String) -> String {
        return Hash.sha256(key)
    }
    public func exist(for key: String) -> Bool {
        return contain(forKey: hashedKey(key))
    }

    public func data(for key: String) -> Data? {
        return object(forKey: hashedKey(key))
    }

    @discardableResult
    public func setData(_ data: Data, for key: String) -> Bool {
        setObject(data, forKey: hashedKey(key), withCost: UInt(data.count))
        return true
    }

    @discardableResult
    public func remove(for key: String) -> Bool {
        remove(for: hashedKey(key))
        return true
    }
}
