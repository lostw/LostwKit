//
//  CounterButton.swift
//  Zhangzhi
//
//  Created by william on 18/07/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit

public typealias ZZCounterdownStart = (Bool) -> Void
public protocol ZZCounterdownButton: UIButton {
    var counterController: ZZCounterdownController {get set}
    func onStateChange(_ state: ZZCounterdownController.CounterState)

    func willStart(_ action: ((ZZCounterdownStart) -> Void))
    func start()
    func resume(_ remain: Int)
}

public extension ZZCounterdownButton {
    func start() {
        self.counterController.start()
    }

    func resume(_ remain: Int) {
        self.counterController.resume(remain)
    }

    func willStart(_ action: ((ZZCounterdownStart) -> Void)) {
        self.counterController.willStart(action)
    }
}

public class ZZCounterdownController {
    public enum CounterState {
        case ready, loading, counting(Int), done
    }

    public weak var slaver: ZZCounterdownButton? {
        didSet {
            slaver?.onStateChange(.ready)
        }
    }
    var timer: Timer?
    public var duration: Int = 60
    public var isReady = true
    var remain: Int = 0
    public var state: CounterState = .ready {
        didSet {
           slaver?.onStateChange(state)
        }
    }

    public init() {}

    public func willStart(_ action:  (( @escaping ZZCounterdownStart) -> Void)) {
        state = .loading
        action({
            if $0 {
                self.start()
            } else {
                self.state = .ready
            }
        })
    }

    func start() {
        self.remain = self.duration

        if let timer = self.timer {
            timer.invalidate()
        }

        self.tick()
    }

    func resume(_ remain: Int) {
        self.remain = remain

        if let timer = self.timer {
            timer.invalidate()
        }

        self.tick()
    }

    @objc func tick() {
        self.state = .counting(remain)
        self.remain -= 1

        if self.remain <= 0 {
            self.state = .done
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: false)
        }
    }
}

public class ZZCodeButton: UIButton, ZZCounterdownButton {
    public var counterController = ZZCounterdownController()
    override public var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.layer.borderWidth = 1
                self.backgroundColor = UIColor.clear
            } else {
                self.layer.borderWidth = 0
                self.backgroundColor = UIColor(hex: 0xe4e4e4)
            }
        }
    }

    public func onStateChange(_ state: ZZCounterdownController.CounterState) {
        switch state {
        case .ready:
            self.isEnabled = true
            self.setTitle("获取验证码", for: .normal)
            self.setTitle("获取验证码", for: .disabled)
        case .loading:
            self.isEnabled = false
            self.setTitle("请求中...", for: .disabled)
        case .counting(let tick):
            self.setTitle("重发(\(tick))", for: .disabled)
            self.isEnabled = false
        case .done:
            self.isEnabled = true
            self.setTitle("重发验证码", for: .normal)
            self.setTitle("重发验证码", for: .disabled)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
//        self.counterController =
        self.commonInitView()

        self.counterController.slaver = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInitView() {
        self.backgroundColor = UIColor.clear
        self.setTitleColor(AppTheme.shared[.majorText], for: .normal)
        self.setTitleColor(UIColor(hex: 0x9f9f9f), for: .disabled)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)

        self.layer.cornerRadius = 3
        self.layer.borderWidth = 1
        self.layer.borderColor = AppTheme.shared[.majorText].cgColor
    }
}
