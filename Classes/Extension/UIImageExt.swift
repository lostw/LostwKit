//
//  UIImageExt.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/8/15.
//  Copyright © 2018 kingtang. All rights reserved.
//

import Foundation

public extension UIImage {
    static func getFaceData(_ imageData: Data) -> UIImage? {
        let faceDetector: CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracy])!
        let ciImage = CIImage(data: imageData)!

        let features = faceDetector.features(in: ciImage)
        if features.count > 0 {
            let cgImage = CIContext(options: nil).createCGImage(ciImage, from: features.first!.bounds)!
            let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)

            return image
        }

        return nil
    }
    static func qrcode(content: String, scaleToWidth width: CGFloat? = nil) -> UIImage? {
        guard let data = content.data(using: .utf8) else {
            return nil
        }

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        guard var qrcodeImage = filter.outputImage else {
            return nil
        }

        qrcodeImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: 5, y: 5))

        if let width = width {
            let size = CGSize(width: width, height: qrcodeImage.extent.height / qrcodeImage.extent.width * width)
            guard let cgImage = CIContext(options: nil).createCGImage(qrcodeImage, from: qrcodeImage.extent) else {
                return nil
            }

            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            guard let ctx = UIGraphicsGetCurrentContext() else {
                return nil
            }

            ctx.interpolationQuality = .none
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.draw(cgImage, in: ctx.boundingBoxOfClipPath)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        } else {
            return UIImage(ciImage: qrcodeImage)
        }
    }

    static func barcode(content: String, scaleToWidth width: CGFloat? = nil) -> UIImage? {
        guard let data = content.data(using: .utf8) else {
            return nil
        }

        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(0, forKey: "inputQuietSpace")
        guard let qrcodeImage = filter.outputImage else {
            return nil
        }

        if let width = width {
            let size = CGSize(width: width, height: qrcodeImage.extent.height / qrcodeImage.extent.width * width)
            guard let cgImage = CIContext(options: nil).createCGImage(qrcodeImage, from: qrcodeImage.extent) else {
                return nil
            }

            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            guard let ctx = UIGraphicsGetCurrentContext() else {
                return nil
            }

            ctx.interpolationQuality = .none
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.draw(cgImage, in: ctx.boundingBoxOfClipPath)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        } else {
            return UIImage(ciImage: qrcodeImage)
        }
    }

    func imageFitTo(width: CGFloat) -> UIImage? {
        let height = width / self.size.width * self.size.height
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /// 根据最大宽高获取等比例缩放后图片
    func imageFitToSize(_ maxSize: CGSize) -> UIImage? {
        let reWidth = self.size.width
        let reHeight = self.size.height

        if self.size.height == 0 || maxSize.height == 0 {
            return nil
        }

        let reRatio =  reWidth/reHeight
        let ratio = maxSize.width/maxSize.height

        var size = CGSize(reWidth, reHeight)
        if ratio > reRatio {
            if maxSize.height < reHeight {
                let width = maxSize.width/reRatio
                size = CGSize(width, maxSize.height)
            }
        } else {
            if maxSize.width < reWidth {
                let height = maxSize.height * reRatio
                size = CGSize(maxSize.width, height)
            }
        }

        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
