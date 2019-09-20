//
//  H5BackView.swift
//  Alamofire
//
//  Created by William on 2019/9/13.
//

import UIKit

typealias WebBackViewAction = (Bool) -> Void
public class H5BackView: AlignmentRectView {
    public enum Style {
        case `default`, simple
    }
    var style: Style = .default
    public var backButton: UIButton!
    var closeButton: UIButton!
    var touchAction: WebBackViewAction?

    override public var insets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
    }

    public init(style: Style) {
        super.init(frame: .zero)
        self.style = style
        self.commonInitView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        var w: CGFloat = 32
        let h: CGFloat = 44
        backButton = UIButton()
        backButton.setImage(UIImage(named: "icon_back_white")!.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.frame = CGRect(x: -4, y: (44 - 32) / 2 - 1.5, width: 32, height: 32)
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        self.addSubview(backButton)

        if self.style == .default {
            closeButton = UIButton()
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            closeButton.setTitleColor(.white, for: .normal)
            closeButton.setTitle("关闭", for: .normal)
            closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
            closeButton.frame = CGRect(x: 32, y: 4 + 1.5, width: 34, height: 32)
            self.addSubview(closeButton)

            w = 80
        }

        if #available(iOS 11, *) {
            translatesAutoresizingMaskIntoConstraints = false
            widthAnchor.constraint(equalToConstant: w).isActive = true
            heightAnchor.constraint(equalToConstant: h).isActive = true
        } else {
            frame = CGRect(x: 0, y: 0, width: w, height: h)
        }
    }

    @objc func onBack() {
        self.touchAction?(false)
    }

    @objc func onClose() {
        self.touchAction?(true)
    }
}
