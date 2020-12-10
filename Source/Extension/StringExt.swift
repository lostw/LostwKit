//
//  String+Range.swift
//  collection
//
//  Created by william on 16/05/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation

private let idcardWi = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
private let idcardMod = ["1", "0", "x", "9", "8", "7", "6", "5", "4", "3", "2"]

public extension String {
    var intValue: Int {
        return Int(self) ?? 0
    }

    var doubleValue: Double {
        return Double(self) ?? 0
    }

    var utf8Data: Data {
        return self.data(using: .utf8)!
    }

    var URLEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }

    var isBlank: Bool {
        return allSatisfy { $0.isWhitespace }
    }

    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + dropFirst()
    }

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }

    func ranges(of search: String, options: NSString.CompareOptions = []) -> [Range<String.Index>]? {
        var ranges: [Range<String.Index>]?
        var searchIndex = self.startIndex

        while searchIndex < self.endIndex {
            if let range = self.range(of: search, options: options, range: searchIndex..<self.endIndex) {
                if ranges == nil {
                    ranges = []
                }

                ranges!.append(range)

                searchIndex = range.upperBound
            } else {
                break
            }
        }

        return ranges
    }

    func toDict() -> [String: Any]? {
        return self.utf8Data.toDictionary()
    }

    func toArr() -> [Any]? {
        return self.utf8Data.toArray()
    }

    func toJSONObject() -> Any? {
        return self.utf8Data.toJSONObject()
    }

    // MARK: - encoding
    func base64Encoded() -> String {
        return utf8Data.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func base64urlEncoded() -> String {
        var base = base64Encoded()
        base.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base
    }

    func base64urlDecoded() -> String? {
        var base64 = self.replacingOccurrences(of: "-", with: "+")
                         .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64.base64Decoded()
    }

    func appendingQuries(_ quries: [String: String]? = nil) -> String {
       guard let params = quries, !params.isEmpty else {
           return self
       }

       let str = params.reduce(into: "") {
           $0.append("&\($1.key)=\($1.value)")
       }

       if let index = self.firstIndex(of: "?") {
           if index == self.index(before: self.endIndex)  {
               let range = str.startIndex..<str.index(after: str.startIndex)
               return "\(self)\(str.replacingCharacters(in: range, with: ""))"
           } else {
               return "\(self)\(str)"
           }
       } else {
           let range = str.startIndex..<str.index(after: str.startIndex)
           return "\(self)\(str.replacingCharacters(in: range, with: "?"))"
       }
    }

    // MARK: - Validator
    func isMatch(regex: String) -> Bool {
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

    func isPhone() -> Bool {
        return isMatch(regex: "^0{0,1}1[0-9]{10}$")
    }

    func isIdcard() -> Bool {
        guard count == 18 else {
            return false
        }

        let text = lowercased()

        //初步校验
        let result = text.isMatch(regex: "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|x)$")
        if !result {
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

    // MARK: - 脱敏
    func mask(range: Range<Int>, charactor: Character = "*") -> String {
        guard range.upperBound <= self.count else {
            return self
        }

        let indexRange = index(self.startIndex, offsetBy: range.lowerBound)..<index(self.startIndex, offsetBy: range.upperBound)
        let replace = String(repeating: charactor, count: range.count)
        return self.replacingCharacters(in: indexRange, with: replace)
    }

    func mask(range: Range<String.Index>, charactor: Character = "*") -> String {
        guard range.upperBound <= self.endIndex else {
            return self
        }
        let count = self.distance(from: range.lowerBound, to: range.upperBound)
        let replace = String(repeating: charactor, count: count)
        return self.replacingCharacters(in: range, with: replace)
    }

    func asMaskedName() -> String {
        guard count >= 2 else {
            return self
        }

        var range: Range<Int>!
        if count == 2 {
            range = 0..<1
        } else {
            range = 1..<(count - 1)
        }

        return mask(range: range)
    }

    func asMaskedMobile() -> String {
        return mask(range: 3..<7)
    }

    func asMaskedIdcard() -> String {
        return mask(range: 2..<16)
    }
}

public extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript(i: Int, length: Int) -> Substring {
        var length = length
        if (self.count - i) < length {
            length = self.count - i
        }
        return self[index(startIndex, offsetBy: i)..<index(startIndex, offsetBy: i+length)]
    }
}
