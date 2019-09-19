//
//  AppTheme.swift
//  Alamofire
//
//  Created by William on 2019/2/13.
//

import UIKit

public class AppTheme {
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

        var defaultColor: UIColor {
            switch self {
            case .background: return UIColor(hex: 0xF5F5F5)
            case .title: return UIColor(hex: 0x333333)
            case .text: return UIColor(hex: 0x666666)
            case .major: return UIColor(hex: 0x1A82D1)
            case .majorText: return UIColor(hex: 0x528bd2)
            case .primary: return UIColor(hex: 0x0cb8ff)
            case .promptText: return UIColor(hex: 0x888888)
            case .subText: return UIColor(hex: 0xbbbbbb)
            case .border: return UIColor(hex: 0xe0e0e0)
            case .disabled: return UIColor(hex: 0xcacaca)
            case .error: return UIColor(hex: 0xec7f7c)
            }
        }
    }

    public static let shared = AppTheme()
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
