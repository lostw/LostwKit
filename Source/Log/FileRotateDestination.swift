//
//  FileRotateDestination.swift
//  Example
//
//  Created by William on 2020/5/26.
//  Copyright © 2020 Wonders. All rights reserved.
//

import UIKit

public class FileRotateDestination: BaseDestination {
    var fileDestination: FileDestination
    var maxFileNum: Int

    public init(directoryURL: URL? = nil, maxFileNum: Int = 5) {
        var dir: URL! = directoryURL
        if dir == nil {
            dir = LostwKitPath.main.appendingPathComponent("log")
        }

        var isDir: ObjCBool = false
        let result = FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir)
        if !result || !isDir.boolValue {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }

        let fileURL = dir.appendingPathComponent(Date().format(.custom("yyyy-MM-dd.HHmmss'.log'")))
        self.fileDestination = FileDestination(logFileURL: fileURL)
        self.fileDestination.format = "$Dyyyy-MM-dd HH:mm:ss.SSS |$d $C$L$c | $T |$N.$F.$l - $M"
        self.maxFileNum = maxFileNum

        super.init()
        self.prune(dir: dir)
    }

    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
        return fileDestination.send(level, msg: msg, thread: thread, file: file, function: function, line: line, context: context)
    }

    func prune(dir: URL) {
        let fileMgr = FileManager.default

        if var files = try? fileMgr.contentsOfDirectory(at: dir, includingPropertiesForKeys: [], options: []) {
            if files.count <= maxFileNum {
                return
            }

            files.sort {$0.lastPathComponent > $1.lastPathComponent}

            for i in maxFileNum..<files.count {
                let url = files[i]
                do {
                    try fileMgr.removeItem(at: url)
                } catch {
                    print("Error attempting to delete the unneeded file <\(url.path)>: \(error)")
                }

            }
        }

    }
}
