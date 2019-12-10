//
//  LogFileConfiguration.swift
//  PullDemo
//
//  Created by william on 10/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

class LogFileConfiguration: BasicLogConfiguration {
    private let logFileRecorder: FileLogRecorder
    init?(minimumSeverity: LogSeverity = .info, directoryURL: URL, synchronousMode: Bool = false, filters: [LogFilter] = [], formatters: [LogFormatter] = [ReadableLogFormatter()]) {

        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd.HHmmss'.log'"

        let filePath = directoryURL.appendingPathComponent(fmt.string(from: Date()))
        if let recorder = FileLogRecorder(filePath: filePath.path, formatters: formatters) {
            logFileRecorder = recorder
            super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: [logFileRecorder], synchronousMode: synchronousMode)

            self.prune(dir: directoryURL)
        } else {
            return nil
        }
    }

    func prune(dir: URL) {
        let fileMgr = FileManager.default

        if var files = try? fileMgr.contentsOfDirectory(at: dir, includingPropertiesForKeys: [], options: []) {
            if files.count <= 5 {
                return
            }

            files.sort {$0.lastPathComponent > $1.lastPathComponent}

            for i in 5..<files.count {
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
