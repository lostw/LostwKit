//
//  ZZAverageView.swift
//  Alamofire
//
//  Created by William on 2019/6/4.
//

import UIKit
import SnapKit

/**
 * 用于subview是平分容器的情况
 * 支持自定义间隔、分隔线
 */
public class ZZAverageView: UIView {
    public var padding: UIEdgeInsets = .zero
    public var space: CGFloat = 0   //
    public var enableSeperatorLine = false
    public var lineColor: UIColor?
    public var linePadding: UIEdgeInsets = .zero

    public func arrangeSubviews(_ views: [UIView]) {
        guard views.count > 0 else { return }

        self.removeSubviews()

        var prevView: UIView! = nil
        for (idx, view) in views.enumerated() {
            self.addSubview(view)
            view.snp.makeConstraints { (make) in
                if prevView == nil {
                    make.left.equalToSuperview().offset(padding.left)
                } else {
                    make.left.equalTo(prevView.snp.right).offset(space)
                    make.width.equalTo(prevView.snp.width)
                }

                make.top.equalToSuperview().offset(padding.top)
                make.bottom.equalToSuperview().offset(-padding.bottom)

                if idx == views.count - 1 {
                    make.right.equalToSuperview().offset(-padding.right)
                }
            }

            prevView = view
        }

        if enableSeperatorLine && views.count > 1 {
            let lineColor = self.lineColor ?? Theme.shared[.border]
            for idx in 1..<views.count {
                let line = UIView()
                line.backgroundColor = lineColor
                self.addSubview(line)
                line.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview().offset(linePadding.top)
                    make.left.equalTo(views[idx - 1].snp.right).offset(space / 2 - ONE_PX_ADJUST)
                    make.width.equalTo(ONE_PX)
                    make.bottom.equalToSuperview().offset(-linePadding.bottom)
                })
            }
        }
    }
}
