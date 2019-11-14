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

public typealias FWPopupInputBlock = (_ text: String) -> Void

open class FWAlertView: FWPopupView {
    
    // 输入框回调
    @objc public var inputBlock: FWPopupInputBlock?
    
    
    private var actionItemArray: [FWPopupItem] = []
    
    private var titleLabel: UILabel?
    private var detailLabel: UILabel?
    private var inputTF: UITextField?
    private var customView: UIView?
    
    private var commponenetCount: Int = 0
    
    
    /// 类初始化方法1：单个按钮的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - confirmBlock: 确定按钮回调
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, confirmBlock: FWPopupItemClickedBlock? = nil) -> FWAlertView {
        
        let items = [FWPopupItem(title: FWAlertViewProperty().defaultTextOK, itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: confirmBlock)]
        return self.alert(title: title, detail: detail, inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: nil, items: items, vProperty: nil)
    }
    
    /// 类初始化方法2：两个按钮的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - confirmBlock: 确定按钮回调
    ///   - cancelBlock: 取消按钮回调
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, confirmBlock: FWPopupItemClickedBlock? = nil, cancelBlock: FWPopupItemClickedBlock? = nil) -> FWAlertView {
        
        let property = FWAlertViewProperty()
        let items = [FWPopupItem(title: property.defaultTextCancel, itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: cancelBlock),
                     FWPopupItem(title: property.defaultTextConfirm, itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: confirmBlock)]
        return self.alert(title: title, detail: detail, inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: nil, items: items, vProperty: nil)
    }
    
    /// 类初始化方法3：可带输入框的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    /// - Returns: self
    @objc open class func alert(title: String, detail: String, inputPlaceholder: String?, keyboardType: UIKeyboardType, isSecureTextEntry: Bool, items: [FWPopupItem]) -> FWAlertView {
        
        return self.alert(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, isSecureTextEntry: isSecureTextEntry, customView: nil, items: items, vProperty: nil)
    }
    
    /// 类初始化方法4：可带输入框、自定义视图的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    ///   - customView: 自定义UI
    /// - Returns: self
    @objc open class func alert(title: String?, detail: String?, inputPlaceholder: String?, keyboardType: UIKeyboardType, isSecureTextEntry: Bool, customView: UIView?, items: [FWPopupItem]) -> FWAlertView {
        
        return self.alert(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, isSecureTextEntry: isSecureTextEntry, customView: customView, items: items, vProperty: nil)
    }
    
    /// 类初始化方法5：可带输入框、自定义视图的弹窗，可设置Alert相关属性
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    ///   - customView: 自定义UI
    ///   - vProperty: FWAlertView的相关属性
    /// - Returns: self
    @objc open class func alert(title: String?, detail: String?, inputPlaceholder: String?, keyboardType: UIKeyboardType, isSecureTextEntry: Bool, customView: UIView?, items: [FWPopupItem], vProperty: FWAlertViewProperty?) -> FWAlertView {
        
        let alertView = FWAlertView()
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, isSecureTextEntry: isSecureTextEntry, customView: customView, items: items, vProperty: vProperty)
        return alertView
    }
    
    open override func showKeyboard() {
        self.inputTF?.becomeFirstResponder()
    }
    
    open override func hideKeyboard() {
        self.inputTF?.resignFirstResponder()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.vProperty = FWAlertViewProperty()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
}


extension FWAlertView {
    
    private func setupUI(title: String?, detail: String?, inputPlaceholder: String?, keyboardType: UIKeyboardType, isSecureTextEntry: Bool, customView: UIView?, items: [FWPopupItem], vProperty: FWAlertViewProperty?) {
        
        if items.count == 0 {
            return
        }
        
        if vProperty != nil {
            self.vProperty = vProperty!
        }
        
        let property = self.vProperty as! FWAlertViewProperty
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.vProperty.cornerRadius
        
        self.frame.origin.x = (UIScreen.main.bounds.width - property.alertViewWidth) / 2
        self.frame.size.width = CGFloat(property.alertViewWidth)
        
        self.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(CGFloat(property.alertViewWidth))
        }
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        self.actionItemArray = items
        self.withKeyboard = (inputPlaceholder != nil)
        
        property.popupCustomAlignment = .center
        property.popupAnimationType = .scale3D
        
        self.commponenetCount = 0
        if title != nil && !title!.isEmpty {
            self.commponenetCount = self.commponenetCount + 1
        }
        if detail != nil && !detail!.isEmpty {
            self.commponenetCount = self.commponenetCount + 1
        }
        if inputPlaceholder != nil {
            self.commponenetCount = self.commponenetCount + 1
        }
        if customView != nil {
            self.commponenetCount = self.commponenetCount + 1
        }
        
        let singleCommponenetMargin = property.commponentMargin*3
        
        var lastConstraintItem = self.snp.top
        var lastTopBottomMargin: CGFloat = 0.0
        
