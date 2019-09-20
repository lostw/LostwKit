//
//  AppTheme.swift
//  Alamofire
//
//  Created by William on 2019/2/13.
//

import UIKit

public class Theme {
    public enum ColorType {
        case background
        case title
        case text
        case major
        case majorText
        case primary
        case promptText
        case subText
        case border
        case disabled
        case error
    }

    public static let shared = Theme()
    var colorDict = [ColorType: UIColor]()

    init() {
        self.colorDict[.background] = UIColor(hex: 0xF5F5F5)
        self.colorDict[.title] = UIColor(hex: 0x333333)
        self.colorDict[.text] = UIColor(hex: 0x666666)
        self.colorDict[.major] = UIColor(hex: 0x1A82D1)
        self.colorDict[.majorText] = UIColor(hex: 0x528bd2)
        self.colorDict[.primary] = UIColor(hex: 0x0cb8ff)
        self.colorDict[.promptText] = UIColor(hex: 0x888888)
        self.colorDict[.subText] = UIColor(hex: 0xbbbbbb)
        self.colorDict[.border] = UIColor(hex: 0xe0e0e0)
        self.colorDict[.disabled] = UIColor(hex: 0xcacaca)
    }

    public subscript(key: ColorType) -> UIColor {
        get {
            return colorDict[key]!
        }
        set {
            return colorDict[key] = newValue
        }

    }

    // MARK: - convience methods
    public var background: UIColor {
        return self[.background]
    }

    public var border: UIColor {
        return self[.border]
    }

    public var titleText: UIColor {
        return self[.title]
    }

    public var text: UIColor {
        return self[.text]
    }

    public var error: UIColor {
        return self[.error]
    }
}
