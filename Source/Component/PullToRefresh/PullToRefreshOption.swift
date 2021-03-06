//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import UIKit

struct PullToRefreshConst {
    static let pullTag = 810
    static let pushTag = 811
    static let alpha = true
    static let height: CGFloat = 60
    static let pushHeight: CGFloat = 40
    static let imageName: String = "pulltorefresharrow.png"
    static let animationDuration: Double = 0.5
    static let fixedTop = true // PullToRefreshView fixed Top
}

public struct PullToRefreshOption {
    public var backgroundColor: UIColor
    public var indicatorColor: UIColor
    public var autoStopTime: Double // 0 is not auto stop
    public var fixedSectionHeader: Bool // Update the content inset for fixed section headers

    public init(backgroundColor: UIColor = .clear, indicatorColor: UIColor = .gray, autoStopTime: Double = 0, fixedSectionHeader: Bool = false) {
        self.backgroundColor = backgroundColor
        self.indicatorColor = indicatorColor
        self.autoStopTime = autoStopTime
        self.fixedSectionHeader = fixedSectionHeader
    }
}

public enum PullToRefreshState {
    case pulling // 初始状态
    case triggered //已触发
    case refreshing //触发
    case stop //结束
    case finish //完成
}
