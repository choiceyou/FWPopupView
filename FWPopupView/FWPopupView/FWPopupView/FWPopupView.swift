//
//  FWPopupView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/19.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

/// 弹窗类型
///
/// - alert: Alert类型
/// - sheet: Sheet类型
/// - custom: 自定义类型
@objc public enum FWPopupType: Int {
    case alert
    case sheet
    case custom
}

public typealias FWPopupBlock = (_ popupView: FWPopupView) -> Void
public typealias FWPopupCompletionBlock = (_ popupView: FWPopupView, _ isCompletion: Bool) -> Void

let FWPopupViewHideAllNotification = "FWPopupViewHideAllNotification"


@objc open class FWPopupView: UIView {
    
    /// 1、当外部没有传入该参数时，默认为UIWindow的根控制器的视图，即表示弹窗
    public var attachedView = FWPopupWindow.sharedInstance.attachView()
    
    public var visible: Bool {
        get {
            if self.attachedView != nil {
                return !(self.attachedView?.fwBackgroundView.isHidden)!
            }
            return false
        }
    }
    
    var popupType: FWPopupType = .alert {
        willSet {
            switch newValue {
            case .alert:
                self.showAnimation = self.alertShowAnimation()
                self.hideAnimation = self.alertHideAnimation()
                break
            case .sheet:
                //                self.showAnimation = self.sheetShowAnimation()
                //                self.hideAnimation = self.sheetHideAnimation()
                break
            case .custom:
                //                self.showAnimation = self.customShowAnimation()
                //                self.hideAnimation = self.customHideAnimation()
                break
            }
        }
    }
    
    var animationDuration: TimeInterval = 0.3 {
        willSet {
            self.attachedView?.fwAnimationDuration = newValue
        }
    }
    
    var withKeyboard = false
    
    var showCompletionBlock: FWPopupCompletionBlock?
    
    var hideCompletionBlock: FWPopupCompletionBlock?
    
    var showAnimation: FWPopupBlock?
    
    var hideAnimation: FWPopupBlock?
    
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
    
    open func showKeyboard() {
        
    }
    
    open func hideKeyboard() {
        
    }
}

extension FWPopupView {
    
    open func show() {
        
        self.show { (self, isFinished) in
            
        }
    }
    
    func show(completionBlock:@escaping FWPopupCompletionBlock) {
        
        self.showCompletionBlock = completionBlock
        
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
    
    open func hide() {
        self.hide { (self, isFinished) in
            
        }
    }
    
    func hide(completionBlock:@escaping FWPopupCompletionBlock) {
        
        self.hideCompletionBlock = completionBlock
        
        if self.attachedView == nil {
            self.attachedView = FWPopupWindow.sharedInstance.attachView()
        }
        self.attachedView?.hideFwBackground()
        
        if self.withKeyboard {
            self.hideKeyboard()
        }
        
        let hideAnimation = self.hideAnimation
        hideAnimation!(self)
    }
    
    open class func hideAll() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FWPopupViewHideAllNotification), object: FWPopupView.self)
    }
    
    @objc func notifyHideAll(notification: Notification) {
        
        if self.isKind(of: notification.object as! AnyClass) {
            self.hide()
        }
    }
}

extension FWPopupView {
    
    func alertShowAnimation() -> FWPopupBlock {
        
        let popupBlock = { [weak self] (popupView: FWPopupView) in
            if self?.superview == nil {
                self?.attachedView?.fwBackgroundView.addSubview(self!)
                self?.center = (self?.attachedView?.center)!
                if (self?.withKeyboard)! {
                    self?.frame.origin.y -= 216/2
                }
                self?.layoutIfNeeded()
            }
            self?.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
            self?.alpha = 0.0
            
            UIView.animate(withDuration: (self?.animationDuration)!, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                
                self?.layer.transform = CATransform3DIdentity
                self?.alpha = 1.0
                
            }, completion: { (finished) in
                
                if self?.showCompletionBlock != nil {
                    self?.showCompletionBlock!(self!, finished)
                }
                
            })
        }
        
        return popupBlock
    }
    
    func alertHideAnimation() -> FWPopupBlock {
        
        let popupBlock:FWPopupBlock = { [weak self] popupView in
            
            UIView.animate(withDuration: (self?.animationDuration)!, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                
                self?.alpha = 0.0
                
            }, completion: { (finished) in
                
                if finished {
                    self?.removeFromSuperview()
                }
                if self?.hideCompletionBlock != nil {
                    self?.hideCompletionBlock!(self!, finished)
                }
                
            })
        }
        
        return popupBlock
    }
    
    func sheetShowAnimation() -> FWPopupBlock {
        
        let popupBlock:FWPopupBlock = { [weak self] popupView in
            if self?.superview == nil {
                self?.attachedView?.fwBackgroundView.addSubview(self!)
                self?.center = (self?.attachedView?.center)!
                self?.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: (self?.animationDuration)!, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                
                self?.superview?.layoutIfNeeded()
                
            }, completion: { (finished) in
                
                if self?.showCompletionBlock != nil {
                    self?.showCompletionBlock!(self!, finished)
                }
                
            })
        }
        
        return popupBlock
    }
    
    //    func sheetHideAnimation() -> FWPopupBlock {
    //
    //    }
    //
    //    func customShowAnimation() -> FWPopupBlock {
    //
    //    }
    //
    //    func customHideAnimation() -> FWPopupBlock {
    //
    //    }
}

