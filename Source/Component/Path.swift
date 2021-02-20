//
//  Path.swift
//  LostwKit
//
//  Created by William on 2020/12/14.
//

import Foundation

public class Path {
    static public let document: Path = {
        // swiftlint:disable force_try
        var cacheDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return Path(fileURL: cacheDir)
        // swiftlint:enable force_try
    }()
    static public let cache: Path = {
        // swiftlint:disable force_try
        var cacheDir = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return Path(fileURL: cacheDir)
        // swiftlint:enable force_try
    }()

    public private(set) var fileURL: URL
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func join(_ path: String) -> Self {
        self.fileURL.appendPathComponent(path)
        return self
    }

    public func join(_ path: String, isDir: Bool) -> Self {
        self.fileURL.appendPathComponent(path, isDirectory: isDir)
        return self
    }

    public func isExist() -> Bool {
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    public func createDirectory() {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return
        }
        try? FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
    }

    /// 创建文件夹
//    public func create() throws {
//        if fileURL.path.hasSuffix("/") {
//            try FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
//        } else {
//            try FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
//        }
//    }
}

extension URL {
    var wrapped: Path {
        return Path(fileURL: self)
    }
}
