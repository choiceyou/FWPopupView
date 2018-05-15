//
//  FWAlertView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/21.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

public typealias FWPopupInputHandler = (_ text: String) -> Void

open class FWAlertView: FWPopupView {
    
    // FWAlertView的相关属性
    @objc public var property = FWAlertViewProperty()
    
    // 输入框回调
    @objc public var inputHandler: FWPopupInputHandler?
    
    
    private var titleStr: String?
    private var detailStr: String?
    private var inputPlaceholder: String?
    private var actionItemArray: [FWPopupItem] = []
    
    private var titleLabel: UILabel?
    private var detailLabel: UILabel?
    private var inputTF: UITextField?
    private var customView: UIView?
    
    private var commponenetArray: [UIView] = []
    
    
    /// 单个按钮的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - confirmBlock: 确定按钮回调
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, confirmBlock: FWPopupItemHandler? = nil) -> FWAlertView {
        
        let alertView = FWAlertView()
        let items = [FWPopupItem(title: alertView.property.defaultTextOK, itemType: .normal, isCancel: false, handler: confirmBlock)]
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: nil, keyboardType: .default, customView: nil, items: items)
        return alertView
    }
    
    /// 两个按钮的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - confirmBlock: 确定按钮回调
    ///   - cancelBlock: 取消按钮回调
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, confirmBlock: FWPopupItemHandler? = nil, cancelBlock: FWPopupItemHandler? = nil) -> FWAlertView {
        
        let alertView = FWAlertView()
        let items = [FWPopupItem(title: alertView.property.defaultTextCancel, itemType: .normal, isCancel: true, handler: cancelBlock),
                     FWPopupItem(title: alertView.property.defaultTextConfirm, itemType: .normal, isCancel: false, handler: confirmBlock)]
        
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: nil, keyboardType: .default, customView: nil, items: items)
        return alertView
    }
    
    /// 可带输入框的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, inputPlaceholder: String?, keyboardType: UIKeyboardType, items: [FWPopupItem]) -> FWAlertView {
        
        let alertView = FWAlertView()
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, customView: nil, items: items)
        return alertView
    }
    
    /// 可带输入框、自定义视图的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    ///   - customView: 自定义UI
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, inputPlaceholder: String?, keyboardType: UIKeyboardType, customView: UIView?, items: [FWPopupItem]) -> FWAlertView {
        
        let alertView = FWAlertView()
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, customView: customView, items: items)
        return alertView
    }
    
    /// 可带输入框、自定义视图的弹窗，可设置Alert相关属性
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    ///   - customView: 自定义UI
    ///   - vProperty: FWAlertView的相关属性
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, inputPlaceholder: String?, keyboardType: UIKeyboardType, customView: UIView?, items: [FWPopupItem], vProperty: FWAlertViewProperty?) -> FWAlertView {
        
        let alertView = FWAlertView()
        if vProperty != nil {
            alertView.property = vProperty!
        }
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, customView: customView, items: items)
        return alertView
    }
    
    open override func showKeyboard() {
        self.inputTF?.becomeFirstResponder()
    }
    
    open override func hideKeyboard() {
        self.inputTF?.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
    }
}


extension FWAlertView {
    
