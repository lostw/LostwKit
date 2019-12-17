//
//  PullRefreshState.swift
//  Alamofire
//
//  Created by William on 2019/12/11.
//

import Foundation

public enum PullRefreshState {
    case pulling(CGFloat) // 初始状态
    case triggered //已触发
    case refreshing //触发
    case stop //结束
    case stopped //
    case finish //完成
}

public protocol PullRefreshView: UIView {
    var state: PullRefreshState { get set }
}
