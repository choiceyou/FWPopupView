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

/// 自定义弹窗校准位置，注意：这边设置靠置哪边动画就从哪边出来
///
/// - center: 中间，默认值
/// - top: 上
/// - left: 左
/// - bottom: 下
/// - right: 右
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
    case top
    case left
    case bottom
    case right
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

/// 显示、隐藏回调
public typealias FWPopupBlock = (_ popupView: FWPopupView) -> Void
/// 显示、隐藏完成回调，某些场景下可能会用到 isShow ==》true: 显示 false：隐藏
public typealias FWPopupCompletionBlock = (_ popupView: FWPopupView, _ isShow: Bool) -> Void
/// 普通无参数回调
public typealias FWPopupVoidBlock = () -> Void

/// 隐藏所有弹窗的通知
let FWPopupViewHideAllNotification = "FWPopupViewHideAllNotification"


open class FWPopupView: UIView, UIGestureRecognizerDelegate {
    
    /// 单击隐藏
    private var tapGest: UITapGestureRecognizer?
    
    /// 1、当外部没有传入该参数时，默认为UIWindow的根控制器的视图，即表示弹窗放在FWPopupWindow上，此时若FWPopupWindow.sharedInstance.touchWildToHide = true表示弹窗视图外部可点击；2、当外部传入该参数时，该视图为传入的UIView，即表示弹窗放在传入的UIView上；
    @objc public var attachedView = FWPopupWindow.sharedInstance.attachView() {
        willSet {
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
    
    
    private var popupCompletionBlock: FWPopupCompletionBlock?
    
    private var showAnimation: FWPopupBlock?
    
    private var hideAnimation: FWPopupBlock?
    
    /// 记录遮罩层设置前的颜色
    internal var originMaskViewColor: UIColor!
    /// 记录遮罩层设置前的是否可点击
    internal var originTouchWildToHide: Bool!
    /// 遮罩层为UIScrollView或其子类时，记录是否可以滚动
    internal var originScrollEnabled: Bool?
    /// 记录弹窗弹起前keywindow
    internal var originKeyWindow: UIWindow?
    
    /// 当前frame值是否被设置过了
    private var haveSetFrame: Bool = false
    /// 弹窗真正的frame
    private var finalFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
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
        
        FWPopupWindow.sharedInstance.backgroundColor = UIColor.clear
        
        self.originMaskViewColor = self.attachedView?.fwMaskViewColor
        self.originTouchWildToHide = FWPopupWindow.sharedInstance.touchWildToHide
        
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
        
        self.show(completionBlock: nil)
    }
    
    /// 显示
    ///
    /// - Parameter completionBlock: 显示、隐藏回调
    @objc open func show(completionBlock: FWPopupCompletionBlock? = nil) {
        
        // 弹起时设置相关参数，因为隐藏或者销毁时会被重置掉，所以每次弹起时都重新调用
        if self.attachedView != nil && self.vProperty.maskViewColor != nil {
            self.attachedView?.fwMaskViewColor = self.vProperty.maskViewColor!
        }
        self.originKeyWindow = UIApplication.shared.keyWindow;
        if self.vProperty.touchWildToHide != nil && !self.vProperty.touchWildToHide!.isEmpty {
            FWPopupWindow.sharedInstance.touchWildToHide = (Int(self.vProperty.touchWildToHide!) == 1) ? true : false
        }
        self.attachedView?.fwAnimationDuration = self.vProperty.animationDuration
        
        if self.attachedView != nil && self.attachedView != FWPopupWindow.sharedInstance.attachView() {
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
    
    /// 隐藏
    @objc open func hide() {
        
        self.hide(completionBlock: nil)
    }
    
    /// 隐藏
    ///
    /// - Parameter completionBlock: 显示、隐藏回调
    @objc open func hide(completionBlock: FWPopupCompletionBlock? = nil) {
        
        self.attachedView?.fwAnimationDuration = self.vProperty.animationDuration
        
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
        
        if self.tapGest != nil && self.attachedView != nil {
            self.tapGest?.isEnabled = false
        }
        
        // 还原弹窗弹起时的相关参数
        self.attachedView?.fwMaskViewColor = self.originMaskViewColor
        FWPopupWindow.sharedInstance.touchWildToHide = self.originTouchWildToHide
        if self.attachedView!.isKind(of: UIScrollView.self) && self.originScrollEnabled != nil {
            (self.attachedView! as! UIScrollView).isScrollEnabled = self.originScrollEnabled!
        }
        if self.originKeyWindow != nil {
            self.originKeyWindow!.becomeKey()
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
        return FWPopupWindow.sharedInstance.isHidden
    }
}

// MARK: - 动画事件
extension FWPopupView {

    private func customShowAnimation() -> FWPopupBlock {
        
        let popupBlock = { [weak self] (popupView: FWPopupView) in
            
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.superview == nil {
                // 保证前一次弹窗销毁完毕
                for view in strongSelf.attachedView!.fwMaskView.subviews {
                    view.removeFromSuperview()
                }
                strongSelf.attachedView?.fwMaskView.addSubview(strongSelf)
                
                strongSelf.setupFrame()
                
                switch strongSelf.vProperty.popupAnimationType {
                case .position: // 位移动画
                    let baseAnimation = CABasicAnimation(keyPath: "position")
                    
                    switch strongSelf.vProperty.popupCustomAlignment {
                    case .top, .topCenter, .topLeft, .topRight, .center:
                        baseAnimation.fromValue = NSValue(cgPoint: CGPoint(x: strongSelf.frame.origin.x + strongSelf.frame.width/2, y: strongSelf.frame.origin.y - strongSelf.frame.height/2))
                        break
                    case .left, .leftCenter:
                        baseAnimation.fromValue = NSValue(cgPoint: CGPoint(x: strongSelf.frame.origin.x - strongSelf.frame.width/2, y: strongSelf.frame.origin.y + strongSelf.frame.height/2))
                        break
                    case .bottom, .bottomCenter, .bottomLeft, .bottomRight:
                        baseAnimation.fromValue = NSValue(cgPoint: CGPoint(x: strongSelf.frame.origin.x + strongSelf.frame.width/2, y: strongSelf.attachedView!.frame.height + strongSelf.frame.height/2))
                        break
                    case .right, .rightCenter:
                        baseAnimation.fromValue = NSValue(cgPoint: CGPoint(x: strongSelf.attachedView!.frame.width + strongSelf.frame.width/2, y:strongSelf.frame.origin.y + strongSelf.frame.height/2))
                        break
                    }
                    
                    baseAnimation.toValue = NSValue(cgPoint: CGPoint(x: strongSelf.frame.origin.x + strongSelf.frame.width/2, y: strongSelf.frame.origin.y + strongSelf.frame.height/2))
                    baseAnimation.duration = strongSelf.vProperty.animationDuration
                    strongSelf.layer.add(baseAnimation, forKey: "positionAnimation")
                    break
                    
                case .scale, .scale3D: // 缩放动画/3D缩放动画
                    strongSelf.layer.anchorPoint = strongSelf.obtainAnchorPoint()
                    strongSelf.frame = strongSelf.finalFrame
                    if strongSelf.vProperty.popupAnimationType == .scale {
                        strongSelf.transform = strongSelf.vProperty.transform
                    } else {
                        strongSelf.layer.transform = strongSelf.vProperty.transform3D
                    }
                    break
                    
                case .frame: // 修改frame值的动画
                    switch strongSelf.vProperty.popupCustomAlignment {
                    case .top, .topCenter, .topLeft, .topRight, .center:
                        strongSelf.frame.size.height = 0
                        break
                    case .left, .leftCenter:
                        strongSelf.frame.size.width = 0
                        break
                    case .bottom, .bottomCenter, .bottomLeft, .bottomRight:
                        strongSelf.frame.origin.y = strongSelf.finalFrame.maxY
                        strongSelf.frame.size.height = 0
                        break
                    case .right, .rightCenter:
                        strongSelf.frame.origin.x = strongSelf.finalFrame.maxX
                        strongSelf.frame.size.width = 0
                        break
                    }
                    break
                }
                
                strongSelf.layoutIfNeeded()
                
                UIView.animate(withDuration: strongSelf.vProperty.animationDuration, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    
                    switch strongSelf.vProperty.popupAnimationType {
                    case .position: // 位移动画
                        break
                    case .scale: // 缩放动画
                        strongSelf.transform = CGAffineTransform.identity
                        break
                    case .scale3D: // 3D缩放动画
                        strongSelf.layer.transform = CATransform3DIdentity
                        break
                    case .frame: // 修改frame值的动画
                        strongSelf.frame = strongSelf.finalFrame
                        break
                    }
                    
                    strongSelf.superview?.layoutIfNeeded()
                    
                }, completion: { (finished) in
                    
                    if strongSelf.popupCompletionBlock != nil {
                        strongSelf.popupCompletionBlock!(strongSelf, true)
                    }
                    
                })
            }
        }
        
        return popupBlock
    }
    
    private func customHideAnimation() -> FWPopupBlock {
        
        let popupBlock:FWPopupBlock = { [weak self] popupView in
            
            guard let strongSelf = self else {
                return
            }
            
            let finalFrame = strongSelf.frame
            
            UIView.animate(withDuration: strongSelf.vProperty.animationDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                
                switch strongSelf.vProperty.popupAnimationType {
                case .position: // 位移动画
                    switch strongSelf.vProperty.popupCustomAlignment {
                    case .top, .topCenter, .topLeft, .topRight, .center:
                        strongSelf.frame.origin.y = -(strongSelf.frame.origin.y + strongSelf.frame.height)
                        break
                    case .left, .leftCenter:
                        strongSelf.frame.origin.x = -(strongSelf.frame.origin.x + strongSelf.frame.width)
                        break
                    case .bottom, .bottomCenter, .bottomLeft, .bottomRight:
                        strongSelf.frame.origin.y = strongSelf.attachedView!.frame.height
                        break
                    case .right, .rightCenter:
                        strongSelf.frame.origin.x = strongSelf.attachedView!.frame.width
                        break
                    }
                    break
                    
                case .scale, .scale3D: // 缩放动画/3D缩放动画
                    strongSelf.layer.anchorPoint = strongSelf.obtainAnchorPoint()
                    strongSelf.frame = finalFrame
                    strongSelf.transform = strongSelf.vProperty.transform
                    break
                    
                case .frame: // 修改frame值的动画
                    switch strongSelf.vProperty.popupCustomAlignment {
                    case .top, .topCenter, .topLeft, .topRight, .center:
                        strongSelf.frame.size.height = 0
                        break
                    case .left, .leftCenter:
                        strongSelf.frame.size.width = 0
                        break
                    case .bottom, .bottomCenter, .bottomLeft, .bottomRight:
                        strongSelf.frame.origin.y = finalFrame.maxY
                        strongSelf.frame.size.height = 0
                        break
                    case .right, .rightCenter:
                        strongSelf.frame.origin.x = finalFrame.maxX
                        strongSelf.frame.size.width = 0
                        break
                    }
                    break
                }
                
                strongSelf.superview?.layoutIfNeeded()
                
            }, completion: { (finished) in
                
                if finished {
                    strongSelf.removeFromSuperview()
                }
                if strongSelf.popupCompletionBlock != nil {
                    strongSelf.popupCompletionBlock!(strongSelf, false)
                }
                
                // 还原视图，防止下次动画时出错
                switch strongSelf.vProperty.popupAnimationType {
                case .frame, .position:
                    strongSelf.frame = strongSelf.finalFrame
                    break
                case .scale, .scale3D:
                    strongSelf.transform = CGAffineTransform.identity
                    break
                }
            })
        }
        
        return popupBlock
    }
    
    private func obtainAnchorPoint() -> CGPoint {
        
        if self.vProperty.popupArrowVertexScaleX > 1 {
            self.vProperty.popupArrowVertexScaleX = 1
        } else if self.vProperty.popupArrowVertexScaleX < 0 {
            self.vProperty.popupArrowVertexScaleX = 0
        }
        
        // 计算anchorPoint
        var tmpX: CGFloat = 0
        var tmpY: CGFloat = 0
        switch self.vProperty.popupCustomAlignment {
        case .center:
            tmpX = 0.5
            tmpY = 0.5
            break
        case .top, .topLeft, .topCenter, .topRight:
            if self.vProperty.popupArrowStyle == .none {
                tmpX = self.vProperty.popupArrowVertexScaleX
            } else {
                let arrowVertexX = (self.frame.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2
                tmpX = arrowVertexX / self.frame.width
            }
            tmpY = 0
            break
        case .left, .leftCenter:
            tmpX = 0
            tmpY = 0.5
            break
        case .right, .rightCenter:
            tmpX = 1
            tmpY = 0.5
            break
        default:
            if self.vProperty.popupArrowStyle == .none {
                tmpX = self.vProperty.popupArrowVertexScaleX
            } else {
                let arrowVertexX = (self.frame.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2
                tmpX = arrowVertexX / self.frame.width
            }
            tmpY = 1
            break
        }
        return CGPoint(x: tmpX, y: tmpY)
    }
    
    private func setupFrame() {
        if self.haveSetFrame == false {
            
            // 设置弹窗的frame
            switch self.vProperty.popupCustomAlignment {
            case .center:
                self.center = self.attachedView!.center
                self.frame.origin.x += self.vProperty.popupViewEdgeInsets.left - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y += self.vProperty.popupViewEdgeInsets.top - self.vProperty.popupViewEdgeInsets.bottom
                break
                
            case .top:
                self.frame.origin.x += self.vProperty.popupViewEdgeInsets.left - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y = self.vProperty.popupViewEdgeInsets.top
                break
            case .left:
                self.frame.origin.x = self.vProperty.popupViewEdgeInsets.left
                self.frame.origin.y += self.vProperty.popupViewEdgeInsets.top - self.vProperty.popupViewEdgeInsets.bottom
                break
            case .bottom:
                self.frame.origin.x += self.vProperty.popupViewEdgeInsets.left - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y = self.attachedView!.frame.height - self.frame.height - self.vProperty.popupViewEdgeInsets.bottom
                break
            case .right:
                self.frame.origin.x = self.attachedView!.frame.width - self.frame.width - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y += self.vProperty.popupViewEdgeInsets.top - self.vProperty.popupViewEdgeInsets.bottom
                break
                
            case .topCenter:
                self.frame.origin.x = (self.attachedView!.frame.width - self.frame.width) / 2 + self.vProperty.popupViewEdgeInsets.left - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y = self.vProperty.popupViewEdgeInsets.top
                break
            case .leftCenter:
                self.frame.origin.x = self.vProperty.popupViewEdgeInsets.left
                self.frame.origin.y = (self.attachedView!.frame.height - self.frame.height) / 2 + self.vProperty.popupViewEdgeInsets.top - self.vProperty.popupViewEdgeInsets.bottom
                break
            case .bottomCenter:
                self.frame.origin.x = (self.attachedView!.frame.width - self.frame.width) / 2 + self.vProperty.popupViewEdgeInsets.left - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y = self.attachedView!.frame.height - self.frame.height - self.vProperty.popupViewEdgeInsets.bottom
                break
            case .rightCenter:
                self.frame.origin.x = self.attachedView!.frame.width - self.frame.width - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y = (self.attachedView!.frame.height - self.frame.height) / 2 + self.vProperty.popupViewEdgeInsets.top - self.vProperty.popupViewEdgeInsets.bottom
                break
                
            case .topLeft:
                self.frame.origin.x = self.vProperty.popupViewEdgeInsets.left
                self.frame.origin.y = self.vProperty.popupViewEdgeInsets.top
                break
            case .topRight:
                self.frame.origin.x = self.attachedView!.frame.width - self.frame.width - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y = self.vProperty.popupViewEdgeInsets.top
                break
            case .bottomLeft:
                self.frame.origin.x = self.vProperty.popupViewEdgeInsets.left
                self.frame.origin.y = self.attachedView!.frame.height - self.frame.height - self.vProperty.popupViewEdgeInsets.bottom
                break
            case .bottomRight:
                self.frame.origin.x = self.attachedView!.frame.width - self.frame.width - self.vProperty.popupViewEdgeInsets.right
                self.frame.origin.y = self.attachedView!.frame.height - self.frame.height - self.vProperty.popupViewEdgeInsets.bottom
                break
            }
            
            self.finalFrame = self.frame
            
            self.haveSetFrame = true
        }
    }
}

// MARK: - 其他
extension FWPopupView {
    
    /// 点击隐藏
    ///
    /// - Parameter tap: 手势
    @objc func tapGesClick(tap: UITapGestureRecognizer) {
        
        if FWPopupWindow.sharedInstance.touchWildToHide && !self.fwBackgroundAnimating {
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


// MARK: - 弹窗的的相关配置属性
open class FWPopupViewProperty: NSObject {
    
    /// 标题字体大小
    @objc open var titleFontSize: CGFloat           = 18.0
    /// 标题文字颜色
    @objc open var titleColor: UIColor              = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    
    /// 按钮字体大小
    @objc open var buttonFontSize: CGFloat          = 17.0
    /// 按钮高度
    @objc open var buttonHeight: CGFloat            = 48.0
    /// 普通按钮文字颜色
    @objc open var itemNormalColor: UIColor         = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    /// 高亮按钮文字颜色
    @objc open var itemHighlightColor: UIColor      = kPV_RGBA(r: 254, g: 226, b: 4, a: 1)
    /// 选中按钮文字颜色
    @objc open var itemPressedColor: UIColor        = kPV_RGBA(r: 240, g: 240, b: 240, a: 1)
    
    /// 上下间距
    @objc open var topBottomMargin:CGFloat          = 10
    /// 左右间距
    @objc open var letfRigthMargin:CGFloat          = 10
    /// 控件之间的间距
    @objc open var commponentMargin:CGFloat         = 10
    
    /// 边框、分割线颜色
    @objc open var splitColor: UIColor              = kPV_RGBA(r: 231, g: 231, b: 231, a: 1)
    /// 边框宽度
    @objc open var splitWidth: CGFloat              = (1/UIScreen.main.scale)
    /// 圆角值
    @objc open var cornerRadius: CGFloat            = 5.0
    
    /// 弹窗的背景色（注意：这边指的是弹窗而不是遮罩层，遮罩层背景色的设置是：fwMaskViewColor）
    @objc open var backgroundColor: UIColor?
    /// 弹窗的最大高度，0：表示不限制
    @objc open var popupViewMaxHeight: CGFloat      = UIScreen.main.bounds.height * CGFloat(0.6)
    
    /// 弹窗箭头的样式
    @objc open var popupArrowStyle                  = FWMenuArrowStyle.none
    /// 弹窗箭头的尺寸
    @objc open var popupArrowSize                   = CGSize(width: 28, height: 12)
    /// 弹窗箭头的顶点的X值相对于弹窗的宽度，默认在弹窗X轴的一半，因此设置范围：0~1
    @objc open var popupArrowVertexScaleX: CGFloat  = 0.5
    /// 弹窗圆角箭头的圆角值
    @objc open var popupArrowCornerRadius: CGFloat  = 2.5
    /// 弹窗圆角箭头与边线交汇处的圆角值
    @objc open var popupArrowBottomCornerRadius: CGFloat  = 4.0
    
    
    // ===== 自定义弹窗（继承FWPopupView）时可能会用到 =====
    
    /// 弹窗校准位置
    @objc open var popupCustomAlignment: FWPopupCustomAlignment     = .center
    /// 弹窗动画类型
    @objc open var popupAnimationType: FWPopupAnimationType         = .position
    
    /// 弹窗偏移量
    @objc open var popupViewEdgeInsets                              = UIEdgeInsetsMake(0, 0, 0, 0)
    /// 遮罩层的背景色（也可以使用fwMaskViewColor），注意：该参数在弹窗隐藏后，还原为弹窗弹起时的值
    @objc open var maskViewColor: UIColor?
    /// 为了兼容OC，0表示false，1表示true，为true时：用户点击外部遮罩层页面可以消失，注意：该参数在弹窗隐藏后，还原为弹窗弹起时的值
    @objc open var touchWildToHide: String?
    
    /// 显示、隐藏动画所需的时间
    @objc open var animationDuration: TimeInterval                  = 0.2
    
    /// 3D放射动画（当且仅当：popupAnimationType == .scale3D 时有效）
    @objc open var transform3D: CATransform3D                       = CATransform3DMakeScale(1.2, 1.2, 1.0)
    /// 2D放射动画
    @objc open var transform: CGAffineTransform                     = CGAffineTransform(scaleX: 0.01, y: 0.01)
    
    
    public override init() {
        super.init()
        
        self.reSetParams()
    }
    
    /// 如果发现部分属性设置后没有生效，可执行该方法
    @objc public func reSetParams() {
        
    }
}
