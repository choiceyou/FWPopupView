//
//  FWAlertView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/21.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

public typealias FWPopupInputHandler = (_ text: String) -> Void

@objc open class FWAlertView: FWPopupView {
    
    // FWAlertView宽度
    public var vwidth: CGFloat              = 275.0
    // 单个点击按钮的高度
    public var buttonHeight: CGFloat        = 48.0
    // FWAlertView的圆角值
    public var cornerRadius: CGFloat        = 5.0
    
    // 标题字体大小
    public var titleFontSize: CGFloat       = 18.0
    // 描述字体大小
    public var detailFontSize: CGFloat      = 14.0
    // 点击按钮字体大小
    public var buttonFontSize: CGFloat      = 17.0
    
    // FWAlertView背景色
    public var vbackgroundColor: UIColor    = UIColor.white
    // 标题文字颜色
    public var titleColor: UIColor          = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 描述文字颜色
    public var detailColor: UIColor         = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 边框、分割线颜色
    public var splitColor: UIColor          = kPV_RGBA(r: 231, g: 231, b: 241, a: 1)
    // 边框宽度
    public var splitWidth: CGFloat          = (1/UIScreen.main.scale)
    
    // 普通按钮颜色
    public var itemNormalColor: UIColor     = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 高亮按钮颜色
    public var itemHighlightColor: UIColor  = kPV_RGBA(r: 254, g: 226, b: 4, a: 1)
    // 选中按钮颜色
    public var itemPressedColor: UIColor    = kPV_RGBA(r: 231, g: 231, b: 231, a: 1)
    
    // 确定按钮默认名称
    public var defaultTextOK                = "知道了"
    // 取消按钮默认名称
    public var defaultTextCancel            = "取消"
    // 确定按钮默认名称
    public var defaultTextConfirm           = "确定"
    
    // 上下间距
    public var topBottomMargin:CGFloat      = 10
    // 左右间距
    public var letfRigthMargin:CGFloat      = 10
    // 为保持FWAlertView美观，设置FWAlertView的最小高度
    public var alertViewMinHeight: CGFloat  = 150
    
    // 输入框回调
    public var inputHandler: FWPopupInputHandler?
    
    
    private var actionItemArray: [FWPopupItem] = []
    private var commponenetArray: [UIView] = []
    
    private var titleLabel: UILabel?
    
    private var detailLabel: UILabel?
    
    private var inputTF: UITextField?
    
    private var customView: UIView?
    
    
    open class func alert(title: String, detail: String, confirmBlock:@escaping FWPopupItemHandler) -> FWAlertView {
        
