//
//  DiskFileManager.swift
//  Alamofire
//
//  Created by William on 2020/7/14.
//

import Foundation

/// 存储数据到文件，对key会先做sha256处理
@available(*, deprecated, message: "use lostw.diskCache instead")
public final class DiskFileManager {
    public static let shared = DiskFileManager(root: Lostw.Folder().cache.appendingPathComponent("files", isDirectory: true))
    public static let document = DiskFileManager(root: Lostw.Folder().persist.appendingPathComponent("files", isDirectory: true))

    var root: URL
    public init(root: URL) {
        self.root = root
        if !FileManager.default.fileExists(atPath: root.path) {
            try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: nil)
        }
    }

    @available(*, deprecated, message: "use setData(_ data: Data, for key: String) -> Bool instead")
    @discardableResult
    public func save(data: Data, for key: String) -> Bool {
        do {
            try data.write(to: path(for: key))
            return true
        } catch {
            ZLog.error(error)
            return false
        }
    }

    @available(*, deprecated, message: "use data(for key: String) instead")
    public func retrieve(for key: String) -> Data? {
        return try? Data(contentsOf: path(for: key))
    }



    private func path(for key: String) -> URL {
        return root.appendingPathComponent(Hash.sha256(key), isDirectory: false)
    }
}

extension DiskFileManager: Storage {
    public func exist(for key: String) -> Bool {
        return FileManager.default.fileExists(atPath: path(for: key).path)
    }

    public func data(for key: String) -> Data? {
        return try? Data(contentsOf: path(for: key))
    }

    @discardableResult
    public func setData(_ data: Data, for key: String) -> Bool {
        do {
            try data.write(to: path(for: key))
            return true
        } catch {
            ZLog.error(error)
            return false
        }
    }

    @discardableResult
    public func remove(for key: String) -> Bool {
        do {
            try FileManager.default.removeItem(at: path(for: key))
            return true
        } catch {
            ZLog.error(error)
            return false
        }
    }
}
