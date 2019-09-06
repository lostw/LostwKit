//
//  Dictionary+WKZ.swift
//  Zhangzhi
//
//  Created by william on 03/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

public extension Dictionary {
    func toQuery() -> String {
        var query = ""
        for (key, value) in self {
            query += "\(key)=\(value)&"
        }

        if query.count > 0 {
            query.remove(at: query.index(before: query.endIndex))
        }

        return query
    }

    func toJsonString(pretty: Bool = false) -> String? {
        return ZZJSON.stringify(self, pretty: pretty)
    }
}

public class ZZJSON {
    public static func stringify(_ object: Any, pretty: Bool = false) -> String? {
        var options: JSONSerialization.WritingOptions = []
        if pretty {
            options.insert(.prettyPrinted)
        }

        guard let data = try? JSONSerialization.data(withJSONObject: object, options: options) else {
            return nil
        }
        let str = String(data: data, encoding: .utf8)
        return str
    }
}
