//
//  WKZAttributedStringMaker.swift
//  collection
//
//  Created by william on 13/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
public enum WKZAttributeSearchType {
    case number, finance, text(_ :String), regex(_ :String)
}
public typealias WKZAttributedStringMakerBlock = (_ make: WKZAttributedStringMaker) -> Void

open class WKZAttributedStringMaker {
    var text: String
    var attributes = [WKZAttribute]()
    var attachment: NSTextAttachment?
    var attachmentPosition: Int = 0
    init(text: String) {
        self.text = text
    }

    open func make(_ block: WKZAttributedStringMakerBlock) -> NSAttributedString {
        block(self)
        return self.generate()
    }

    public func generate() -> NSAttributedString {
        let result = NSMutableAttributedString(string: self.text)

        for attribute in self.attributes {
            for range in attribute.ranges {
                result.addAttributes(attribute.attrs, range: NSRange(range))
            }
        }

        if let attachment = self.attachment {
            let attachmentAttr = NSAttributedString(attachment: attachment)
            if attachmentPosition == 0 {
                result.insert(attachmentAttr, at: 0)
                result.insert(NSAttributedString(string: " "), at: 1)
            } else {
                result.append(NSAttributedString(string: " "))
                result.append(attachmentAttr)
            }
        }

        return result.copy() as! NSAttributedString
    }

    open func range(_ range: Range<Int>? = nil) -> WKZAttribute {
        let final = range ?? 0..<self.text.count

        let attribute = WKZAttribute(range: final)
        self.attributes.append(attribute)
        return attribute
    }

     open func find(_ type: WKZAttributeSearchType, options: String.CompareOptions = []) -> WKZAttribute? {
        var range: Range<String.Index>?
        switch type {
        case .number:
            range = self.text.range(of: "[\\d\\.]+", options: .regularExpression)
        case .finance:
            range = self.text.range(of: "\\d+(,\\d{3})*(\\.\\d{2})?", options: .regularExpression)
        case .text(let s):
            range = self.text.range(of: s, options: options)
        case .regex(let r):
            range = self.text.range(of: r, options: .regularExpression)
        }

        guard range != nil else {
            return nil
        }

        let start = self.text.distance(from: self.text.startIndex, to: range!.lowerBound)
        let end = self.text.distance(from: self.text.startIndex, to: range!.upperBound)

        return self.range(start..<end)

    }

    open func findAll(_ type: WKZAttributeSearchType, options: String.CompareOptions = []) -> WKZAttribute? {
        var ranges: [Range<String.Index>]?
        switch type {
        case .number:
            ranges = self.text.ranges(of: "\\d+", options: .regularExpression)
        case .finance:
            ranges = self.text.ranges(of: "\\d+(,\\d{3})*(\\.\\d{2})?", options: .regularExpression)
        case .text(let s):
            ranges = self.text.ranges(of: s, options: options)
        case .regex(let r):
            ranges = self.text.ranges(of: r, options: .regularExpression)
        }

        guard ranges != nil else {
            return nil
        }

        var attributeRanges = [Range<Int>]()

        for range in ranges! {
            let start = self.text.distance(from: self.text.startIndex, to: range.lowerBound)
            let end = self.text.distance(from: self.text.startIndex, to: range.upperBound)
            attributeRanges.append(start..<end)
        }

        let attribute = WKZAttribute(ranges: attributeRanges)
        self.attributes.append(attribute)

        return attribute
    }

    public func prepend(icon: UIImage, adjustY: CGFloat = 0) -> Self {
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = CGRect(x: 0, y: adjustY, width: icon.size.width, height: icon.size.height)

        self.attachment = attachment
        self.attachmentPosition = 0
        return self
    }

    public func append(icon: UIImage, adjustY: CGFloat = 0) -> Self {
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = CGRect(x: 0, y: adjustY, width: icon.size.width, height: icon.size.height)

        self.attachment = attachment
        self.attachmentPosition = 1
        return self
    }
}

public extension String {
    var styled: WKZAttributedStringMaker {
        return WKZAttributedStringMaker(text: self)
    }
}