        let alertView = FWAlertView()
        let items = [FWPopupItem(title: alertView.defaultTextOK, itemType: .normal, isCancel: false, handler: confirmBlock)]
        
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: nil, customView: nil, items: items)
        return alertView
    }
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - confirmBlock: 确定按钮回调
    ///   - cancelBlock: 取消按钮回调
    /// - Returns: self
    open class func alert(title: String, detail: String, confirmBlock:@escaping FWPopupItemHandler, cancelBlock:@escaping FWPopupItemHandler) -> FWAlertView {
        
        let alertView = FWAlertView()
        let items = [FWPopupItem(title: alertView.defaultTextCancel, itemType: .normal, isCancel: true, handler: cancelBlock),
                     FWPopupItem(title: alertView.defaultTextConfirm, itemType: .normal, isCancel: false, handler: confirmBlock)]
        
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: nil, customView: nil, items: items)
        return alertView
    }
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    /// - Returns: self
    open class func alert(title: String, detail: String, inputPlaceholder: String?, items: [FWPopupItem]) -> FWAlertView {
        
        let alertView = FWAlertView()
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: inputPlaceholder, customView: nil, items: items)
        return alertView
    }
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - inputPlaceholder: 输入框提示文字。注意：没有输入框时该参数必须要为nil，反之为空或者字符串即可
    ///   - items: 点击按钮项
    ///   - customView: 自定义UI
    /// - Returns: self
    open class func alert(title: String, detail: String, inputPlaceholder: String?, customView: UIView?, items: [FWPopupItem]) -> FWAlertView {
        
        let alertView = FWAlertView()
        alertView.setupUI(title: title, detail: detail, inputPlaceholder: inputPlaceholder, customView: customView, items: items)
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
    
    private func setupUI(title: String, detail: String, inputPlaceholder: String?, customView: UIView?, items: [FWPopupItem]) {
        
        if items.count == 0 {
            return
        }
        
        self.backgroundColor = vbackgroundColor
        self.clipsToBounds = true
        
        self.popupType = .alert
        self.animationDuration = 0.3
        
        self.actionItemArray = items
        
        self.withKeyboard = (inputPlaceholder != nil)
        
        self.layer.cornerRadius = self.cornerRadius
        self.clipsToBounds = true
        
        self.frame.origin.x = (UIScreen.main.bounds.width - self.vwidth) / 2
        self.frame.origin.y = 100
        self.frame.size.width = CGFloat(self.vwidth)
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        var currentMaxY:CGFloat = topBottomMargin
        
        if !title.isEmpty {
            self.titleLabel = UILabel(frame: CGRect(x: letfRigthMargin, y: currentMaxY, width: self.frame.width - letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.text = title
            self.titleLabel?.textColor = self.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.titleFontSize)
            self.titleLabel?.numberOfLines = 5
            self.titleLabel?.backgroundColor = UIColor.clear
            
            self.titleLabel?.sizeToFit()
            
            self.titleLabel?.frame = CGRect(x: letfRigthMargin, y: currentMaxY, width: self.frame.width - letfRigthMargin * 2, height: self.titleLabel!.frame.height)
            
            currentMaxY = self.titleLabel!.frame.maxY
            
            self.commponenetArray.append(self.titleLabel!)
        }
        
        if !detail.isEmpty {
            currentMaxY += topBottomMargin
            
            self.detailLabel = UILabel(frame: CGRect(x: letfRigthMargin, y: currentMaxY, width: self.frame.width - letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.detailLabel!)
            self.detailLabel?.text = detail
            self.detailLabel?.textColor = self.detailColor
            self.detailLabel?.textAlignment = .center
            self.detailLabel?.font = UIFont.boldSystemFont(ofSize: self.detailFontSize)
            self.detailLabel?.numberOfLines = 5
            self.detailLabel?.backgroundColor = UIColor.clear
            
            self.detailLabel?.sizeToFit()
            
            self.detailLabel?.frame = CGRect(x: letfRigthMargin, y: currentMaxY, width: self.frame.width - letfRigthMargin * 2, height: self.detailLabel!.frame.height)
            
            currentMaxY = self.detailLabel!.frame.maxY
            
            self.commponenetArray.append(self.detailLabel!)
        }
        
        if inputPlaceholder != nil {
            currentMaxY += topBottomMargin
                
            self.inputTF = UITextField(frame: CGRect(x: letfRigthMargin, y: currentMaxY, width: self.frame.width - letfRigthMargin * 2, height: 40))
            self.addSubview(self.inputTF!)
            self.inputTF?.placeholder = inputPlaceholder
            self.inputTF?.textAlignment = .center
            self.inputTF?.clearButtonMode = .whileEditing
            self.inputTF?.leftViewMode = .always
            self.inputTF?.layer.borderColor = self.splitColor.cgColor
            self.inputTF?.layer.borderWidth = splitWidth
            self.inputTF?.layer.cornerRadius = self.cornerRadius
            
            currentMaxY = self.inputTF!.frame.maxY
            
            self.commponenetArray.append(self.inputTF!)
        }
        
        if customView != nil {
            currentMaxY += topBottomMargin
            
            self.customView = customView
            self.customView?.frame = CGRect(x: (self.frame.width - self.customView!.frame.width) / 2, y: currentMaxY, width: self.customView!.frame.width, height: self.customView!.frame.height)
            
            self.addSubview(self.customView!)
            
            currentMaxY = self.customView!.frame.maxY
            
            self.commponenetArray.append(self.customView!)
        }
        
        currentMaxY += topBottomMargin
        
        // 调整
        if currentMaxY < self.alertViewMinHeight - self.buttonHeight {
            currentMaxY = self.alertViewMinHeight - self.buttonHeight
            
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
        
        let btnContrainerView = UIView(frame: CGRect(x: 0, y: currentMaxY, width: self.frame.width, height: self.buttonHeight))
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
                btn.frame = CGRect(x: -splitWidth, y: 0, width: btnContrainerView.frame.width + splitWidth * 2, height: self.buttonHeight + splitWidth)
            } else if items.count == 2 {
                let btnW = (btnContrainerView.frame.width + splitWidth * 4) / 2
                btn.frame = CGRect(x: -splitWidth + btnW * CGFloat(tmpIndex), y: 0, width: btnW, height: self.buttonHeight + splitWidth)
            } else {
                btn.frame = CGRect(x: -splitWidth, y: self.buttonHeight * CGFloat(tmpIndex), width: btnContrainerView.frame.width + splitWidth * 2, height: self.buttonHeight + splitWidth)
                
                if tmpIndex > 0 {
                    currentMaxY += btn.frame.height
                    if tmpIndex == items.count - 1 {
                        btnContrainerView.frame.size.height = btn.frame.maxY
                    }
                }
            }
            
            btn.backgroundColor = self.backgroundColor
            btn.setTitle(popupItem.title, for: .normal)
            btn.setTitleColor(popupItem.highlight ? self.itemHighlightColor : self.itemNormalColor, for: .normal)
            btn.layer.borderWidth = splitWidth
            btn.layer.borderColor = self.splitColor.cgColor
            btn.setBackgroundImage(self.getImageWithColor(color: btn.backgroundColor!), for: .normal)
            btn.setBackgroundImage(self.getImageWithColor(color: self.itemPressedColor), for: .highlighted)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.buttonFontSize)
            
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
    
    /// 将颜色转换为图片
    ///
    /// - Parameter color: 颜色
    /// - Returns: UIImage
    private func getImageWithColor(color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
