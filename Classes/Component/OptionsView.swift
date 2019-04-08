//
//  OptionsView.swift
//  Zhangzhi
//
//  Created by william on 25/08/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit


@objc protocol OptionDropViewDelegate: AnyObject {
    func numberOfSectionsInDropView(_ view: OptionDropView) -> Int
    func dropView(_ view: OptionDropView, defaultIndexForSection section: Int) -> Int
    func dropView(_ view: OptionDropView, titleAt indexPath: IndexPath) -> String
    func dropView(_ view: OptionDropView, numberOfRowsInSection section:Int) -> Int
    func dropView(_ view: OptionDropView, selectAt indexPath: IndexPath)
    
    @objc optional func dropView(_ view: OptionDropView, dropTitleAt indexPath: IndexPath) -> String
    @objc optional func showDropView()
}

class OptionSectionView: UIView {
    fileprivate let titleLabel = UILabel()
    fileprivate let triangle = CAShapeLayer()
    var title: String? {
        didSet {
            self.titleLabel.text = title
            self.updateLayout()
        }
    }
    var isHighlight: Bool = false {
        didSet {
            if self.isHighlight {
                self.titleLabel.textColor = AppTheme.shared[.majorText]
                self.triangle.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
            } else {
                self.titleLabel.textColor = AppTheme.shared[.text]
                self.triangle.transform = CATransform3DIdentity
            }
        }
    }
    override var frame: CGRect {
        didSet {
            self.updateLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func commonInitView() {
        self.titleLabel.textColor = AppTheme.shared[.text]
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(self.titleLabel)
        
        self.triangle.fillColor = UIColor(hex: 0xd6d6d6).cgColor
        self.triangle.path = self.trianglePath().cgPath
        self.layer.addSublayer(self.triangle)
        
        self.updateLayout()
    }
    
    func updateLayout() {
        let size = self.titleLabel.sizeThatFits(self.bounds.size)
        self.titleLabel.frame = self.bounds.rectForCenterSize(size)
        
        self.triangle.frame = CGRect(x: self.titleLabel.frame.origin.x + self.titleLabel.frame.width + 4,
                                     y: (self.bounds.height - 4) / 2,
                                     width: 8,
                                     height: 4)
    }
    
    func trianglePath() -> UIBezierPath {
        let w = 8, h = 4
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x:w, y:0))
        path.addLine(to: CGPoint(x:w/2, y:h))
        path.close()
        
        return path
    }
}

