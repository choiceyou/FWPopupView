//
//  FWPopupView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/19.
//  Copyright © 2018年 xfg. All rights reserved.
//  弹窗基类

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit
import SnapKit

/// 自定义弹窗校准位置，注意：这边设置靠置哪边动画就从哪边出来
///
/// - center: 中间，默认值
/// - topCenter: 上中
/// - leftCenter: 左中
/// - bottomCenter: 下中
/// - rightCenter: 右中
/// - topLeft: 上左
/// - topRight: 上右
/// - bottomLeft: 下左
/// - bottomRight: 下右
@objc public enum FWPopupCustomAlignment: Int {
    case center
    case topCenter
    case leftCenter
    case bottomCenter
    case rightCenter
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

/// 自定义弹窗动画类型
///
/// - position: 位移动画，视图靠边的时候建议使用
/// - scale: 缩放动画
/// - scale3D: 3D缩放动画（注意：这边隐藏时用的还是scale动画）
/// - frame: 修改frame值的动画，视图未靠边的时候建议使用
@objc public enum FWPopupAnimationType: Int {
    case position
    case scale
    case scale3D
    case frame
}

/// 弹窗箭头的样式
///
/// - none: 无箭头
/// - round: 圆角
/// - triangle: 菱角
@objc public enum FWMenuArrowStyle: Int {
    case none
    case round
    case triangle
}

/// 弹窗状态
///
/// - unKnow: 不知
/// - willAppear: 将要显示
/// - didAppear: 已经显示
/// - willDisappear: 将要隐藏
/// - didDisappear: 已经隐藏
/// - didAppearButCovered: 已经显示，但是被其他弹窗遮盖住了（实际上当前状态下弹窗是不可见）
/// - didAppearAgain: 已经显示，其上面遮盖的弹窗消失了（实际上当前状态与FWPopupStateDidAppear状态相同）
@objc public enum FWPopupViewState: Int {
    case unKnow
    case willAppear
    case didAppear
    case willDisappear
    case didDisappear
    case didAppearButCovered
    case didAppearAgain
}

/// 当前约束的状态
///
/// - beforeAnimation: 动画之前的约束
/// - showAnimation: 显示动画的约束
/// - hideAnimation: 隐藏动画的约束
private enum FWConstraintsState: Int {
    case constraintsBeforeAnimation
    case constraintsShownAnimation
    case constraintsHiddenAnimation
}


/// 弹窗已经显示回调
public typealias FWPopupDidAppearBlock = (_ popupView: FWPopupView) -> Void
/// 弹窗已经隐藏回调
public typealias FWPopupDidDisappearBlock = (_ popupView: FWPopupView) -> Void
/// 弹窗状态回调，注意：该回调会走N次
public typealias FWPopupStateBlock = (_ popupView: FWPopupView, _ popupViewState: FWPopupViewState) -> Void

/// 弹窗显示、隐藏回调，内部回调，该回调不对外
public typealias FWPopupShowBlock = (_ popupView: FWPopupView) -> Void
/// 弹窗显示、隐藏回调，内部回调，该回调不对外
public typealias FWPopupHideBlock = (_ popupView: FWPopupView, _ hideWithRemove: Bool) -> Void

/// 普通无参数回调
public typealias FWPopupVoidBlock = () -> Void

/// 隐藏所有弹窗的通知
let FWPopupViewHideAllNotification = "FWPopupViewHideAllNotification"


open class FWPopupView: UIView, UIGestureRecognizerDelegate {
    
    /// 单击隐藏
    private var tapGest: UITapGestureRecognizer?
    
    /// 1、当外部没有传入该参数时，默认为UIWindow的根控制器的视图，即表示弹窗放在FWPopupSWindow上，此时若FWPopupSWindow.sharedInstance.touchWildToHide = true表示弹窗视图外部可点击；2、当外部传入该参数时，该视图为传入的UIView，即表示弹窗放在传入的UIView上；
    @objc public var attachedView = FWPopupSWindow.sharedInstance.attachView() {
        willSet {
            newValue?.fwMaskView.addSubview(self)
            if newValue!.isKind(of: UIScrollView.self) {
                self.originScrollEnabled = (newValue! as! UIScrollView).isScrollEnabled
            }
        }
    }
    
    /// FWPopupType = custom 的可设置参数
    @objc public var vProperty = FWPopupViewProperty() {
        willSet {
            self.attachedView?.fwAnimationDuration = newValue.animationDuration
            if newValue.backgroundColor != nil {
                self.backgroundColor = newValue.backgroundColor
            } else if newValue.backgroundLayerColors != nil {
                var tmpArray: [Any] = []
                for color: UIColor in newValue.backgroundLayerColors! {
                    tmpArray.append(color.cgColor as Any)
                }
                self.backgroundLayer.colors = tmpArray
            }
        }
    }
    
    /// 当前弹窗是否可见
    @objc public var visible: Bool {
        get {
            if self.attachedView != nil {
                return !(self.attachedView!.fwMaskView.alpha == 0)
            }
            return false
        }
    }
    
    /// 是否有用到键盘
    @objc public var withKeyboard = false
    
    
    private var popupDidAppearBlock: FWPopupDidAppearBlock?
    private var popupDidDisappearBlock: FWPopupDidDisappearBlock?
    private var popupStateBlock: FWPopupStateBlock?
    
