//
//  FWPopupView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/19.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

/// 弹窗类型
///
/// - alert: Alert类型，表示弹窗在屏幕中间
/// - sheet: Sheet类型，表示弹窗在屏幕底部
/// - custom: 自定义类型，待拓展
@objc public enum FWPopupType: Int {
    case alert
    case sheet
    case custom
}

/// 显示、隐藏回调
public typealias FWPopupBlock = (_ popupView: FWPopupView) -> Void
/// 显示、隐藏完成回调，某些场景下可能会用到 isShow ==》true: 显示 false：隐藏
public typealias FWPopupCompletionBlock = (_ popupView: FWPopupView, _ isShow: Bool) -> Void
/// 普通无参数回调
public typealias FWPopupVoidBlock = () -> Void

let FWPopupViewHideAllNotification = "FWPopupViewHideAllNotification"


open class FWPopupView: UIView {
    
    /// 1、当外部没有传入该参数时，默认为UIWindow的根控制器的视图，即表示弹窗放在FWPopupWindow上，此时若FWPopupWindow.sharedInstance.touchWildToHide = true表示弹窗视图外部可点击；2、当外部传入该参数时，该视图为传入的UIView，即表示弹窗放在传入的UIView上；
    @objc public var attachedView = FWPopupWindow.sharedInstance.attachView()
    
    @objc public var visible: Bool {
        get {
            if self.attachedView != nil {
                return !(self.attachedView?.fwBackgroundView.isHidden)!
            }
            return false
        }
    }
    
    @objc public var popupType: FWPopupType = .alert {
        willSet {
            switch newValue {
            case .alert:
                self.showAnimation = self.alertShowAnimation()
                self.hideAnimation = self.alertHideAnimation()
                break
            case .sheet:
                self.showAnimation = self.sheetShowAnimation()
                self.hideAnimation = self.sheetHideAnimation()
                break
            case .custom:
                self.showAnimation = self.customShowAnimation()
                self.hideAnimation = self.customHideAnimation()
                break
            }
        }
    }
    
    @objc public var animationDuration: TimeInterval = 0.2 {
        willSet {
            self.attachedView?.fwAnimationDuration = newValue
        }
    }
    
    @objc public var withKeyboard = false
    
    
    private var popupCompletionBlock: FWPopupCompletionBlock?
    
    private var showAnimation: FWPopupBlock?
    
    private var hideAnimation: FWPopupBlock?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        FWPopupWindow.sharedInstance.backgroundColor = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyHideAll(notification:)), name: NSNotification.Name(rawValue: FWPopupViewHideAllNotification), object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc open func showKeyboard() {
        
    }
    
    @objc open func hideKeyboard() {
        
    }
}

// MARK: - 显示、隐藏
extension FWPopupView {
    
    @objc open func show() {
        
        self.show(completionBlock: nil)
    }
    
    @objc open func show(completionBlock: FWPopupCompletionBlock? = nil) {
        
        if completionBlock != nil {
            self.popupCompletionBlock = completionBlock
        }
        
        if self.attachedView == nil {
            self.attachedView = FWPopupWindow.sharedInstance.attachView()
        }
        self.attachedView?.showFwBackground()
        
        let showA = self.showAnimation
        showA!(self)
        
        if self.withKeyboard {
            self.showKeyboard()
        }
    }
    
    @objc open func hide() {
        
        self.hide(completionBlock: nil)
    }
    
    @objc open func hide(completionBlock: FWPopupCompletionBlock? = nil) {
        
        if completionBlock != nil {
            self.popupCompletionBlock = completionBlock
        }
        
        if self.attachedView == nil {
            self.attachedView = FWPopupWindow.sharedInstance.attachView()
        }
        self.attachedView?.hideFwBackground()
        
        if self.withKeyboard {
            self.hideKeyboard()
        }
        
        let hideAnimation = self.hideAnimation
        if hideAnimation != nil {
            hideAnimation!(self)
        }
    }
    
    @objc open class func hideAll() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FWPopupViewHideAllNotification), object: FWPopupView.self)
    }
    
    @objc open func notifyHideAll(notification: Notification) {
        
        if self.isKind(of: notification.object as! AnyClass) {
            self.hide()
        }
    }
    
    /// 弹窗是否隐藏
    ///
    /// - Returns: 是否隐藏
    @objc open class func isPopupViewHiden() -> Bool {
        return FWPopupWindow.sharedInstance.isHidden
    }
}

// MARK: - 动画事件
extension FWPopupView {
    
