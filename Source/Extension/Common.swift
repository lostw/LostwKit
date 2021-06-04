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

public typealias VoidClosure = () -> Void

public let APP_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
public let APP_BUILD = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
public let STATUSBAR_HEIGHT = UIApplication.shared.statusBarFrame.height
public let SCREEN_WIDTH = UIScreen.main.bounds.width
public let SCREEN_HEIGHT = UIScreen.main.bounds.height

public let ONE_PX = 1.0 / UIScreen.main.scale
public let ONE_PX_ADJUST = ONE_PX / 2.0

public let defaultCellIdentifier = "DefaultCell"

public func isPhoneX() -> Bool {
     let width = UIScreen.main.bounds.width
     let height = UIScreen.main.bounds.height
     return width >= 375.0 && height >= 812.0
}

postfix operator ~
public postfix func ~ (value: CGFloat) -> CGFloat {
    return value / 375 * SCREEN_WIDTH
}

@discardableResult
public func swizzleMethod(_ classType: AnyClass, original: Selector, swizzled: Selector) -> Bool {
    guard let originalMethod = class_getInstanceMethod(classType, original),
        let swizzledMethod = class_getInstanceMethod(classType, swizzled) else {
        return false
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
    return true
}

public func genderTextByIdcard(_ idcard: String?) -> String {
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

public func deviceIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)

    let machine = systemInfo.machine
    let mirror = Mirror(reflecting: machine)
    var identifier = ""

    for child in mirror.children {
        if let value = child.value as? Int8, value != 0 {
            identifier.append(String(UnicodeScalar(UInt8(value))))
        }
    }

    return identifier
}

public func delay(_ time: TimeInterval, queue: DispatchQueue = DispatchQueue.main, action: @escaping VoidClosure) {
    queue.asyncAfter(deadline: .now() + time, execute: action)
}

public func toCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()

    formatter.positiveFormat = "###,###,###,###,##0.00;"
    formatter.roundingMode = .halfUp
    return formatter.string(from: NSNumber(value: value)) ?? ""
}

public func currencyStyle(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.positiveFormat = "###,###,##0.00;"
    formatter.roundingMode = .halfUp
    formatter.positivePrefix = "¥"
    formatter.negativePrefix = "-¥"
    return formatter.string(from: NSNumber(value: value)) ?? ""
}

public func isVersion(_ a: String, olderThan b: String) -> Bool {
    if a == b {
        return false
    }

    return a.compare(b, options: .numeric) == .orderedDescending
}

public func getIdcardAge(_ idcard: String) -> Int {
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

public func qrcode(_ content: String, imageWidth: CGFloat) -> UIImage {
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
    let scale = imageWidth / outputImage!.extent.size.width
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    let transformImage = qrFilter!.outputImage!.transformed(by: transform)

    // 获取Image
    let image = UIImage(ciImage: transformImage)
    return image
}

public func storageSizeDesc(_ size: UInt) -> String {
    if size == 0 {
        return "0K"
    }

    var double = Double(size) / 1024
    var level = 0
    let unit = ["K", "M", "G"]
    while (double > 1024) && (level <= unit.count) {
        double /= 1024
        level += 1
    }

    return String(format: "%0.2f%@", double, unit[level])
}
