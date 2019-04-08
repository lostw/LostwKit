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
            }
        }
    }
    
    public static let shared = AppTheme()
    var colorDict = [ColorType: UIColor]()
    
    public subscript(key: ColorType) -> UIColor {
        return colorDict[key] ?? key.defaultColor
    }
    
    public func configColor(key: ColorType, color: UIColor) {
        colorDict[key] = color
    }
}
