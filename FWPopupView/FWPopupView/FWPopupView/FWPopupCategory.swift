//
//  FWPopupCategory.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/20.
//  Copyright © 2018年 xfg. All rights reserved.
//

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
            guard let isAnimating = objc_getAssociatedObject(self, fwBackgroundAnimatingKey) as? Bool else {
                return false
            }
            return isAnimating
        }
        set {
            objc_setAssociatedObject(self, fwBackgroundAnimatingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var fwAnimationDuration: TimeInterval {
        get {
            guard let duration = objc_getAssociatedObject(self, fwAnimationDurationKey) as? TimeInterval else {
                return 0.0
            }
            return duration
        }
        set {
            objc_setAssociatedObject(self, fwAnimationDurationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var fwReferenceCount: Int {
        get {
            guard let count = objc_getAssociatedObject(self, fwReferenceCountKey) as? Int else {
                return 0
            }
            return count
        }
        set {
            objc_setAssociatedObject(self, fwReferenceCountKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var fwBackgroundViewColor: UIColor {
        get {
            guard let color = objc_getAssociatedObject(self, fwBackgroundViewColorKey) as? UIColor else {
                return UIColor(white: 0.05, alpha: 0.05)
            }
            return color
        }
        set {
            objc_setAssociatedObject(self, fwBackgroundViewColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.fwBackgroundView.backgroundColor = newValue
            print("111111111")
        }
    }
    
    var fwBackgroundView: UIView {
        var tmpView = objc_getAssociatedObject(self, fwBackgroundViewKey) as? UIView
        if tmpView == nil {
            tmpView = UIView(frame: self.bounds)
            self.addSubview(tmpView!)
            
            tmpView?.alpha = 0.0
            tmpView?.backgroundColor = UIColor(white: 0.05, alpha: 0.05)
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
                    FWPopupWindow.sharedInstance.makeKey()
                } else if self.isKind(of: UIWindow.self) {
                    self.isHidden = true
                    let aa = self as! UIWindow
                    aa.makeKey()
                }
            }
            
        }
    }
}