    private func alertShowAnimation() -> FWPopupBlock {
        
        let popupBlock = { [weak self] (popupView: FWPopupView) in
            
            guard let strongSelf = self else {
                return
            }
            if strongSelf.superview == nil {
                strongSelf.attachedView?.fwBackgroundView.addSubview(strongSelf)
                strongSelf.center = (strongSelf.attachedView?.center)!
                if strongSelf.withKeyboard {
                    strongSelf.frame.origin.y -= 216/2
                }
                strongSelf.layoutIfNeeded()
            }
            strongSelf.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
            strongSelf.alpha = 0.0
            
            UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                
                strongSelf.layer.transform = CATransform3DIdentity
                strongSelf.alpha = 1.0
                
            }, completion: { (finished) in
                
                if strongSelf.popupCompletionBlock != nil {
                    strongSelf.popupCompletionBlock!(strongSelf, true)
                }
                
            })
        }
        
        return popupBlock
    }
    
    private func alertHideAnimation() -> FWPopupBlock {
        
        let popupBlock:FWPopupBlock = { [weak self] popupView in
            
            guard let strongSelf = self else {
                return
            }
            UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                
                strongSelf.alpha = 0.0
                
            }, completion: { (finished) in
                
                if finished {
                    strongSelf.removeFromSuperview()
                }
                if strongSelf.popupCompletionBlock != nil {
                    strongSelf.popupCompletionBlock!(strongSelf, false)
                }
                
            })
        }
        
        return popupBlock
    }
    
    private func sheetShowAnimation() -> FWPopupBlock {
        
        let popupBlock:FWPopupBlock = { [weak self] popupView in
            
            guard let strongSelf = self else {
                return
            }
            if strongSelf.superview == nil {
                strongSelf.attachedView?.fwBackgroundView.addSubview(strongSelf)
                strongSelf.frame.origin.y =  UIScreen.main.bounds.height
            }
            
            UIView.animate(withDuration: strongSelf.animationDuration / 2, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                
                strongSelf.frame.origin.y =  UIScreen.main.bounds.height - strongSelf.frame.height
                strongSelf.layoutIfNeeded()
                strongSelf.superview?.layoutIfNeeded()
                
            }, completion: { (finished) in
                
                if strongSelf.popupCompletionBlock != nil {
                    strongSelf.popupCompletionBlock!(strongSelf, true)
                }
                
            })
        }
        
        return popupBlock
    }
    
    private func sheetHideAnimation() -> FWPopupBlock {
        
        let popupBlock:FWPopupBlock = { [weak self] popupView in
            
            guard let strongSelf = self else {
                return
            }
            UIView.animate(withDuration: strongSelf.animationDuration / 2, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                
                strongSelf.frame.origin.y =  UIScreen.main.bounds.height
                strongSelf.superview?.layoutIfNeeded()
                
            }, completion: { (finished) in
                
                if finished {
                    strongSelf.removeFromSuperview()
                }
                if strongSelf.popupCompletionBlock != nil {
                    strongSelf.popupCompletionBlock!(strongSelf, false)
                }
                
            })
        }
        
        return popupBlock
    }
    
    private func customShowAnimation() -> FWPopupBlock {
        
        let popupBlock = { [weak self] (popupView: FWPopupView) in
            
            guard let strongSelf = self else {
                return
            }
            if strongSelf.superview == nil {
                strongSelf.attachedView?.fwBackgroundView.addSubview(strongSelf)
                strongSelf.center = (strongSelf.attachedView?.center)!
                if strongSelf.withKeyboard {
                    strongSelf.frame.origin.y -= 216/2
                }
                strongSelf.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                
                strongSelf.superview?.layoutIfNeeded()
                
            }, completion: { (finished) in
                
                if strongSelf.popupCompletionBlock != nil {
                    strongSelf.popupCompletionBlock!(strongSelf, true)
                }
                
            })
        }
        
        return popupBlock
    }
    
    private func customHideAnimation() -> FWPopupBlock {
        
        let popupBlock:FWPopupBlock = { [weak self] popupView in
            
            guard let strongSelf = self else {
                return
            }
            UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                
                strongSelf.superview?.layoutIfNeeded()
                
            }, completion: { (finished) in
                
                if finished {
                    strongSelf.removeFromSuperview()
                }
                if strongSelf.popupCompletionBlock != nil {
                    strongSelf.popupCompletionBlock!(strongSelf, false)
                }
                
            })
        }
        
        return popupBlock
    }
    
    /// 将颜色转换为图片
    ///
    /// - Parameter color: 颜色
    /// - Returns: UIImage
    public func getImageWithColor(color: UIColor) -> UIImage {
        
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


// MARK: - 弹窗的的相关配置属性
open class FWPopupViewProperty: NSObject {
    
    // 单个点击按钮的高度
    @objc public var buttonHeight: CGFloat        = 48.0
    // 圆角值
    @objc public var cornerRadius: CGFloat        = 5.0
    
    // 标题字体大小
    @objc public var titleFontSize: CGFloat       = 18.0
    // 点击按钮字体大小
    @objc public var buttonFontSize: CGFloat      = 17.0
    
    // 弹窗的背景色
    @objc public var vbackgroundColor: UIColor    = UIColor.white
    // 标题文字颜色
    @objc public var titleColor: UIColor          = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 边框、分割线颜色
    @objc public var splitColor: UIColor          = kPV_RGBA(r: 231, g: 231, b: 231, a: 1)
    // 边框宽度
    @objc public var splitWidth: CGFloat          = (1/UIScreen.main.scale)
    
    // 普通按钮颜色
    @objc public var itemNormalColor: UIColor     = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    // 高亮按钮颜色
    @objc public var itemHighlightColor: UIColor  = kPV_RGBA(r: 254, g: 226, b: 4, a: 1)
    // 选中按钮颜色
    @objc public var itemPressedColor: UIColor    = kPV_RGBA(r: 231, g: 231, b: 231, a: 1)
    
    // 上下间距
    @objc public var topBottomMargin:CGFloat      = 10
    // 左右间距
    @objc public var letfRigthMargin:CGFloat      = 10
    
    public override init() {
        super.init()
    }
}