    private var showAnimation: FWPopupShowBlock?
    
    private var hideAnimation: FWPopupHideBlock?
    
    /// 记录遮罩层设置前的颜色
    internal var originMaskViewColor: UIColor!
    /// 记录遮罩层设置前的是否可点击
    internal var originTouchWildToHide: Bool!
    /// 遮罩层为UIScrollView或其子类时，记录是否可以滚动
    internal var originScrollEnabled: Bool?
    /// 记录弹窗弹起前keywindow
    internal var originKeyWindow: UIWindow?
    /// 是否不需要设置Size（当前基类使用SnapKit，如果子类不希望该父类重置他的size，可以传入true）
    internal var isNotMakeSize: Bool = false
    
    /// 弹窗真正的Size
    internal var finalSize = CGSize.zero
    /// 当前Constraints是否被设置过了
    private var haveSetConstraints: Bool = false
    
    /// 是否重新设置了父视图
    private var isResetSuperView: Bool = false
    
    /// 渐变的背景颜色
    private lazy var backgroundLayer: CAGradientLayer = {
        var backgroundLayer = CAGradientLayer()
        self.layer.addSublayer(backgroundLayer)
        backgroundLayer.startPoint = self.vProperty.backgroundLayerStartPoint
        backgroundLayer.endPoint = self.vProperty.backgroundLayerEndPoint
        backgroundLayer.locations = self.vProperty.backgroundLayerLocations
        backgroundLayer.type = CAGradientLayerType.axial
        return backgroundLayer
    }()
    
    /// 记录当前弹窗状态
    public var currentPopupViewState: FWPopupViewState = .unKnow {
        willSet {
            if self.popupStateBlock != nil {
                self.popupStateBlock!(self, newValue)
            }
        }
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupParams()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupParams()
    }
    
    private func setupParams() {
        self.backgroundColor = UIColor.white
        
        FWPopupSWindow.sharedInstance.backgroundColor = UIColor.clear
        
        self.originMaskViewColor = self.attachedView?.fwMaskViewColor
        self.originTouchWildToHide = FWPopupSWindow.sharedInstance.touchWildToHide
        self.attachedView?.fwMaskView.addSubview(self)
        self.isHidden = true
        
        self.showAnimation = self.customShowAnimation()
        self.hideAnimation = self.customHideAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyHideAll(notification:)), name: NSNotification.Name(rawValue: FWPopupViewHideAllNotification), object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if self.attachedView!.isKind(of: UIScrollView.self) && self.originScrollEnabled != nil {
            (self.attachedView! as! UIScrollView).isScrollEnabled = self.originScrollEnabled!
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.vProperty.backgroundLayerColors != nil {
            self.backgroundLayer.frame = self.bounds
        }
    }
    
    @objc open func showKeyboard() {
        // 供子类重写
    }
    
    @objc open func hideKeyboard() {
        // 供子类重写
    }
}

// MARK: - 显示、隐藏
extension FWPopupView {
    
    /// 显示
    @objc open func show() {
        
        self.show(popupDidAppearBlock: nil)
    }
    
    /// 显示
    ///
    /// - Parameter popupDidAppearBlock: 弹窗已经显示回调
    @objc open func show(popupDidAppearBlock: FWPopupDidAppearBlock? = nil) {
        
        self.popupDidAppearBlock = popupDidAppearBlock
        self.show(popupStateBlock: nil)
    }
    
    /// 显示
    ///
    /// - Parameter completionBlock: 显示、隐藏回调
    @objc open func show(popupStateBlock: FWPopupStateBlock? = nil) {
        
        if self.superview == nil {
            self.attachedView?.fwMaskView.addSubview(self)
            self.isResetSuperView = true
        }
        
        self.popupStateBlock = popupStateBlock
        
        if self.attachedView?.fwBackgroundAnimating == true {
            FWPopupSWindow.sharedInstance.willShowingViews.append(self)
        } else {
            self.showNow()
        }
    }
    
