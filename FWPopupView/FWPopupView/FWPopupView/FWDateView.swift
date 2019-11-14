//
//  FWDateView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/27.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

/// 确定回调
public typealias FWDateViewConfirmBlock = (_ datePicker: UIDatePicker) -> Void

open class FWDateView: FWPopupView {
    
    @objc public let datePicker = UIDatePicker()
    
    private var confirmBtn: UIButton?
    private var cancelBtn: UIButton?
    
    private var confirmBlock: FWDateViewConfirmBlock?
    private var cancelBlock: FWPopupVoidBlock?
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - confirmBlock: 点击确定按钮回调
    ///   - cancelBlock: 点击取消按钮回调
    /// - Returns: self
    @objc open class func date(confirmBlock: FWDateViewConfirmBlock? = nil, cancelBlock: FWPopupVoidBlock? = nil) -> FWDateView {
        
        let dateView = FWDateView()
        dateView.setupUI(confirmBlock: confirmBlock, cancelBlock: cancelBlock)
        return dateView
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.vProperty = FWDateViewProperty()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FWDateView {
    
    private func setupUI(confirmBlock: FWDateViewConfirmBlock? = nil, cancelBlock: FWPopupVoidBlock? = nil) {
        
        let property = self.vProperty as! FWDateViewProperty
        
        self.datePicker.setValue(property.pickerTextColor, forKey: "textColor")
        
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: property.datePickerHeight + property.btnHeight)
        
        self.cancelBtn = self.setupBtn(frame: CGRect(x: 0, y: 0, width: property.btnWidth, height: property.btnHeight), title: property.cancelBtnTitle, tag: 0)
        self.addSubview(self.cancelBtn!)
        
        self.confirmBtn = self.setupBtn(frame: CGRect(x: self.frame.width - property.btnWidth, y: 0, width: property.btnWidth, height: property.btnHeight), title: property.confirmBtnTitle, tag: 1)
        self.addSubview(self.confirmBtn!)
        
        self.datePicker.frame = CGRect(x: 0, y: property.btnHeight, width: self.frame.width, height: property.datePickerHeight)
        self.datePicker.backgroundColor = self.backgroundColor
        // 默认
        self.datePicker.locale = Locale(identifier: "zh_Hans_CN")
        self.addSubview(self.datePicker)
        
        self.confirmBlock = confirmBlock
        self.cancelBlock = cancelBlock
        
        property.popupCustomAlignment = .bottomCenter
        property.popupAnimationType = .position
    }
    
    private func setupBtn(frame: CGRect, title: String, tag: Int) -> UIButton {
        
        let property = self.vProperty as! FWDateViewProperty
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        btn.frame = frame
        btn.tag = tag
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(property.btnTitleColor, for: .normal)
        btn.backgroundColor = self.backgroundColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: property.btnTitleFont)
        return btn
    }
    
    @objc private func btnAction(_ sender: Any) {
        
        let btn = sender as! UIButton
        if btn.tag == 0 && self.cancelBlock != nil {
            self.cancelBlock!()
        } else if btn.tag == 1 && self.confirmBlock != nil {
            self.confirmBlock!(self.datePicker)
        }
        
        self.hide()
    }
}


open class FWDateViewProperty : FWPopupViewProperty {
    
    // UIDatePicker的高度
    @objc public var datePickerHeight: CGFloat = 240
    
    // 确定、取消按钮的高度
    @objc public var btnHeight: CGFloat = 40
    // 确定、取消按钮的宽度
    @objc public var btnWidth: CGFloat = 60
    // 时间选择器文字颜色
    @objc public var pickerTextColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 按钮文字颜色
    @objc public var btnTitleColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 按钮文字大小
    @objc public var btnTitleFont: CGFloat = 17.0
    // 取消按钮名称
    @objc public var cancelBtnTitle = "取消"
    // 确定按钮名称
    @objc public var confirmBtnTitle = "确定"
    
    public override func reSetParams() {
        super.reSetParams()
        
    }
}
