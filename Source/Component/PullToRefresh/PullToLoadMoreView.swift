//
//  PullToLoadMoreView.swift
//  Alamofire
//
//  Created by xftt on 2019/12/4.
//

import UIKit

final class PullToLoadMoreView: UIView, PullRefreshView {
    fileprivate var options: PullToRefreshOption
    fileprivate let contentLabel = UILabel()

    var state: PullRefreshState = .pulling(0) {
        didSet {
//            if self.state == oldValue {
//                return
//            }
            switch self.state {
            case .stop:
                break
            case .finish:
                self.contentLabel.text = "—— 没有记录了 ——"
            case .refreshing:
                break
            case .pulling: //starting point\
                self.contentLabel.text = "加载中..."
            case .triggered:
                break
            case .stopped:
                break
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(frame: CGRect, options: PullToRefreshOption) {
        self.options = options
        super.init(frame: frame)
        self.backgroundColor = self.options.backgroundColor

        self.contentLabel.font = UIFont.systemFont(ofSize: 10)
        self.contentLabel.textColor = UIColor(hex: 0xaaaaaa)
        self.contentLabel.textAlignment = .center
        self.contentLabel.text = "加载中..."
        self.contentLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        self.addSubview(contentLabel)
        self.autoresizingMask = .flexibleWidth
    }
}
