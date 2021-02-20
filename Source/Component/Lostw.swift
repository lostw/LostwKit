//
//  Lostw.swift
//  LostwKit
//
//  Created by William on 2020/11/26.
//

import Foundation

public let lostw = Lostw.shared

public struct Lostw {
    public struct App {
        public var version: String {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
        public var build: String {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        }
    }

    public static let shared = Lostw()
    public let app = App()

    public let cachePath: URL
    public let persistPath: URL

    init() {
        let fileManager = FileManager.default

        // swiftlint:disable force_try
        var cacheDir = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        // swiftlint:enable force_try
        cacheDir.appendPathComponent("LostwKit", isDirectory: true)

        self.cachePath = cacheDir
        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        }

        // swiftlint:disable force_try
        var doucumentDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        // swiftlint:enable force_try
        doucumentDir.appendPathComponent("LostwKit", isDirectory: true)
        self.persistPath = cacheDir
        if !fileManager.fileExists(atPath: doucumentDir.path) {
            try? fileManager.createDirectory(at: doucumentDir, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
