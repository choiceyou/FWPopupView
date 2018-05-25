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
    @objc open class func alert(title: String, detail: String, confirmBlock: FWPopupItemClickedBlock? = nil) -> FWAlertView {
        
        let items = [FWPopupItem(title: FWAlertViewProperty().defaultTextOK, itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: confirmBlock)]
        return self.alert(title: title, detail: detail, inputPlaceholder: nil, keyboardType: .default, customView: nil, items: items, vProperty: nil)
    }
    
    /// 两个按钮的弹窗
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
        return self.alert(title: title, detail: detail, inputPlaceholder: nil, keyboardType: .default, customView: nil, items: items, vProperty: nil)
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
        
        return self.alert(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, customView: nil, items: items, vProperty: nil)
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
        
        return self.alert(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, customView: customView, items: items, vProperty: nil)
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
    @objc open class func alert(title: String?, detail: String?, inputPlaceholder: String?, keyboardType: UIKeyboardType, customView: UIView?, items: [FWPopupItem], vProperty: FWAlertViewProperty?) -> FWAlertView {
        
        let alertView = FWAlertView()
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: inputPlaceholder, keyboardType: keyboardType, customView: customView, items: items, vProperty: vProperty)
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
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
    }
}


extension FWAlertView {
    
    private func setupUI(title: String?, detail: String?, inputPlaceholder: String?, keyboardType: UIKeyboardType, customView: UIView?, items: [FWPopupItem], vProperty: FWAlertViewProperty?) {
        
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
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        self.actionItemArray = items
        self.withKeyboard = (inputPlaceholder != nil)
        
        property.popupCustomAlignment = .center
        property.popupAnimationType = .scale3D
        
        var currentMaxY: CGFloat = property.topBottomMargin
        
        if title != nil && !title!.isEmpty {
            self.titleLabel = UILabel(frame: CGRect(x: self.vProperty.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.vProperty.letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.text = title
            self.titleLabel?.textColor = self.vProperty.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.vProperty.titleFontSize)
            self.titleLabel?.numberOfLines = 5
            self.titleLabel?.backgroundColor = UIColor.clear
            
            self.titleLabel?.sizeToFit()
            
            self.titleLabel?.frame = CGRect(x: self.vProperty.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.vProperty.letfRigthMargin * 2, height: self.titleLabel!.frame.height)
            
            currentMaxY = self.titleLabel!.frame.maxY
            
            self.commponenetArray.append(self.titleLabel!)
        }
        
        if detail != nil && !detail!.isEmpty {
            currentMaxY += self.vProperty.commponentMargin
            
            self.detailLabel = UILabel(frame: CGRect(x: self.vProperty.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.vProperty.letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.detailLabel!)
            self.detailLabel?.text = detail
            self.detailLabel?.textColor = property.detailColor
            self.detailLabel?.textAlignment = .center
            self.detailLabel?.font = UIFont.boldSystemFont(ofSize: property.detailFontSize)
            self.detailLabel?.numberOfLines = 5
            self.detailLabel?.backgroundColor = UIColor.clear
            
            self.detailLabel?.sizeToFit()
            
            self.detailLabel?.frame = CGRect(x: self.vProperty.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.vProperty.letfRigthMargin * 2, height: self.detailLabel!.frame.height)
            
            currentMaxY = self.detailLabel!.frame.maxY
            
            self.commponenetArray.append(self.detailLabel!)
        }
        
        if inputPlaceholder != nil {
            currentMaxY += self.vProperty.commponentMargin
                
            self.inputTF = UITextField(frame: CGRect(x: self.vProperty.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.vProperty.letfRigthMargin * 2, height: 40))
            self.addSubview(self.inputTF!)
            self.inputTF?.placeholder = inputPlaceholder
            self.inputTF?.textAlignment = .center
            self.inputTF?.clearButtonMode = .whileEditing
            self.inputTF?.leftViewMode = .always
            self.inputTF?.layer.borderColor = self.vProperty.splitColor.cgColor
            self.inputTF?.layer.borderWidth = self.vProperty.splitWidth
            self.inputTF?.layer.cornerRadius = self.vProperty.cornerRadius
            self.inputTF?.keyboardType = keyboardType
            
            currentMaxY = self.inputTF!.frame.maxY
            
            self.commponenetArray.append(self.inputTF!)
        }
        
        if customView != nil {
            currentMaxY += self.vProperty.commponentMargin
            
            self.customView = customView
            self.customView?.frame = CGRect(x: (self.frame.width - self.customView!.frame.width) / 2, y: currentMaxY, width: self.customView!.frame.width, height: self.customView!.frame.height)
            
            self.addSubview(self.customView!)
            
            currentMaxY = self.customView!.frame.maxY
            
            self.commponenetArray.append(self.customView!)
        }
        
        currentMaxY += self.vProperty.topBottomMargin
        
        // 调整
        if currentMaxY < property.alertViewMinHeight - self.vProperty.buttonHeight {
            currentMaxY = property.alertViewMinHeight - self.vProperty.buttonHeight
            
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
        
        let btnContrainerView = UIView(frame: CGRect(x: 0, y: currentMaxY, width: self.frame.width, height: self.vProperty.buttonHeight))
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
                btn.frame = CGRect(x: -self.vProperty.splitWidth, y: 0, width: btnContrainerView.frame.width + self.vProperty.splitWidth * 2, height: self.vProperty.buttonHeight + self.vProperty.splitWidth)
            } else if items.count == 2 {
                let btnW = (btnContrainerView.frame.width + self.vProperty.splitWidth * 4) / 2
                btn.frame = CGRect(x: -self.vProperty.splitWidth + btnW * CGFloat(tmpIndex), y: 0, width: btnW, height: self.vProperty.buttonHeight + self.vProperty.splitWidth)
            } else {
                btn.frame = CGRect(x: -self.vProperty.splitWidth, y: self.vProperty.buttonHeight * CGFloat(tmpIndex), width: btnContrainerView.frame.width + self.vProperty.splitWidth * 2, height: self.vProperty.buttonHeight + self.vProperty.splitWidth)
                
                if tmpIndex > 0 {
                    currentMaxY += btn.frame.height
                    if tmpIndex == items.count - 1 {
                        btnContrainerView.frame.size.height = btn.frame.maxY
                    }
                }
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
            
            btn.setTitle(popupItem.title, for: .normal)
            btn.layer.borderWidth = self.vProperty.splitWidth
            btn.layer.borderColor = self.vProperty.splitColor.cgColor
            btn.setBackgroundImage(self.getImageWithColor(color: btn.backgroundColor!), for: .normal)
            btn.setBackgroundImage(self.getImageWithColor(color: self.vProperty.itemPressedColor), for: .highlighted)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.vProperty.buttonFontSize)
            
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
                item.itemClickedBlock!(self, btn.tag)
            }
        }
    }
}


/// FWAlertView的相关属性，请注意其父类中还有很多公共属性
open class FWAlertViewProperty: FWPopupViewProperty {
    
    // FWAlertView宽度
    @objc open var alertViewWidth: CGFloat      = 275.0
    // 为保持FWAlertView美观，设置FWAlertView的最小高度
    @objc open var alertViewMinHeight: CGFloat  = 150
    
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
    
    
    public override func reSetParams() {
        super.reSetParams()
        
    }
}

