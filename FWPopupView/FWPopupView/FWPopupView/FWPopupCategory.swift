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

let fwReferenceCountKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwReferenceCountKey".hashValue)

let fwBackgroundViewKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwBackgroundViewKey".hashValue)
let fwBackgroundViewColorKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwBackgroundViewColorKey".hashValue)
let fwBackgroundAnimatingKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwBackgroundAnimatingKey".hashValue)
let fwAnimationDurationKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "fwAnimationDurationKey".hashValue)

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
    
    var fwBackgroundViewColor: UIColor {
        get {
            let color = objc_getAssociatedObject(self, fwBackgroundViewColorKey) as? UIColor
            guard color != nil else {
                return UIColor(white: 0, alpha: 0.5)
            }
            return color!
        }
        set {
            objc_setAssociatedObject(self, fwBackgroundViewColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var fwBackgroundView: UIView {
        var tmpView = objc_getAssociatedObject(self, fwBackgroundViewKey) as? UIView
        if tmpView == nil {
            tmpView = UIView(frame: self.bounds)
            self.addSubview(tmpView!)
            tmpView?.backgroundColor = fwBackgroundViewColor
            
            tmpView?.alpha = 0.0
            tmpView?.layer.zPosition = CGFloat(MAXFLOAT)
            
            objc_setAssociatedObject(self, fwBackgroundViewKey, tmpView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return tmpView!
    }
    
    
    func showFwBackground() {
        
        self.fwReferenceCount += 1
        if self.fwReferenceCount > 1 {
            return
        }
        self.fwBackgroundView.isHidden = false
        self.fwBackgroundAnimating = true
        
        if self == FWPopupWindow.sharedInstance.attachView() {
            FWPopupWindow.sharedInstance.isHidden = false
            FWPopupWindow.sharedInstance.makeKeyAndVisible()
        } else if self.isKind(of: UIWindow.self) {
            self.isHidden = false
            let aa = self as! UIWindow
            aa.makeKeyAndVisible()
        } else {
            self.bringSubview(toFront: self.fwBackgroundView)
        }
        
        UIView.animate(withDuration: self.fwAnimationDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            
            self.fwBackgroundView.alpha = 1.0
            
        }) { (finished) in
            
            if finished {
                self.fwBackgroundAnimating = false
            }
            
        }
    }
    
    func hideFwBackground() {
        
        self.fwReferenceCount -= 1
        if self.fwReferenceCount > 0 {
            return
        }
        self.fwBackgroundAnimating = true
        
        UIView.animate(withDuration: self.fwAnimationDuration, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            
            self.fwBackgroundView.alpha = 0.0
            
        }) { (finished) in
            
            if finished {
                self.fwBackgroundAnimating = false
                
                if self == FWPopupWindow.sharedInstance.attachView() {
                    FWPopupWindow.sharedInstance.isHidden = true
                    UIApplication.shared.delegate!.window??.makeKey()
                } else if self.isKind(of: UIWindow.self) {
                    self.isHidden = true
                    UIApplication.shared.delegate!.window??.makeKey()
                }
            }
            
        }
    }
}
