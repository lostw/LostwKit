//
//  DataExt.swift
//  HealthTaiZhou
//
//  Created by William on 2019/1/23.
//  Copyright © 2019 Wonders. All rights reserved.
//

import Foundation

public extension Data {
    func toJSONObject() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }

    func toDictionary() -> [String: Any]? {
        return self.toJSONObject() as? [String: Any]
    }

    func toArray() -> [Any]? {
        return self.toJSONObject() as? [Any]
    }
}
