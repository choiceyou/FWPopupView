//
//  FWPopupSWindow.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/19.
//  Copyright © 2018年 xfg. All rights reserved.
//  弹窗window

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

public func kPV_RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

open class FWPopupSWindow: UIWindow, UIGestureRecognizerDelegate {
    
    /// 单例模式
    @objc public class var sharedInstance: FWPopupSWindow {
        struct Static {
            static let kbManager = FWPopupSWindow(frame: UIScreen.main.bounds)
        }
        if #available(iOS 13.0, *) {
            if Static.kbManager.windowScene == nil {
                let windowScene = UIApplication.shared.connectedScenes.filter{$0.activationState == .foregroundActive}.first
                Static.kbManager.windowScene = windowScene as? UIWindowScene
            }
        }
        return Static.kbManager
    }
    
    // 默认false，当为true时：用户点击外部遮罩层页面可以消失
    @objc open var touchWildToHide: Bool = false
    // 默认false，当为true时：用户拖动外部遮罩层页面可以消失
    @objc open var panWildToHide: Bool = false
    
    /// 被隐藏的视图队列（A视图正在显示，接着B视图显示，此时就把A视图隐藏同时放入该队列）
    open var hiddenViews: [UIView] = []
    /// 将要展示的视图队列（A视图的显示或者隐藏动画正在进行中时，此时如果B视图要显示，则把B视图放入该队列，等动画结束从该队列中拿出来显示）
    open var willShowingViews: [UIView] = []
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let rootVC = FWPopupRootViewController()
        rootVC.view.backgroundColor = UIColor.clear
        self.rootViewController = rootVC
        
        self.windowLevel = UIWindow.Level.statusBar + 1
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(tapGesClick(tap:)))
        //        tapGest.cancelsTouchesInView = false
        tapGest.delegate = self
        self.addGestureRecognizer(tapGest)
        
        let panGest = UIPanGestureRecognizer(target: self, action: #selector(panGesClick(pan:)))
        self.addGestureRecognizer(panGest)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FWPopupSWindow {
    
    @objc func tapGesClick(tap: UIGestureRecognizer) {
        
        if self.touchWildToHide && !self.attachView()!.fwBackgroundAnimating {
            for view in (self.attachView()?.fwMaskView.subviews)! {
                if view.isKind(of: FWPopupView.self) && !self.hiddenViews.contains(view) {
                    let popupView = view as! FWPopupView
                    if popupView.currentPopupViewState == .didAppear || popupView.currentPopupViewState == .didAppearAgain {
                        popupView.hide()
                    }
                }
            }
        }
    }
    
    @objc func panGesClick(pan: UIGestureRecognizer) {
        
        if self.panWildToHide {
            self.tapGesClick(tap: pan)
        }
    }
    
    /// 隐藏全部的弹窗（包括当前不可见的弹窗）
    @objc public func removeAllPopupView() {
        for view in (self.attachView()?.fwMaskView.subviews)! {
            if view.isKind(of: FWPopupView.self) {
                let popupView = view as! FWPopupView
                popupView.hide()
            }
        }
        self.attachView()?.hideFwBackground()
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.attachView()?.fwMaskView
    }
    
    public func attachView() -> UIView? {
        if self.rootViewController != nil {
            return self.rootViewController?.view
        } else {
            return nil
        }
    }
}
