//
//  ZZPickerRow.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/7/29.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

protocol ZZPickerToolbarDelegate: AnyObject {
    func willResignPicker()
}

class ZZPickerToolbar: UIView {
    var titleLabel: UILabel!
    weak var delegate: ZZPickerToolbarDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInitView() {
        self.backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.zFontSize(15).zColor(AppTheme.shared[.title])
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let confirmButton = UIButton()
        confirmButton.zColor(UIColor(hex: 0x528bd2)).zFontSize(14).zText("确定")
        confirmButton.contentEdgeInsets = UIEdgeInsets.make(8, 10, 8, 10)
        self.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        confirmButton.zBind { [unowned self] in
            self.delegate?.willResignPicker()
        }
        
        self.addBottomLine()
    }
}

typealias PickerCallback = (Int, String) -> String?
open class ZZPickerRow: UIView {
    static let pickerView: UIPickerView = {
        let view = UIPickerView()
        view.backgroundColor = .white
        return view
    }()
    static let toolbar = ZZPickerToolbar(frame: CGRect.make(0, 0, SCREEN_WIDTH, 44))
    
    var field: UITextField!
    var titleLabel: UILabel!
    var valueLabel: UILabel!
    private var indicatorView: UIImageView!
    
    var willPickAction: PickerCallback?
    open var placeholder: String? {
        didSet {
            if let value = placeholder {
                valueLabel.attributedText = value.styled.make({ (make) in
                    make.range().color(UIColor(hex: 0xbbbbbb))
                })
            } else {
                valueLabel.text = nil
            }
        }
    }
    var selectedIndex: Int = 0
    var selectedText: String?
    var options: [String] = [] {
        didSet {
            if field.isFirstResponder {
                let picker = type(of: self).pickerView
                picker.reloadAllComponents()
                picker.selectRow(selectedIndex, inComponent: 0, animated: false)
            }
        }
    }
    var isEnabled = true {
        didSet {
            self.indicatorView.isHidden = !isEnabled
            self.isUserInteractionEnabled = isEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInitView() {
        self.backgroundColor = .white
        
        field = UITextField()
        field.isHidden = true
        field.inputView = type(of: self).pickerView
        field.inputAccessoryView = type(of: self).toolbar
        self.addSubview(field)
        
        titleLabel = UILabel()
        titleLabel.zFontSize(14).zColor(AppTheme.shared[.title])
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        valueLabel = UILabel()
        valueLabel.zFontSize(14).zColor(AppTheme.shared[.text])
        self.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-27)
        }
        
        indicatorView = UIImageView(image: #imageLiteral(resourceName: "arrow_right.png"))
        self.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        
        valueLabel.bindTouchAction { [unowned self] (_) in
            if self.options.count > 0 {
                guard !self.field.isFirstResponder else {
                    return
                }
                self.field.becomeFirstResponder()
                
                type(of: self).toolbar.delegate = self
                type(of: self).toolbar.titleLabel.text = self.titleLabel.text
                
                let pickerView = type(of: self).pickerView
                pickerView.delegate = self
                pickerView.dataSource = self
                pickerView.reloadAllComponents()
                
                pickerView.selectRow(self.selectedIndex, inComponent: 0, animated: false)
                
            } else {
                self.field.resignFirstResponder()
            }
        }
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}

extension ZZPickerRow: UIPickerViewDelegate, UIPickerViewDataSource, ZZPickerToolbarDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    private func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return options[row].styled.make {$0.range().fontSize(14)}
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return options[row]
//    }
    
    func willResignPicker() {
        let targetIndex = type(of: self).pickerView.selectedRow(inComponent: 0)
        let targetText = self.options[targetIndex]
        if let callback = self.willPickAction {
            let result = callback(targetIndex, targetText)
            if result != nil {
                self.valueLabel.text = result
                self.selectedIndex = targetIndex
                self.selectedText = result
            }
        } else {
            self.valueLabel.text = targetText
            self.selectedIndex = targetIndex
            self.selectedText = targetText
        }
        
        self.field.resignFirstResponder()
    }
}