        if title != nil && !title!.isEmpty {
            self.titleLabel = UILabel()
            self.addSubview(self.titleLabel!)
            self.titleLabel?.snp.makeConstraints({ (make) in
                var tmpOffset:CGFloat = 0.0
                if self.commponenetCount == 1 {
                    tmpOffset = singleCommponenetMargin
                } else if self.commponenetCount == 2 && (detail != nil && !detail!.isEmpty) {
                    tmpOffset = property.topBottomMargin + property.commponentMargin
                } else {
                    tmpOffset = property.topBottomMargin
                }
                make.top.equalToSuperview().offset(tmpOffset)
                make.left.equalToSuperview().offset(self.vProperty.letfRigthMargin)
                make.right.equalToSuperview().offset(-self.vProperty.letfRigthMargin)
            })
            self.titleLabel?.text = title
            self.titleLabel?.textColor = self.vProperty.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = (self.vProperty.titleFont != nil) ? self.vProperty.titleFont! : UIFont.systemFont(ofSize: self.vProperty.titleFontSize)
            self.titleLabel?.numberOfLines = 5
            self.titleLabel?.backgroundColor = UIColor.clear
            
            lastTopBottomMargin = property.topBottomMargin
            lastConstraintItem = self.titleLabel!.snp.bottom
        }
        
        if detail != nil && !detail!.isEmpty {
            self.detailLabel = UILabel()
            self.addSubview(self.detailLabel!)
            self.detailLabel?.snp.makeConstraints({ (make) in
                make.top.equalTo(lastConstraintItem).offset((self.commponenetCount != 1) ? (lastTopBottomMargin+property.commponentMargin) : singleCommponenetMargin)
                make.left.equalToSuperview().offset(self.vProperty.letfRigthMargin)
                make.right.equalToSuperview().offset(-self.vProperty.letfRigthMargin)
                make.height.lessThanOrEqualTo(self.superview!.frame.size.height*property.popupViewMaxHeightRate-100)
            })
            self.detailLabel?.text = detail
            self.detailLabel?.textColor = property.detailColor
            self.detailLabel?.textAlignment = .center
            self.detailLabel?.font = (property.detailFont != nil) ? property.detailFont! : UIFont.systemFont(ofSize: property.detailFontSize)
            self.detailLabel?.numberOfLines = 0
            self.detailLabel?.backgroundColor = UIColor.clear
            
            lastTopBottomMargin = 0.0
            lastConstraintItem = self.detailLabel!.snp.bottom
        }
        
        if inputPlaceholder != nil {
            self.inputTF = UITextField()
            self.addSubview(self.inputTF!)
            self.inputTF?.snp.makeConstraints({ (make) in
                make.top.equalTo(lastConstraintItem).offset((self.commponenetCount != 1) ? (lastTopBottomMargin+property.commponentMargin) : singleCommponenetMargin)
                make.left.equalToSuperview().offset(self.vProperty.letfRigthMargin)
                make.right.equalToSuperview().offset(-self.vProperty.letfRigthMargin)
                make.height.equalTo(40)
            })
            self.inputTF?.attributedPlaceholder = NSAttributedString(string: inputPlaceholder!, attributes: [NSAttributedString.Key.foregroundColor : property.inputPlaceholderColor])
            self.inputTF?.textColor = property.inputTextColor
            self.inputTF?.textAlignment = .center
            self.inputTF?.clearButtonMode = .whileEditing
            self.inputTF?.leftViewMode = .always
            self.inputTF?.layer.borderColor = self.vProperty.splitColor.cgColor
            self.inputTF?.layer.borderWidth = self.vProperty.splitWidth
            self.inputTF?.layer.cornerRadius = self.vProperty.cornerRadius
            self.inputTF?.keyboardType = keyboardType
            self.inputTF?.isSecureTextEntry = isSecureTextEntry
            
            lastTopBottomMargin = 0.0
            lastConstraintItem = self.inputTF!.snp.bottom
        }
        
        if customView != nil {
            self.customView = customView
            self.addSubview(self.customView!)
            self.customView?.snp.makeConstraints({ (make) in
                make.top.equalTo(lastConstraintItem).offset((self.commponenetCount != 1) ? (lastTopBottomMargin+property.commponentMargin) : singleCommponenetMargin)
                make.centerX.equalToSuperview()
                make.size.equalTo(customView!.frame.size)
            })
            
            lastTopBottomMargin = 0.0
            lastConstraintItem = self.customView!.snp.bottom
        }
        
        let btnContrainerView = UIView()
        self.addSubview(btnContrainerView)
        btnContrainerView.backgroundColor = UIColor.clear
        btnContrainerView.snp.makeConstraints { (make) in
            make.top.equalTo(lastConstraintItem).offset((self.commponenetCount != 1) ? (property.topBottomMargin+property.commponentMargin) : singleCommponenetMargin)
            make.left.right.equalToSuperview()
        }
        
        var lastBtn: UIButton!
        var tmpIndex = 0
        
