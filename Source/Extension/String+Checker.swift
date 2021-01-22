//
//  String+Validator.swift
//  LostwKit
//
//  Created by William on 2021/1/6.
//

import Foundation

private let idcardWi = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
private let idcardMod = ["1", "0", "x", "9", "8", "7", "6", "5", "4", "3", "2"]
private let idcardRegex = "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|x)$"

public extension String {
    public struct Checker {
        let value: String
        public init(value: String) {
            self.value = value
        }

        public var isPhone: Bool {
            return value.isMatch(regex: "^0{0,1}1[0-9]{10}$")
        }

        public var isIdcard: Bool {
            guard value.count == 18 else {
                return false
            }

            let text = value.lowercased()
            //初步校验
            guard text.isMatch(regex: idcardRegex) else {
                return false
            }

            //计算并比对校验位
            var sum: Int = 0
            for i in 0..<17 {
                sum += idcardWi[i] * String(text[i]).intValue
            }
            let mod = sum % 11
            return idcardMod[mod] == String(text[17])
        }
    }

    var checker: Checker {
        return Checker(value: self)
    }
}