class OptionDropView: UIView {
    static let identifier = "cellIdentifier"
    weak var delegate: OptionDropViewDelegate?
    var rowHeight: CGFloat = 42
    fileprivate var sectionViews = [OptionSectionView]()
    fileprivate var currentSection = -1
    fileprivate lazy var coverView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(hex: 0x000000, alpha: 0.6)
        view.bindTouchAction({ [unowned self] (tap) in
            self.touchSection(atIndex: -1)
        })
        return view
    }()
    fileprivate lazy var listView: UITableView = {
        let view = UITableView()
        view.isHidden = true
        view.delegate = self
        view.dataSource = self
        
        view.separatorInset = UIEdgeInsets.zero
        view.layoutMargins = UIEdgeInsets.zero
        
        return view
    }()
    
    override var bounds: CGRect {
        didSet {
            self.updateLayout()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reloadData() {
        guard let delegate = self.delegate else {
            return
        }
        
        let numberOfSections = delegate.numberOfSectionsInDropView(self)
        guard numberOfSections > 0 else {
            return
        }
        
        self.removeSubviews()
        self.sectionViews.removeAll()
        
        
        for idx in 0..<numberOfSections {
            let sectionView = OptionSectionView()
            let selectedIdx = delegate.dropView(self, defaultIndexForSection: idx)
            let title = delegate.dropView(self, titleAt: IndexPath(row: selectedIdx, section: idx))
            sectionView.title = title
            self.addSubview(sectionView)
            
            self.sectionViews.append(sectionView)
        }
        
        self.bindTouchAction { [unowned self] (tap) in
            let point = tap.location(in: self)
            for (idx, item) in self.sectionViews.enumerated() {
                if item.frame.contains(point) {
                    self.touchSection(atIndex: idx)
                    return
                }
            }
        }
        
        self.updateLayout()
        
    }
    
    func touchSection(atIndex index: Int) {
        //清除之前的tab选中状态
        if self.currentSection != -1 {
            let sectionView = self.sectionViews[self.currentSection]
            sectionView.isHighlight = false
        }
        
        //点击同一个tab, 收起菜单
        if self.currentSection == index {
            self.currentSection = -1
        } else {
            self.currentSection = index
        }
        
        
        //选中了新的tab
        if self.currentSection != -1 {
            let sectionView = self.sectionViews[self.currentSection]
            sectionView.isHighlight = true
        }
        
        //更新菜单
        self.updateDropList()
    }
    
    func updateDropList() {
        if self.currentSection == -1 {
            self.collapse()
        } else {
            if let superview = self.superview {
                self.superview?.addSubview(self.coverView)
                self.superview?.addSubview(self.listView)
                self.listView.isHidden = false
                self.coverView.isHidden = false
                self.superview?.bringSubviewToFront(self)
                self.delegate?.showDropView?()
            
                let numberOfRows = self.delegate!.dropView(self, numberOfRowsInSection: self.currentSection)
                var height:CGFloat = 0
                if (numberOfRows > 6) {
                    height = 6 * self.rowHeight - 21
                    self.listView.isScrollEnabled = true
                } else {
                    height = CGFloat(numberOfRows) * self.rowHeight
                    self.listView.isScrollEnabled = false
                }
                self.coverView.frame = superview.bounds
                let rect = CGRect(x: 0, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: height)
                
                //保证动画开始时的宽度
                if self.listView.frame.width == 0 {
                    var startRect = self.listView.frame
                    startRect.size.width = self.frame.size.width
                    self.listView.frame = startRect
                }
                
                UIView.animate(withDuration: 0.2, animations: { 
                    self.coverView.alpha = 0.3
                    self.listView.frame = rect
                })
                
                self.listView.reloadData()
            }
        }
    }
    
    func collapse() {
        if !self.listView.isHidden {
            var rect = self.listView.frame
            rect.size.height = 0
            
            UIView.animate(withDuration: 0.2, animations: {
                self.listView.frame = rect
                self.coverView.alpha = 0
            }, completion: { finished in
                self.listView.isHidden = true
                self.coverView.isHidden = true
            })
        }
    }
    
    func commonInitView() {
        self.backgroundColor = UIColor.white
    }
    
    func updateLayout() {
        guard let delegate = self.delegate else {
            return
        }
        
        let numberOfSections = delegate.numberOfSectionsInDropView(self)
        guard numberOfSections > 0 else {
            return
        }
        
        let w = self.bounds.width / CGFloat(numberOfSections)
        for (idx, view) in self.sectionViews.enumerated() {
            view.frame = CGRect(x: CGFloat(idx) * w, y: 0, width: w, height: self.bounds.height)
        }
    }
}

extension OptionDropView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let delegate = self.delegate else {
            return 0
        }
        
        return delegate.dropView(self, numberOfRowsInSection: self.currentSection)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: OptionDropView.identifier)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: OptionDropView.identifier)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.tintColor = AppTheme.shared[.majorText]
            
            cell.layoutMargins = UIEdgeInsets.zero
        }
        
        if let delegate = self.delegate {
            let idx = delegate.dropView(self, defaultIndexForSection: self.currentSection)
            if idx == indexPath.row {
                cell.textLabel?.textColor = AppTheme.shared[.majorText]
                cell.accessoryType = .checkmark
            } else {
                cell.textLabel?.textColor = AppTheme.shared[.text]
                cell.accessoryType = .none
            }
            var text = delegate.dropView?(self, dropTitleAt: IndexPath(row: indexPath.row, section: self.currentSection))
            if text == nil{
                text = delegate.dropView(self, titleAt: IndexPath(row: indexPath.row, section: self.currentSection))
            }
            cell.textLabel?.text = text
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let delegate = self.delegate {
            let indexPath = IndexPath(row: indexPath.row, section: self.currentSection)
            let title = delegate.dropView(self, titleAt: indexPath)
            self.sectionViews[self.currentSection].title = title
            delegate.dropView(self, selectAt: indexPath)
        }
        
        self.touchSection(atIndex: -1)
    }
}
