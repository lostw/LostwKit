//
//  Dictionary+WKZ.swift
//  Zhangzhi
//
//  Created by william on 03/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

extension Dictionary {
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
    
    public func toJsonString(pretty: Bool = false) -> String? {
        var options:JSONSerialization.WritingOptions = []
        if pretty {
            options.insert(.prettyPrinted)
        }
        
        let data = try! JSONSerialization.data(withJSONObject: self, options: options)
        let str = String(data: data, encoding: .utf8)
        return str;

    }
}
