//
//  DiskFileManager.swift
//  Alamofire
//
//  Created by William on 2020/7/14.
//

import Foundation

/// 存储数据到文件，对key会先做sha256处理
public final class DiskFileManager {
    public static let shared = DiskFileManager(root: lostw.cachePath.appendingPathComponent("files", isDirectory: true))

    var root: URL
    public init(root: URL) {
        self.root = root
        if !FileManager.default.fileExists(atPath: root.path) {
            try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: nil)
        }
    }

    public func exist(for key: String) -> Bool {
        return FileManager.default.fileExists(atPath: path(for: key).path)
    }

    public func save(data: Data, for key: String) {
        do {
            try data.write(to: path(for: key))
        } catch {
            ZLog.error(error)
        }
    }

    public func retrieve(for key: String) -> Data? {
        return try? Data(contentsOf: path(for: key))
    }

    private func path(for key: String) -> URL {
        return root.appendingPathComponent(Hash.sha256(key), isDirectory: false)
    }
}
