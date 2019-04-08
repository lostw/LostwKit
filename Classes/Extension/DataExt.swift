//
//  DataExt.swift
//  HealthTaiZhou
//
//  Created by William on 2019/1/23.
//  Copyright © 2019 Wonders. All rights reserved.
//

import Foundation

extension Data {
    public func toJSONObject() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
    
    public func toDictionary() -> [String: Any]? {
        return self.toJSONObject() as? [String: Any]
    }
}
