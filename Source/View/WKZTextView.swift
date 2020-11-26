//
//  WKZTextView.swift
//  collection
//
//  Created by william on 09/06/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

open class ZZTextView: UITextView {
    public var placeholder: String? {
        get { placeholderLabel.text }
        set { placeholderLabel.text = newValue}
    }

    public var attributedPlaceholder: NSAttributedString? {
        get { placeholderLabel.attributedText }
        set { placeholderLabel.attributedText = newValue }
    }

    override open var text: String! {
        didSet {
            togglePlaceholder(text.isEmpty)
        }
    }

    private let placeholderLabel = UILabel()

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInitView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChange(_:)), name: UITextView.textDidChangeNotification, object: nil)

        placeholderLabel.numberOfLines = 0
        self.placeholderLabel.textColor = UIColor(red: 187.0/255.0, green: 187.0/255.0, blue: 187.0/255.0, alpha: 1)
        self.placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(self.placeholderLabel)

        self.textColor = Theme.shared[.text]
    }

    override open func layoutSubviews() {

        let x = self.textContainerInset.left + self.textContainer.lineFragmentPadding
        let y = self.textContainerInset.top
        let width = self.bounds.width - x - self.textContainerInset.right - self.textContainer.lineFragmentPadding
        let height = self.bounds.height - self.textContainerInset.top - self.textContainerInset.bottom

        let size = self.placeholderLabel.sizeThatFits(CGSize(width: width, height: height))
        self.placeholderLabel.frame = CGRect(x: x, y: y, width: size.width, height: size.height)

        super.layoutSubviews()
    }

    @objc func onTextChange(_ notification: Notification) {
        togglePlaceholder(text.isEmpty)
    }

    func togglePlaceholder(_ flag: Bool) {
        self.placeholderLabel.isHidden = !flag
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
