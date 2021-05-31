//
//  ImageDownloader.swift
//  LostwKit
//
//  Created by William on 2021/5/27.
//

import Foundation
import Kingfisher

public typealias ImageDownloaderProgress = (_ received: Int64, _ total: Int64) -> Void

public class ImageDownloader {
    public static let shared = ImageDownloader()

    public func downloadImage(link: String, progress: ImageDownloaderProgress? = nil, callback: @escaping (Swift.Result<Data, Error>) -> Void) {
        guard let url = URL(string: link) else {
            return

        }
        Kingfisher.ImageDownloader.default.downloadImage(with: url, options: nil, progressBlock: progress, completionHandler: { result in
            callback(result.map({ $0.originalData }).mapError({ ZZError(error: $0) }))
        })
    }
}