        for popupItem: FWPopupItem in items {
            
            let btn = UIButton(type: .custom)
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btnContrainerView.addSubview(btn)
            btn.tag = tmpIndex
            
            if items.count == 1 {
                btn.snp.makeConstraints { (make) in
                    make.top.left.right.equalTo(btnContrainerView).inset(UIEdgeInsets(top: 0, left: -self.vProperty.splitWidth, bottom: 0, right: -self.vProperty.splitWidth))
                    make.height.equalTo(property.buttonHeight + property.splitWidth)
                }
            } else if items.count == 2 {
                let btnW = (property.alertViewWidth + self.vProperty.splitWidth * 4) / 2
                btn.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview().offset(-property.splitWidth+btnW*CGFloat(tmpIndex))
                    make.width.equalTo(btnW)
                    make.height.equalTo(property.buttonHeight + property.splitWidth)
                }
            } else {
                btn.snp.makeConstraints { (make) in
                    make.left.right.equalTo(btnContrainerView).inset(UIEdgeInsets(top: 0, left: -self.vProperty.splitWidth, bottom: 0, right: -self.vProperty.splitWidth))
                    make.height.equalTo(property.buttonHeight + property.splitWidth)
                    make.width.equalTo(btnContrainerView).offset(property.splitWidth*2)
                    if tmpIndex == 0 {
                        make.top.equalToSuperview()
                        lastBtn = btn
                    } else {
                        make.top.equalTo(lastBtn.snp.bottom).offset(-self.vProperty.splitWidth)
                        lastBtn = btn
                    }
                }
            }
            
            if tmpIndex == items.count-1 {
                lastBtn = btn
            }
            
            // 按钮背景颜色
            if popupItem.itemBackgroundColor != nil {
                btn.backgroundColor = popupItem.itemBackgroundColor
            } else {
                btn.backgroundColor = self.backgroundColor
            }
            // 按钮文字颜色
            if popupItem.itemTitleColor != nil {
                btn.setTitleColor(popupItem.itemTitleColor, for: .normal)
            } else {
                btn.setTitleColor(popupItem.highlight ? self.vProperty.itemHighlightColor : self.vProperty.itemNormalColor, for: .normal)
            }
            
            // 按钮文字大小
            if popupItem.itemTitleFont != nil {
                btn.titleLabel?.font = popupItem.itemTitleFont
            } else {
                btn.titleLabel?.font = (self.vProperty.buttonFont != nil) ? self.vProperty.buttonFont! : UIFont.systemFont(ofSize: self.vProperty.buttonFontSize)
            }
            
            btn.setTitle(popupItem.title, for: .normal)
            btn.layer.borderWidth = self.vProperty.splitWidth
            btn.layer.borderColor = self.vProperty.splitColor.cgColor
            btn.setBackgroundImage(self.getImageWithColor(color: btn.backgroundColor!), for: .normal)
            btn.setBackgroundImage(self.getImageWithColor(color: self.vProperty.itemPressedColor), for: .highlighted)
            
            tmpIndex += 1
        }
        lastBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(btnContrainerView.snp.bottom)
        }
        
        self.snp.makeConstraints { (make) in
            make.bottom.equalTo(btnContrainerView.snp.bottom)
        }
    }
}

extension FWAlertView {
    
    @objc private func btnAction(_ sender: Any) {
        
        let btn = sender as! UIButton
        let item = self.actionItemArray[btn.tag]
        if item.disabled {
            return
        }
        
        if self.withKeyboard && item.isCancel == false && item.canAutoHide {
            if self.inputTF!.text != nil && !self.inputTF!.text!.isEmpty {
                self.hide()
            }
        } else if item.canAutoHide {
            self.hide()
        }
        
        if self.inputBlock != nil && item.isCancel == false {
            self.inputBlock!(self.inputTF!.text!)
        } else {
            if item.itemClickedBlock != nil {
                item.itemClickedBlock!(self, btn.tag, item.title)
            }
        }
    }
}


/// FWAlertView的相关属性，请注意其父类中还有很多公共属性
open class FWAlertViewProperty: FWPopupViewProperty {
    
    // FWAlertView宽度
    @objc open var alertViewWidth: CGFloat = 275.0
    // 为保持FWAlertView美观，设置FWAlertView的最小高度
    @objc open var alertViewMinHeight: CGFloat = 150
    
    // 描述字体大小
    @objc open var detailFontSize: CGFloat = 14.0
    // 描述字体，设置该值后detailFontSize无效
    @objc open var detailFont: UIFont?
    // 描述文字颜色
    @objc open var detailColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    
    // 输入框提示文字颜色
    @objc open var inputPlaceholderColor: UIColor = UIColor.lightGray
    // 输入框文字颜色
    @objc open var inputTextColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    
    // 确定按钮默认名称
    @objc open var defaultTextOK = "知道了"
    // 取消按钮默认名称
    @objc open var defaultTextCancel = "取消"
    // 确定按钮默认名称
    @objc open var defaultTextConfirm = "确定"
    
    
    public override func reSetParams() {
        super.reSetParams()
        
    }
}

