//
//  util.swift
//  collection
//
//  Created by william on 02/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

typealias VoidClosure = () -> Void

public let APP_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
public let APP_BUILD = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
public let SCREEN_WIDTH = UIScreen.main.bounds.width
public let SCREEN_HEIGHT = UIScreen.main.bounds.height

public let ONE_PX = 1 / UIScreen.main.scale
public let ONE_PX_ADJUST = ONE_PX / 2

public let defaultCellIdentifier = "DefaultCell"

public func isPhoneX() -> Bool {
    guard #available(iOS 11, *) else {
        return false
    }
    
    return UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0.0
}

postfix operator ~
postfix func ~ (value: CGFloat) -> CGFloat {
    return value / 375 * SCREEN_WIDTH
}

func maskText(_ text: String, range: Range<Int>, charactor: Character = "*") -> String {
    guard range.upperBound <= text.count - 1 else {
        return text
    }
    
    let indexRange = text.index(text.startIndex, offsetBy: range.lowerBound)..<text.index(text.startIndex, offsetBy: range.upperBound)
    let replace = String(repeating: charactor, count: range.count)
    return text.replacingCharacters(in: indexRange, with: replace)
}

func maskText(_ text: String, range: Range<String.Index>, charactor: Character = "*") -> String {
    guard range.upperBound <= text.endIndex else {
        return text
    }
    let count = text.distance(from: range.lowerBound, to: range.upperBound)
    let replace = String(repeating: charactor, count: count)
    return text.replacingCharacters(in: range, with: replace)
    
}

func maskName(_ name: String) -> String {
    guard name.count >= 2 else {
        return name
    }
    
    var range: Range<Int>!
    if name.count == 2 {
        range = 1..<2
    } else {
        range = 1..<(name.count - 1)
    }
    
    return maskText(name, range: range)
 }

func maskMobile(_ mobile: String) -> String {
    return maskText(mobile, range: 3..<7)
}

func maskIdcard(_ text: String) -> String {
    return maskText(text, range: 8..<16)
}

func genderTextByIdcard(_ idcard: String?) -> String {
    guard let idcard = idcard else {
        return ""
    }
    
    var genderBit: Int = 0
    if idcard.count == 18 {
        genderBit = String(idcard[16]).intValue
    } else if idcard.count == 15 {
        genderBit = String(idcard.last!).intValue
    }
    
    return genderBit % 2 == 1 ? "男" : "女"
}

//func implodeQuery(_ path: String, params: [String: Any]?) -> String {
//    var link = path
//    if let query = params?.toQuery() {
//        if link.range(of: "?") == nil {
//            link = "\(link)?\(query)"
//        } else {
//            link = "\(link)&\(query)"
//        }
//    }
//
//    return link
//}

func toCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    
    formatter.positiveFormat = "###,###,###,###,##0.00;"
    formatter.roundingMode = .halfUp
    return formatter.string(from: NSNumber(value: value)) ?? ""
}

func toCurrency(_ value: Int, decimal: Bool = true) -> String {
    let formatter = NumberFormatter()
    
    if decimal {
        formatter.positiveFormat = "###,###,###,###,##0.00;"
    } else {
        formatter.positiveFormat = "###,###,###,###,##0;"
    }
    
    formatter.roundingMode = .halfUp
    return formatter.string(from: NSNumber(value: value)) ?? ""
}

func isVersion(_ a: String, olderThan b: String) -> Bool {
    if a == b {
        return false
    }
    
    return a.compare(b, options: .numeric) == .orderedDescending
}

func swiftClassFromString(_ className: String) -> AnyClass! {
    
    /// get namespace
    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    
    /// get 'anyClass' with classname and namespace
    let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!;
    
    // return AnyClass!
    return cls;
}

func getIdcardAge(_ idcard: String) -> Int {
    let year = Int(idcard[6, 4])!
    let month = Int(idcard[10, 2])!
    let day = Int(idcard[12, 2])!
    
    let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    
    var age = components.year! - year
    if (components.month! - month) * 32 + (components.day! - day) < 0 {
        age -= 1
    }
    return age
}

func qrcode(_ content: String, imageWidth: CGFloat) -> UIImage {
    //创建一个二维码的滤镜
    let qrFilter = CIFilter(name: "CIQRCodeGenerator")
    
    // 恢复滤镜的默认属性
    qrFilter?.setDefaults()
    
    // 将字符串转换成
    let infoData = content.data(using: .utf8)
    
    // 通过KVC设置滤镜inputMessage数据
    qrFilter?.setValue(infoData, forKey: "inputMessage")
    
    // 获得滤镜输出的图像
    let  outputImage = qrFilter?.outputImage
    
    // 设置缩放比例
    let scale = imageWidth / outputImage!.extent.size.width;
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    let transformImage = qrFilter!.outputImage!.transformed(by: transform)
    
    // 获取Image
    let image = UIImage(ciImage: transformImage)
    return image
}