    private func setupUI(title: String?, detail: String?, inputPlaceholder: String?, keyboardType: UIKeyboardType, customView: UIView?, items: [FWPopupItem]) {
        
        if items.count == 0 {
            return
        }
        
        self.backgroundColor = self.property.vbackgroundColor
        self.clipsToBounds = true
        
        self.popupType = .alert
        self.animationDuration = 0.3
        
        self.actionItemArray = items
        
        self.withKeyboard = (inputPlaceholder != nil)
        
        self.layer.cornerRadius = self.property.cornerRadius
        self.clipsToBounds = true
        
        self.frame.origin.x = (UIScreen.main.bounds.width - self.property.vwidth) / 2
        self.frame.origin.y = 100
        self.frame.size.width = CGFloat(self.property.vwidth)
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        var currentMaxY:CGFloat = self.property.topBottomMargin
        
        if title != nil && !title!.isEmpty {
            self.titleLabel = UILabel(frame: CGRect(x: self.property.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.property.letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.text = title
            self.titleLabel?.textColor = self.property.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.property.titleFontSize)
            self.titleLabel?.numberOfLines = 5
            self.titleLabel?.backgroundColor = UIColor.clear
            
            self.titleLabel?.sizeToFit()
            
            self.titleLabel?.frame = CGRect(x: self.property.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.property.letfRigthMargin * 2, height: self.titleLabel!.frame.height)
            
            currentMaxY = self.titleLabel!.frame.maxY
            
            self.commponenetArray.append(self.titleLabel!)
        }
        
        if detail != nil && !detail!.isEmpty {
            currentMaxY += self.property.topBottomMargin
            
            self.detailLabel = UILabel(frame: CGRect(x: self.property.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.property.letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.detailLabel!)
            self.detailLabel?.text = detail
            self.detailLabel?.textColor = self.property.detailColor
            self.detailLabel?.textAlignment = .center
            self.detailLabel?.font = UIFont.boldSystemFont(ofSize: self.property.detailFontSize)
            self.detailLabel?.numberOfLines = 5
            self.detailLabel?.backgroundColor = UIColor.clear
            
            self.detailLabel?.sizeToFit()
            
            self.detailLabel?.frame = CGRect(x: self.property.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.property.letfRigthMargin * 2, height: self.detailLabel!.frame.height)
            
            currentMaxY = self.detailLabel!.frame.maxY
            
            self.commponenetArray.append(self.detailLabel!)
        }
        
        if inputPlaceholder != nil {
            currentMaxY += self.property.topBottomMargin
                
            self.inputTF = UITextField(frame: CGRect(x: self.property.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.property.letfRigthMargin * 2, height: 40))
            self.addSubview(self.inputTF!)
            self.inputTF?.placeholder = inputPlaceholder
            self.inputTF?.textAlignment = .center
            self.inputTF?.clearButtonMode = .whileEditing
            self.inputTF?.leftViewMode = .always
            self.inputTF?.layer.borderColor = self.property.splitColor.cgColor
            self.inputTF?.layer.borderWidth = self.property.splitWidth
            self.inputTF?.layer.cornerRadius = self.property.cornerRadius
            self.inputTF?.keyboardType = keyboardType
            
            currentMaxY = self.inputTF!.frame.maxY
            
            self.commponenetArray.append(self.inputTF!)
        }
        
        if customView != nil {
            currentMaxY += self.property.topBottomMargin
            
            self.customView = customView
            self.customView?.frame = CGRect(x: (self.frame.width - self.customView!.frame.width) / 2, y: currentMaxY, width: self.customView!.frame.width, height: self.customView!.frame.height)
            
            self.addSubview(self.customView!)
            
            currentMaxY = self.customView!.frame.maxY
            
            self.commponenetArray.append(self.customView!)
        }
        
        currentMaxY += self.property.topBottomMargin
        
        // 调整
        if currentMaxY < self.property.alertViewMinHeight - self.property.buttonHeight {
            currentMaxY = self.property.alertViewMinHeight - self.property.buttonHeight
            
            var tmpMargin:CGFloat = 0
            var tmpHeight:CGFloat = currentMaxY
            for view in self.commponenetArray {
                tmpHeight -= view.frame.height
            }
            tmpMargin = tmpHeight / CGFloat((self.commponenetArray.count + 1))
            
            var tmpHeight2 = tmpMargin
            for view in self.commponenetArray {
                view.frame.origin.y = tmpHeight2
                tmpHeight2 = view.frame.maxY + tmpMargin
            }
        }
        
        let btnContrainerView = UIView(frame: CGRect(x: 0, y: currentMaxY, width: self.frame.width, height: self.property.buttonHeight))
        btnContrainerView.backgroundColor = UIColor.clear
        self.addSubview(btnContrainerView)
        
        currentMaxY = btnContrainerView.frame.maxY
        
        var tmpIndex = 0
        for popupItem: FWPopupItem in items {
            
            let btn = UIButton(type: .custom)
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btnContrainerView.addSubview(btn)
            btn.tag = tmpIndex
            
            if items.count == 1 {
                btn.frame = CGRect(x: -self.property.splitWidth, y: 0, width: btnContrainerView.frame.width + self.property.splitWidth * 2, height: self.property.buttonHeight + self.property.splitWidth)
            } else if items.count == 2 {
                let btnW = (btnContrainerView.frame.width + self.property.splitWidth * 4) / 2
                btn.frame = CGRect(x: -self.property.splitWidth + btnW * CGFloat(tmpIndex), y: 0, width: btnW, height: self.property.buttonHeight + self.property.splitWidth)
            } else {
                btn.frame = CGRect(x: -self.property.splitWidth, y: self.property.buttonHeight * CGFloat(tmpIndex), width: btnContrainerView.frame.width + self.property.splitWidth * 2, height: self.property.buttonHeight + self.property.splitWidth)
                
                if tmpIndex > 0 {
                    currentMaxY += btn.frame.height
                    if tmpIndex == items.count - 1 {
                        btnContrainerView.frame.size.height = btn.frame.maxY
                    }
                }
            }
            
            btn.backgroundColor = self.backgroundColor
            btn.setTitle(popupItem.title, for: .normal)
            btn.setTitleColor(popupItem.highlight ? self.property.itemHighlightColor : self.property.itemNormalColor, for: .normal)
            btn.layer.borderWidth = self.property.splitWidth
            btn.layer.borderColor = self.property.splitColor.cgColor
            btn.setBackgroundImage(self.getImageWithColor(color: btn.backgroundColor!), for: .normal)
            btn.setBackgroundImage(self.getImageWithColor(color: self.property.itemPressedColor), for: .highlighted)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.property.buttonFontSize)
            
            tmpIndex += 1
        }
        
        self.frame.size.height = currentMaxY
    }
}

extension FWAlertView {
    
    @objc private func btnAction(_ sender: Any) {
        
        let btn = sender as! UIButton
        let item = self.actionItemArray[btn.tag]
        if item.disabled {
            return
        }
        
        if self.withKeyboard && item.isCancel == false {
            if self.inputTF!.text != nil && !self.inputTF!.text!.isEmpty {
                self.hide()
            }
        } else {
            self.hide()
        }
        
        if self.inputHandler != nil && item.isCancel == false {
            self.inputHandler!(self.inputTF!.text!)
        } else {
            if item.itemHandler != nil {
                item.itemHandler!(btn.tag)
            }
        }
    }
}


/// FWAlertView的相关属性
open class FWAlertViewProperty: FWPopupViewProperty {
    
    // FWAlertView宽度
    @objc open var vwidth: CGFloat              = 275.0
    
    // 描述字体大小
    @objc open var detailFontSize: CGFloat      = 14.0
    
    // 描述文字颜色
    @objc open var detailColor: UIColor         = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    
    // 确定按钮默认名称
    @objc open var defaultTextOK                = "知道了"
    // 取消按钮默认名称
    @objc open var defaultTextCancel            = "取消"
    // 确定按钮默认名称
    @objc open var defaultTextConfirm           = "确定"
    
    // 为保持FWAlertView美观，设置FWAlertView的最小高度
    @objc open var alertViewMinHeight: CGFloat  = 150
    
    public override init() {
        super.init()
    }
}

