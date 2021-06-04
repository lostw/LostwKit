//
//  DiskStorage.swift
//  LostwKit
//
//  Created by William on 2021/5/28.
//

import Foundation

public protocol Storage {
    func exist(for key: String) -> Bool
    func data(for key: String) -> Data?
    @discardableResult
    func setData(_ data: Data, for key: String) -> Bool
    @discardableResult
    func remove(for key: String) -> Bool
}

public extension Storage {
    func image(for key: String) -> UIImage? {
        if let data = data(for: key) {
            return UIImage(data: data, scale: UIScreen.main.scale)
        }

        return nil
    }

    @discardableResult
    func setImage(_ image: UIImage, for key: String) -> Bool {
        return setData(image.pngData()!, for: key)
    }

    func dict(for key: String) -> [String: Any]? {
        if let data = data(for: key) {
            return data.toDictionary()
        }

        return nil
    }

    @discardableResult
    func setDict(_ dict: [String: Any], for key: String) -> Bool {
        if let jsonData = ZZJson.toData(dict) {
            return setData(jsonData, for: key)
        }
        return false
    }
}