    private func showNow() {
        
        if self.currentPopupViewState == .willAppear || self.currentPopupViewState == .didAppear || self.currentPopupViewState == .didAppearButCovered || self.currentPopupViewState == .didAppearAgain {
            return
        }
        self.currentPopupViewState = .willAppear
        
        // 弹起时设置相关参数，因为隐藏或者销毁时会被重置掉，所以每次弹起时都重新调用
        if self.attachedView != nil && self.vProperty.maskViewColor != nil {
            self.attachedView?.fwMaskViewColor = self.vProperty.maskViewColor!
        }
        for tmpWindow in UIApplication.shared.windows {
            if tmpWindow.isKeyWindow {
                self.originKeyWindow = tmpWindow
            }
        }
        if self.vProperty.touchWildToHide != nil && !self.vProperty.touchWildToHide!.isEmpty && Int(self.vProperty.touchWildToHide!) == 1 {
            FWPopupSWindow.sharedInstance.touchWildToHide = true
        } else {
            FWPopupSWindow.sharedInstance.touchWildToHide = false
        }
        self.attachedView?.fwAnimationDuration = self.vProperty.animationDuration
        
        if self.attachedView != nil && self.attachedView != FWPopupSWindow.sharedInstance.attachView() {
            if tapGest == nil {
                tapGest = UITapGestureRecognizer(target: self, action: #selector(tapGesClick(tap:)))
                //                tapGest?.cancelsTouchesInView = false
                tapGest?.delegate = self
                self.attachedView?.addGestureRecognizer(tapGest!)
            } else {
                self.tapGest?.isEnabled = true
            }
            if self.attachedView!.isKind(of: UIScrollView.self) {
                (self.attachedView! as! UIScrollView).isScrollEnabled = false
            }
        }
        
        if self.attachedView == nil {
            self.attachedView = FWPopupSWindow.sharedInstance.attachView()
        }
        
        self.attachedView?.showFwBackground()
        
        let showA = self.showAnimation
        showA!(self)
        
        if self.withKeyboard {
            self.showKeyboard()
        }
    }
    
    /// 隐藏，从父视图中移除
    @objc open func hide() {
        
        self.hide(popupDidDisappearBlock: nil)
    }
    
    /// 隐藏，从父视图中移除同时回调
    ///
    /// - Parameter completionBlock: 显示、隐藏回调
    @objc open func hide(popupDidDisappearBlock: FWPopupDidDisappearBlock? = nil) {
        
        self.popupDidDisappearBlock = popupDidDisappearBlock
        self.hideNow(isRemove: true)
    }
    
    /// 隐藏，父视图中不移除当前视图（如果使用这个隐藏方法，不需要使用的时候可以手动把该弹窗从父视图中移除，否则可能会造成内存泄漏）
    @objc open func hideWithNotRemove() {
        
        self.hideNow(isRemove: false)
    }
    
    private func hideNow(isRemove: Bool) {
        
        if self.currentPopupViewState == .willDisappear || self.currentPopupViewState == .didDisappear {
            return
        }
        self.currentPopupViewState = .willDisappear
        
        if self.attachedView == nil {
            self.attachedView = FWPopupSWindow.sharedInstance.attachView()
        }
        
        self.attachedView?.fwAnimationDuration = self.vProperty.animationDuration
        
        for tmpView: UIView in FWPopupSWindow.sharedInstance.hiddenViews {
            if tmpView == self {
                if let index = FWPopupSWindow.sharedInstance.hiddenViews.firstIndex(of: tmpView) {
                    FWPopupSWindow.sharedInstance.hiddenViews.remove(at: index)
                }
            }
        }
        
        if FWPopupSWindow.sharedInstance.hiddenViews.isEmpty && FWPopupSWindow.sharedInstance.willShowingViews.isEmpty && self.attachedView?.fwBackgroundAnimating == false {
            self.attachedView?.hideFwBackground()
        }
        
        if self.withKeyboard {
            self.hideKeyboard()
        }
        
        let hideAnimation = self.hideAnimation
        if hideAnimation != nil {
            hideAnimation!(self, isRemove)
        }
        
        if self.tapGest != nil && self.attachedView != nil {
            self.tapGest?.isEnabled = false
        }
        
        // 还原弹窗弹起时的相关参数
        self.attachedView?.fwMaskViewColor = self.originMaskViewColor
        FWPopupSWindow.sharedInstance.touchWildToHide = self.originTouchWildToHide
        if self.attachedView!.isKind(of: UIScrollView.self) && self.originScrollEnabled != nil {
            (self.attachedView! as! UIScrollView).isScrollEnabled = self.originScrollEnabled!
        }
        if self.originKeyWindow != nil {
            self.originKeyWindow!.makeKey()
        }
    }
    
    /// 隐藏所有的弹窗
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
        return FWPopupSWindow.sharedInstance.isHidden
    }
}

// MARK: - 动画事件
extension FWPopupView {
    
    /// 显示动画
    ///
    /// - Returns: FWPopupShowBlock
    private func customShowAnimation() -> FWPopupShowBlock {
        
        let popupBlock = { [weak self] (popupView: FWPopupView) in
            
            guard let strongSelf = self else {
                return
            }
            
            // 保证前一次弹窗销毁完毕
            var tmpHiddenViews: [UIView] = []
            for view in strongSelf.attachedView!.fwMaskView.subviews {
                if view.isKind(of: FWPopupView.self) {
                    if view == strongSelf {
                        view.isHidden = false
                    } else if (view as! FWPopupView).currentPopupViewState != .unKnow {
                        view.isHidden = true
                        (view as! FWPopupView).currentPopupViewState = .didAppearButCovered
                        tmpHiddenViews.append(view)
                    }
                }
            }
            FWPopupSWindow.sharedInstance.hiddenViews.removeAll()
            FWPopupSWindow.sharedInstance.hiddenViews.append(contentsOf: tmpHiddenViews)
            
            if !strongSelf.haveSetConstraints || strongSelf.isResetSuperView == true {
                strongSelf.setupConstraints(constraintsState: .constraintsBeforeAnimation)
            }
            
            strongSelf.setupConstraints(constraintsState: .constraintsShownAnimation)
            
            strongSelf.attachedView?.fwBackgroundAnimating = true
            
            if strongSelf.vProperty.usingSpringWithDamping >= 0 && strongSelf.vProperty.usingSpringWithDamping <= 1 {
                UIView.animate(withDuration: strongSelf.vProperty.animationDuration, delay: 0.0, usingSpringWithDamping: strongSelf.vProperty.usingSpringWithDamping, initialSpringVelocity: strongSelf.vProperty.initialSpringVelocity, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    
                    strongSelf.showAnimationDuration()
                    
                }, completion: { (finished) in
                    
                    strongSelf.showAnimationFinished()
                    
                })
            } else {
                UIView.animate(withDuration: strongSelf.vProperty.animationDuration, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    
                    strongSelf.showAnimationDuration()
                    
                }, completion: { (finished) in
                    
                    strongSelf.showAnimationFinished()
                    
                })
            }
        }
        
