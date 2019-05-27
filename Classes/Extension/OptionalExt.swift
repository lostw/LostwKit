//
//  OptionalExt.swift
//  HealthTaiZhou
//
//  Created by Mac on 2019/3/13.
//  Copyright © 2019 Wonders. All rights reserved.
//

import Foundation
public extension Optional where Wrapped == String {
    func emptyOr(_ defaultValue: String) -> String {
        switch self {
        case .none:
            return defaultValue
        case .some(let value):
            return value.isEmpty ? defaultValue : value
        }
    }

    var intValue: Int {
        return self.intValue ?? 0
    }

    var doubleValue: Double {
        return self.doubleValue ?? 0
    }
}
