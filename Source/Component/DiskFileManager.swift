//
//  DiskFileManager.swift
//  Alamofire
//
//  Created by William on 2020/7/14.
//

import Foundation

class DiskFileManager {
    var root: URL
    init(root: URL) {
        self.root = root
        if !FileManager.default.fileExists(atPath: root.path) {
            try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: nil)
        }
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