        return popupBlock
    }
    
    /// 显示动画的操作
    private func showAnimationDuration() {
        
        if self.vProperty.popupAnimationType == .position {
            self.superview?.layoutIfNeeded()
        } else if self.vProperty.popupAnimationType == .frame {
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        } else if self.vProperty.popupAnimationType == .scale {
            self.transform = CGAffineTransform.identity
        } else if self.vProperty.popupAnimationType == .scale3D {
            self.layer.transform = CATransform3DIdentity
        }
    }
    
    /// 显示动画完成后的操作
    private func showAnimationFinished() {
        
        if self.popupDidAppearBlock != nil {
            self.popupDidAppearBlock!(self)
        }
        self.currentPopupViewState = .didAppear
        
        if FWPopupSWindow.sharedInstance.willShowingViews.count > 0 {
            let willShowingView: FWPopupView = FWPopupSWindow.sharedInstance.willShowingViews.first as! FWPopupView
            willShowingView.showNow()
            FWPopupSWindow.sharedInstance.willShowingViews.removeFirst()
        } else {
            self.attachedView?.fwBackgroundAnimating = false
        }
    }
    
    /// 隐藏动画
    ///
    /// - Returns: FWPopupHideBlock
    private func customHideAnimation() -> FWPopupHideBlock {
        
        let popupBlock: FWPopupHideBlock = { [weak self] popupView, isRemove in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.setupConstraints(constraintsState: .constraintsHiddenAnimation)
            
            strongSelf.attachedView?.fwBackgroundAnimating = true
            
            UIView.animate(withDuration: strongSelf.vProperty.animationDuration, animations: {
                
                if strongSelf.vProperty.popupAnimationType == .position {
                    strongSelf.superview?.layoutIfNeeded()
                } else if strongSelf.vProperty.popupAnimationType == .frame {
                    strongSelf.superview?.layoutIfNeeded()
                    strongSelf.layoutIfNeeded()
                } else if strongSelf.vProperty.popupAnimationType == .scale || strongSelf.vProperty.popupAnimationType == .scale3D {
                    strongSelf.transform = strongSelf.vProperty.transform
                }
                
            }, completion: { (finished) in
                
                if isRemove == true {
                    strongSelf.removeFromSuperview()
                    if let index = FWPopupSWindow.sharedInstance.hiddenViews.firstIndex(of: strongSelf) {
                        FWPopupSWindow.sharedInstance.hiddenViews.remove(at: index)
                    }
                }
                strongSelf.isHidden = true
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.0001, execute: {
                    if FWPopupSWindow.sharedInstance.willShowingViews.count > 0 {
                        let willShowingView: FWPopupView = FWPopupSWindow.sharedInstance.willShowingViews.last as! FWPopupView
                        willShowingView.showNow()
                        FWPopupSWindow.sharedInstance.willShowingViews.removeLast()
                    } else if !FWPopupSWindow.sharedInstance.hiddenViews.isEmpty {
                        let showView: FWPopupView = FWPopupSWindow.sharedInstance.hiddenViews.last as! FWPopupView
                        showView.isHidden = false
                        showView.currentPopupViewState = .didAppearAgain
                        FWPopupSWindow.sharedInstance.hiddenViews.removeLast()
                        if showView.vProperty.touchWildToHide != nil && !showView.vProperty.touchWildToHide!.isEmpty && Int(showView.vProperty.touchWildToHide!) == 1 {
                            FWPopupSWindow.sharedInstance.touchWildToHide = true
                        } else {
                            FWPopupSWindow.sharedInstance.touchWildToHide = false
                        }
                    }
                    
                    strongSelf.currentPopupViewState = .didDisappear
                    if strongSelf.popupDidDisappearBlock != nil {
                        strongSelf.popupDidDisappearBlock!(strongSelf)
                    }
                })
                
                strongSelf.attachedView?.fwBackgroundAnimating = false
                
            })
        }
        
        return popupBlock
    }
    
    /// 根据不同状态、动画设置视图的不同约束
    ///
    /// - Parameter constraintsState: FWConstraintsState
    private func setupConstraints(constraintsState: FWConstraintsState) {
        
        let myAlignment: FWPopupCustomAlignment = self.vProperty.popupCustomAlignment
        let edgeInsets = self.vProperty.popupViewEdgeInsets
        
        if constraintsState == .constraintsBeforeAnimation {
            self.layoutIfNeeded()
            if self.finalSize.equalTo(CGSize.zero) {
                self.finalSize = self.frame.size
            }
            self.haveSetConstraints = true
            
            if self.vProperty.popupAnimationType == .position {
                if self.isResetSuperView == true {
                    self.isResetSuperView = false
                    self.snp.remakeConstraints { (make) in
                        make.size.equalTo(self.finalSize)
                        self.constraintsBeforeAnimationPosition(make: make, myAlignment: myAlignment)
                    }
                } else {
                    self.snp.makeConstraints { (make) in
                        if self.isNotMakeSize == false {
                            make.size.equalTo(self.finalSize)
                        }
                        self.constraintsBeforeAnimationPosition(make: make, myAlignment: myAlignment)
                    }
                }
                self.superview?.layoutIfNeeded()
            } else if self.vProperty.popupAnimationType == .frame {
                if self.isResetSuperView == true {
                    self.isResetSuperView = false
                    self.snp.remakeConstraints { (make) in
                        self.constraintsBeforeAnimationFrame(make: make, myAlignment: myAlignment)
                    }
                } else {
                    self.snp.makeConstraints { (make) in
                        self.constraintsBeforeAnimationFrame(make: make, myAlignment: myAlignment)
                    }
                }
                self.superview?.layoutIfNeeded()
            } else if self.vProperty.popupAnimationType == .scale || self.vProperty.popupAnimationType == .scale3D {
                if self.isResetSuperView == true {
                    self.isResetSuperView = false
                    self.snp.remakeConstraints { (make) in
                        make.size.equalTo(self.finalSize)
                        self.constraintsBeforeAnimationScale(make: make, myAlignment: myAlignment)
                    }
                } else {
                    self.snp.makeConstraints { (make) in
                        if self.isNotMakeSize == false {
                            make.size.equalTo(self.finalSize)
                        }
                        self.constraintsBeforeAnimationScale(make: make, myAlignment: myAlignment)
                    }
                }
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
                if self.vProperty.popupAnimationType == .scale {
                    self.transform = self.vProperty.transform
                } else {
                    self.layer.transform = self.vProperty.transform3D
                }
            }
        } else if constraintsState == .constraintsShownAnimation {
            self.snp.updateConstraints { (make) in
                if self.vProperty.popupAnimationType == .position {
                    if myAlignment == .center {
                        make.centerY.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
                    } else if myAlignment == .topCenter {
                        make.top.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
                    } else if myAlignment == .leftCenter {
                        make.left.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
                    } else if myAlignment == .bottomCenter {
                        make.bottom.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
                    } else if myAlignment == .rightCenter {
                        make.right.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
                    } else if myAlignment == .topLeft {
                        make.top.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
                    } else if myAlignment == .topRight {
                        make.top.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
                    } else if myAlignment == .bottomLeft {
                        make.bottom.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
                    } else if myAlignment == .bottomRight {
                        make.bottom.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
                    }
                } else if self.vProperty.popupAnimationType == .frame {
                    if myAlignment == .center {
                        make.height.equalTo(self.finalSize.height)
                    } else if myAlignment == .topCenter {
                        make.height.equalTo(self.finalSize.height)
                    } else if myAlignment == .leftCenter {
                        make.width.equalTo(self.finalSize.width)
                    } else if myAlignment == .bottomCenter {
                        make.height.equalTo(self.finalSize.height)
                    } else if myAlignment == .rightCenter {
                        make.width.equalTo(self.finalSize.width)
                    } else if myAlignment == .topLeft {
                        make.height.equalTo(self.finalSize.height)
                    } else if myAlignment == .topRight {
                        make.height.equalTo(self.finalSize.height)
                    } else if myAlignment == .bottomLeft {
                        make.height.equalTo(self.finalSize.height)
                    } else if myAlignment == .bottomRight {
                        make.height.equalTo(self.finalSize.height)
                    }
                }
            }
        } else if constraintsState == .constraintsHiddenAnimation {
            self.snp.updateConstraints { (make) in
                if self.vProperty.popupAnimationType == .position {
                    if myAlignment == .center {
                        make.centerY.equalToSuperview().offset(-self.finalSize.height/2 - self.superview!.frame.size.height/2)
                    } else if myAlignment == .topCenter {
                        make.top.equalToSuperview().offset(-self.finalSize.height)
                    } else if myAlignment == .leftCenter {
                        make.left.equalToSuperview().offset(-self.finalSize.width)
                    } else if myAlignment == .bottomCenter {
                        make.bottom.equalToSuperview().offset(self.finalSize.height)
                    } else if myAlignment == .rightCenter {
                        make.right.equalToSuperview().offset(self.finalSize.width)
                    } else if myAlignment == .topLeft {
                        make.top.equalToSuperview().offset(-self.finalSize.height)
                    } else if myAlignment == .topRight {
                        make.top.equalToSuperview().offset(-self.finalSize.height)
                    } else if myAlignment == .bottomLeft {
                        make.bottom.equalToSuperview().offset(self.finalSize.height)
                    } else if myAlignment == .bottomRight {
                        make.bottom.equalToSuperview().offset(self.finalSize.height)
                    }
                } else if self.vProperty.popupAnimationType == .frame {
                    if myAlignment == .center {
                        make.height.equalTo(0)
                    } else if myAlignment == .topCenter {
                        make.height.equalTo(0)
                    } else if myAlignment == .leftCenter {
                        make.width.equalTo(0)
                    } else if myAlignment == .bottomCenter {
                        make.height.equalTo(0)
                    } else if myAlignment == .rightCenter {
                        make.width.equalTo(0)
                    } else if myAlignment == .topLeft {
                        make.height.equalTo(0)
                    } else if myAlignment == .topRight {
                        make.height.equalTo(0)
                    } else if myAlignment == .bottomLeft {
                        make.height.equalTo(0)
                    } else if myAlignment == .bottomRight {
                        make.height.equalTo(0)
                    }
                }
            }
        }
    }
    
    /// 位移动画展示前的约束
    ///
    /// - Parameters:
    ///   - make: ConstraintMaker
    ///   - myAlignment: 自定义弹窗校准位置
    private func constraintsBeforeAnimationPosition(make: ConstraintMaker, myAlignment: FWPopupCustomAlignment) {
        
        let edgeInsets = self.vProperty.popupViewEdgeInsets
        
        if myAlignment == .center {
            make.centerX.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.centerY.equalToSuperview().offset(-self.finalSize.height/2 - self.superview!.frame.size.height/2)
        } else if myAlignment == .topCenter {
            make.centerX.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(-self.finalSize.height)
        } else if myAlignment == .leftCenter {
            make.centerY.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.left.equalToSuperview().offset(-self.finalSize.width)
        } else if myAlignment == .bottomCenter {
            make.centerX.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(self.finalSize.height)
        } else if myAlignment == .rightCenter {
            make.centerY.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.right.equalToSuperview().offset(self.finalSize.width)
        } else if myAlignment == .topLeft {
            make.left.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(-self.finalSize.height)
        } else if myAlignment == .topRight {
            make.right.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(-self.finalSize.height)
        } else if myAlignment == .bottomLeft {
            make.left.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(self.finalSize.height)
        } else if myAlignment == .bottomRight {
            make.right.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(self.finalSize.height)
        }
    }
    
    /// 修改frame值动画展示前的约束
    ///
    /// - Parameters:
    ///   - make: ConstraintMaker
    ///   - myAlignment: 自定义弹窗校准位置
    private func constraintsBeforeAnimationFrame(make: ConstraintMaker, myAlignment: FWPopupCustomAlignment) {
        
        let edgeInsets = self.vProperty.popupViewEdgeInsets
        
        if myAlignment == .center {
            make.top.equalToSuperview().offset((self.superview!.frame.size.height-self.finalSize.height)/2 + edgeInsets.top - edgeInsets.bottom)
            make.centerX.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.width.equalTo(self.finalSize.width)
            make.height.equalTo(0)
        } else if myAlignment == .topCenter {
            make.centerX.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.width.equalTo(self.finalSize.width)
            make.height.equalTo(0)
        } else if myAlignment == .leftCenter {
            make.centerY.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.left.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.width.equalTo(0)
            make.height.equalTo(self.finalSize.height)
        } else if myAlignment == .bottomCenter {
            make.centerX.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.width.equalTo(self.finalSize.width)
            make.height.equalTo(0)
        } else if myAlignment == .rightCenter {
            make.centerY.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.right.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.width.equalTo(0)
            make.height.equalTo(self.finalSize.height)
        } else if myAlignment == .topLeft {
            make.left.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.width.equalTo(self.finalSize.width)
            make.height.equalTo(0)
        } else if myAlignment == .topRight {
            make.right.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.width.equalTo(self.finalSize.width)
            make.height.equalTo(0)
        } else if myAlignment == .bottomLeft {
            make.left.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.width.equalTo(self.finalSize.width)
            make.height.equalTo(0)
        } else if myAlignment == .bottomRight {
            make.right.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(edgeInsets.top - edgeInsets.bottom)
            make.width.equalTo(self.finalSize.width)
            make.height.equalTo(0)
        }
    }
    
    /// 缩放动画展示前的约束
    ///
    /// - Parameters:
    ///   - make: ConstraintMaker
    ///   - myAlignment: 自定义弹窗校准位置
    private func constraintsBeforeAnimationScale(make: ConstraintMaker, myAlignment: FWPopupCustomAlignment) {
        
        let edgeInsets = self.vProperty.popupViewEdgeInsets
        let anchorPoint = self.obtainAnchorPoint()
        self.layer.anchorPoint = anchorPoint
        if myAlignment == .center {
            make.center.equalToSuperview().inset(edgeInsets)
        } else if myAlignment == .topCenter {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerX.equalToSuperview().offset(-self.finalSize.width*(0.5-anchorPoint.x) + edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(-self.finalSize.height*(1-anchorPoint.y)/2 + edgeInsets.top - edgeInsets.bottom)
        } else if myAlignment == .leftCenter {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerY.equalToSuperview().offset(-self.finalSize.height*(0.5-anchorPoint.y) + edgeInsets.top - edgeInsets.bottom)
            make.left.equalToSuperview().offset(-self.finalSize.width/2 + self.finalSize.width*anchorPoint.x + edgeInsets.left - edgeInsets.right)
        } else if myAlignment == .bottomCenter {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerX.equalToSuperview().offset(edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(self.finalSize.height*(anchorPoint.y-0.5) + edgeInsets.top - edgeInsets.bottom)
        } else if myAlignment == .rightCenter {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerY.equalToSuperview().offset(-self.finalSize.height*(0.5-anchorPoint.y) + edgeInsets.top - edgeInsets.bottom)
            make.right.equalToSuperview().offset(self.finalSize.width/2 - self.finalSize.width*(1-anchorPoint.x) + edgeInsets.left - edgeInsets.right)
        } else if myAlignment == .topLeft {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.left.equalToSuperview().offset(-self.finalSize.width/2 + self.finalSize.width*anchorPoint.x + edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(-self.finalSize.height*(1-anchorPoint.y)/2 + edgeInsets.top - edgeInsets.bottom)
        } else if myAlignment == .topRight {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.right.equalToSuperview().offset(self.finalSize.width/2 - self.finalSize.width*(1-anchorPoint.x) + edgeInsets.left - edgeInsets.right)
            make.top.equalToSuperview().offset(-self.finalSize.height*(1-anchorPoint.y)/2 + edgeInsets.top - edgeInsets.bottom)
        } else if myAlignment == .bottomLeft {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.left.equalToSuperview().offset(-self.finalSize.width/2 + self.finalSize.width*anchorPoint.x + edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(self.finalSize.height*(anchorPoint.y-0.5) + edgeInsets.top - edgeInsets.bottom)
        } else if myAlignment == .bottomRight {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.right.equalToSuperview().offset(self.finalSize.width/2 - self.finalSize.width*(1-anchorPoint.x) + edgeInsets.left - edgeInsets.right)
            make.bottom.equalToSuperview().offset(self.finalSize.height*(anchorPoint.y-0.5) + edgeInsets.top - edgeInsets.bottom)
        }
    }
    
    /// 获取当前视图的锚点
    ///
    /// - Returns: CGPoint
    private func obtainAnchorPoint() -> CGPoint {
        
        if self.vProperty.popupArrowVertexScaleX > 1 {
            self.vProperty.popupArrowVertexScaleX = 1
        } else if self.vProperty.popupArrowVertexScaleX < 0 {
            self.vProperty.popupArrowVertexScaleX = 0
        }
        
        var tmpX: CGFloat = 0
        var tmpY: CGFloat = 0
        switch self.vProperty.popupCustomAlignment {
        case .center:
            tmpX = 0.5
            tmpY = 0.5
            break
        case .topLeft, .topCenter, .topRight:
            if self.vProperty.popupArrowStyle == .none {
                tmpX = self.vProperty.popupArrowVertexScaleX
            } else {
                let arrowVertexX = (self.finalSize.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2
                tmpX = arrowVertexX / self.finalSize.width
            }
            tmpY = 0
            break
        case .leftCenter:
            tmpX = 0
            tmpY = 0.5
            break
        case .rightCenter:
            tmpX = 1
            tmpY = 0.5
            break
        default:
            if self.vProperty.popupArrowStyle == .none {
                tmpX = self.vProperty.popupArrowVertexScaleX
            } else {
                let arrowVertexX = (self.finalSize.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2
                tmpX = arrowVertexX / self.finalSize.width
            }
            tmpY = 1
            break
        }
        return CGPoint(x: tmpX, y: tmpY)
    }
}

// MARK: - 其他
extension FWPopupView {
    
    /// 重置视图size
    ///
    /// - Parameters:
    ///   - size: 新的size
    ///   - isImmediateEffect: 是否立即生效，当 currentPopupState==FWPopupStateDidAppear 时有效，此时弹窗会重新显示，此时相应的回调也会重新走
    @objc open func resetSize(size: CGSize, isImmediateEffect: Bool) {
        
        self.finalSize = size
        if isImmediateEffect && (self.currentPopupViewState == .didAppear || self.currentPopupViewState == .didAppearAgain) {
            self.hide { [weak self] (popupView) in
                guard let strongSelf = self else {
                    return
                }
                if strongSelf.popupDidAppearBlock != nil {
                    strongSelf.show(popupDidAppearBlock: strongSelf.popupDidAppearBlock)
                } else if strongSelf.popupStateBlock != nil {
                    strongSelf.show(popupStateBlock: strongSelf.popupStateBlock)
                } else {
                    strongSelf.show()
                }
            }
        }
    }
    
    /// 点击隐藏
    ///
    /// - Parameter tap: 手势
    @objc func tapGesClick(tap: UITapGestureRecognizer) {
        
        if FWPopupSWindow.sharedInstance.touchWildToHide && !self.fwBackgroundAnimating {
            for view: UIView in (self.attachedView?.fwMaskView.subviews)! {
                if view.isKind(of: FWPopupView.self) {
                    let popupView = view as! FWPopupView
                    popupView.hide()
                }
            }
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isMember(of: UIView.self) {
            return true
        } else {
            return false
        }
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


// MARK: - 弹窗的相关配置属性
open class FWPopupViewProperty: NSObject {
    
    /// 标题字体大小
    @objc open var titleFontSize: CGFloat = 18.0
    /// 标题字体，设置该值后titleFontSize无效
    @objc open var titleFont: UIFont?
    /// 标题文字颜色
    @objc open var titleColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    
    /// 按钮字体大小
    @objc open var buttonFontSize: CGFloat = 17.0
    /// 按钮字体，设置该值后buttonFontSize无效
    @objc open var buttonFont: UIFont?
    /// 按钮高度
    @objc open var buttonHeight: CGFloat = 48.0
    /// 普通按钮文字颜色
    @objc open var itemNormalColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    /// 高亮按钮文字颜色
    @objc open var itemHighlightColor: UIColor = kPV_RGBA(r: 254, g: 226, b: 4, a: 1)
    /// 选中按钮文字颜色
    @objc open var itemPressedColor: UIColor = kPV_RGBA(r: 240, g: 240, b: 240, a: 1)
    
    /// 单个控件中的文字（图片）等与该控件上（下）之前的距离。注意：这个距离指的是单个控件内部哦，不是控件与控件之间
    @objc open var topBottomMargin:CGFloat = 10
    /// 单个控件中的文字（图片）等与该控件左（右）之前的距离。注意：这个距离指的是单个控件内部哦，不是控件与控件之间
    @objc open var letfRigthMargin:CGFloat = 10
    /// 控件之间的间距
    @objc open var commponentMargin:CGFloat = 10
    
    /// 边框颜色（部分控件分割线也用这个颜色）
    @objc open var splitColor: UIColor = kPV_RGBA(r: 231, g: 231, b: 231, a: 1)
    /// 分割线、边框的宽度
    @objc open var splitWidth: CGFloat = (1/UIScreen.main.scale)
    /// 圆角值
    @objc open var cornerRadius: CGFloat = 5.0
    
    /// 弹窗的背景色（注意：这边指的是弹窗而不是遮罩层，遮罩层背景色的设置是：fwMaskViewColor）
    @objc open var backgroundColor: UIColor?
    /// 弹窗的背景渐变色：当未设置backgroundColor时该值才有效
    @objc open var backgroundLayerColors: [UIColor]?
    /// 弹窗的背景渐变色相关属性：当设置了backgroundLayerColors时该值才有效
    @objc open var backgroundLayerStartPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    /// 弹窗的背景渐变色相关属性：当设置了backgroundLayerColors时该值才有效
    @objc open var backgroundLayerEndPoint: CGPoint = CGPoint(x: 1.0, y: 0.0)
    /// 弹窗的背景渐变色相关属性：当设置了backgroundLayerColors时该值才有效
    @objc open var backgroundLayerLocations: [NSNumber] = [0, 1]
    
    /// 弹窗的最大高度占遮罩层高度的比例，0：表示不限制
    @objc open var popupViewMaxHeightRate: CGFloat = 0.6
    
    /// 弹窗箭头的样式
    @objc open var popupArrowStyle = FWMenuArrowStyle.none
    /// 弹窗箭头的尺寸
    @objc open var popupArrowSize = CGSize(width: 28, height: 12)
    /// 弹窗箭头的顶点的X值相对于弹窗的宽度，默认在弹窗X轴的一半，因此设置范围：0~1
    @objc open var popupArrowVertexScaleX: CGFloat = 0.5
    /// 弹窗圆角箭头的圆角值
    @objc open var popupArrowCornerRadius: CGFloat = 2.5
    /// 弹窗圆角箭头与边线交汇处的圆角值
    @objc open var popupArrowBottomCornerRadius: CGFloat = 4.0
    
    
    // ===== 自定义弹窗（继承FWPopupView）时可能会用到 =====
    
    /// 弹窗校准位置
    @objc open var popupCustomAlignment: FWPopupCustomAlignment = .center
    /// 弹窗动画类型
    @objc open var popupAnimationType: FWPopupAnimationType = .position
    
    /// 弹窗偏移量
    @objc open var popupViewEdgeInsets = UIEdgeInsets.zero
    /// 遮罩层的背景色（也可以使用fwMaskViewColor），注意：该参数在弹窗隐藏后，还原为弹窗弹起时的值
    @objc open var maskViewColor: UIColor?
    /// 为了兼容OC，0表示false，1表示true，为true时：用户点击外部遮罩层页面可以消失，注意：该参数在弹窗隐藏后，还原为弹窗弹起时的值
    @objc open var touchWildToHide: String?
    
    /// 显示、隐藏动画所需的时间
    @objc open var animationDuration: TimeInterval = 0.2
    /// 阻尼系数，范围：0.0f~1.0f，数值越小「弹簧」的振动效果越明显。默认：-1，表示没有「弹簧」效果
    @objc open var usingSpringWithDamping: CGFloat = -1
    /// 初始速率，数值越大一开始移动越快，默认为：5
    @objc open var initialSpringVelocity: CGFloat = 5
    
    /// 3D放射动画（当且仅当：popupAnimationType == .scale3D 时有效）
    @objc open var transform3D: CATransform3D = CATransform3DMakeScale(1.2, 1.2, 1.0)
    /// 2D放射动画
    @objc open var transform: CGAffineTransform                     = CGAffineTransform(scaleX: 0.001, y: 0.001)
    
    
    public override init() {
        super.init()
        
        self.reSetParams()
    }
    
    /// 如果发现部分属性设置后没有生效，可执行该方法
    @objc public func reSetParams() {
        
    }
}
