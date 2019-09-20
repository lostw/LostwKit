//
//  WKZTextView.swift
//  collection
//
//  Created by william on 09/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class WKZTextView: UITextView {
    public var placeholder: String? {

        didSet {
            if let placeholder = self.placeholder {
                self.placeholderLayer.string = NSAttributedString(string: placeholder, attributes: self.attributes)
            } else {
                self.placeholderLayer.string = nil
            }
        }
    }
    public var placeholderAttribute: [NSAttributedString.Key: Any]?
    private var attributes: [NSAttributedString.Key: Any] {
        var attribute = self.placeholderAttribute ?? [:]
        if attribute[.foregroundColor] == nil {
            attribute[.foregroundColor] = UIColor(red: 187.0/255.0, green: 187.0/255.0, blue: 187.0/255.0, alpha: 1)
        }

        if attribute[.font] == nil {
            if self.font == nil {
                attribute[.font] = UIFont.systemFont(ofSize: 14)
            } else {
                attribute[.font] = self.font!
            }

        }

        return attribute
    }
    override open var text: String! {
        didSet {
            self.placeholderLayer.isHidden = self.text.count > 0
        }
    }
    let placeholderLayer = CATextLayer()

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInitView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChange(_:)), name: UITextView.textDidChangeNotification, object: nil)

        self.placeholderLayer.truncationMode = CATextLayerTruncationMode(rawValue: "end")
        self.placeholderLayer.isWrapped = true
        self.placeholderLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(self.placeholderLayer)

        self.textColor = Theme.shared[.text]
    }

    override open func layoutSubviews() {

        let x = self.textContainerInset.left + self.textContainer.lineFragmentPadding
        let y = self.textContainerInset.top
        let width = self.bounds.width - x - self.textContainerInset.right - self.textContainer.lineFragmentPadding
        let height = self.bounds.height - self.textContainerInset.top - self.textContainerInset.bottom

        self.placeholderLayer.frame = CGRect(x: x, y: y, width: width, height: height)

        super.layoutSubviews()
    }

    @objc func onTextChange(_ notification: Notification) {
        self.placeholderLayer.isHidden = self.text.count > 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
