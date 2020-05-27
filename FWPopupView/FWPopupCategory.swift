//
//  FWPopupCategory.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/20.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit
import SnapKit

let fwReferenceCountKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwReferenceCountKey".hashValue)

let fwBackgroundViewKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwBackgroundViewKey".hashValue)
let fwBackgroundViewColorKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwBackgroundViewColorKey".hashValue)
let fwBackgroundAnimatingKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwBackgroundAnimatingKey".hashValue)
let fwAnimationDurationKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwAnimationDurationKey".hashValue)

/// 遮罩层的默认背景色
let kDefaultMaskViewColor = UIColor(white: 0, alpha: 0.5)


extension UIView {
    
    var fwBackgroundAnimating: Bool {
        get {
            let isAnimating = objc_getAssociatedObject(self, fwBackgroundAnimatingKey) as? Bool
            guard isAnimating != nil else {
                return false
            }
            return isAnimating!
        }
        set {
            objc_setAssociatedObject(self, fwBackgroundAnimatingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var fwAnimationDuration: TimeInterval {
        get {
            let duration = objc_getAssociatedObject(self, fwAnimationDurationKey) as? TimeInterval
            guard duration != nil else {
                return 0.0
            }
            return duration!
        }
        set {
            objc_setAssociatedObject(self, fwAnimationDurationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var fwReferenceCount: Int {
        get {
            let count = objc_getAssociatedObject(self, fwReferenceCountKey) as? Int
            guard count != nil else {
                return 0
            }
            return count!
        }
        set {
            objc_setAssociatedObject(self, fwReferenceCountKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 遮罩层颜色
    var fwMaskViewColor: UIColor {
        get {
            let color = objc_getAssociatedObject(self, fwBackgroundViewColorKey) as? UIColor
            guard color != nil else {
                return kDefaultMaskViewColor
            }
            return color!
        }
        set {
            objc_setAssociatedObject(self, fwBackgroundViewColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 遮罩层
    var fwMaskView: UIView {
        var tmpView = objc_getAssociatedObject(self, fwBackgroundViewKey) as? UIView
        if tmpView == nil {
            tmpView = UIView(frame: self.bounds)
            self.addSubview(tmpView!)
            tmpView?.snp.makeConstraints({ (make) in
                make.top.left.bottom.right.equalTo(self)
            })
            
            tmpView?.alpha = 0.0
            tmpView?.layer.zPosition = CGFloat(MAXFLOAT)
        }
        tmpView?.backgroundColor = fwMaskViewColor
        objc_setAssociatedObject(self, fwBackgroundViewKey, tmpView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return tmpView!
    }
    
    /// 显示遮罩层
    func showFwBackground() {
        
        self.fwReferenceCount += 1
        if self.fwReferenceCount > 1 {
            self.fwReferenceCount -= 1
            return
        }
        self.fwMaskView.isHidden = false
        
        if self == FWPopupSWindow.sharedInstance.attachView() {
            FWPopupSWindow.sharedInstance.isHidden = false
            FWPopupSWindow.sharedInstance.makeKeyAndVisible()
        } else if self.isKind(of: UIWindow.self) {
            self.isHidden = false
            let aa = self as! UIWindow
            aa.makeKeyAndVisible()
        } else {
            self.bringSubviewToFront(self.fwMaskView)
        }
        
        UIView.animate(withDuration: self.fwAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            
            self.fwMaskView.alpha = 1.0
            
        }) { (finished) in
            
        }
    }
    
    /// 隐藏遮罩层
    func hideFwBackground() {
        
        if self.fwReferenceCount > 1 {
            return
        }
        
        UIView.animate(withDuration: self.fwAnimationDuration, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            
            self.fwMaskView.alpha = 0.0
            
        }) { (finished) in
            
            if self == FWPopupSWindow.sharedInstance.attachView() {
                FWPopupSWindow.sharedInstance.isHidden = true
            } else if self.isKind(of: UIWindow.self) {
                self.isHidden = true
            }
            
            self.fwReferenceCount -= 1
        }
    }
}
