//
//  FWDateView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/27.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

/// 确定回调
public typealias FWDateViewConfirmBlock = (_ datePicker: UIDatePicker) -> Void

@objc open class FWDateView: FWPopupView {
    
    @objc public let property = FWDateViewProperty()
    
    private var confirmBtn: UIButton?
    private var cancelBtn: UIButton?
    
    private let datePicker = UIDatePicker()
    
    private var confirmBlock: FWDateViewConfirmBlock?
    private var cancelBlock: FWPopupVoidBlock?
    
    @objc open class func date(confirmBlock:@escaping FWDateViewConfirmBlock, cancelBlock:@escaping FWPopupVoidBlock) -> FWDateView {
        
        let dateView = FWDateView()
        dateView.setupUI(confirmBlock: confirmBlock, cancelBlock: cancelBlock)
        return dateView
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FWDateView {
    
    private func setupUI(confirmBlock:@escaping FWDateViewConfirmBlock, cancelBlock:@escaping FWPopupVoidBlock) {
        
        self.backgroundColor = self.property.vbackgroundColor
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.property.datePickerHeight + self.property.btnHeight)
        
        self.popupType = .sheet
        
        self.cancelBtn = self.setupBtn(frame: CGRect(x: 0, y: 0, width: self.property.btnWidth, height: self.property.btnHeight), title: self.property.cancelBtnTitle, tag: 0)
        self.addSubview(self.cancelBtn!)
        
        self.confirmBtn = self.setupBtn(frame: CGRect(x: self.frame.width - self.property.btnWidth, y: 0, width: self.property.btnWidth, height: self.property.btnHeight), title: self.property.confirmBtnTitle, tag: 1)
        self.addSubview(self.confirmBtn!)
        
        self.datePicker.frame = CGRect(x: 0, y: self.property.btnHeight, width: self.frame.width, height: self.property.datePickerHeight)
        self.datePicker.backgroundColor = self.property.vbackgroundColor
        self.addSubview(self.datePicker)
        
        self.confirmBlock = confirmBlock
        self.cancelBlock = cancelBlock
    }
    
    private func setupBtn(frame: CGRect, title: String, tag: Int) -> UIButton {
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        btn.frame = frame
        btn.tag = tag
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(self.property.btnTitleColor, for: .normal)
        btn.backgroundColor = self.property.vbackgroundColor
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.property.btnTitleFont)
        return btn
    }
    
    @objc private func btnAction(_ sender: Any) {
        
        let btn = sender as! UIButton
        if btn.tag == 0 {
            self.cancelBlock!()
        } else {
            self.confirmBlock!(self.datePicker)
        }
        
        self.hide()
    }
}


@objc open class FWDateViewProperty : FWPopupViewProperty {
    
    // UIDatePicker的高度
    @objc public var datePickerHeight: CGFloat = 240
    // 确定、取消按钮的高度
    @objc public var btnHeight: CGFloat = 40
    // 确定、取消按钮的宽度
    @objc public var btnWidth: CGFloat = 60
    // 按钮文字颜色
    @objc public var btnTitleColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 按钮文字大小
    @objc public var btnTitleFont: CGFloat = 17.0
    // 取消按钮名称
    @objc public var cancelBtnTitle = "取消"
    // 确定按钮名称
    @objc public var confirmBtnTitle = "确定"
}
