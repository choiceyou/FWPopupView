//
//  FWRadioButton.swift
//  FWPopupView
//
//  Created by xfg on 2018/10/10.
//  Copyright © 2018年 xfg. All rights reserved.
//  单选按钮

import Foundation
import UIKit

/// 类型
///
/// - circular: 圆形，默认
/// - rectangle: 正方形，可设置圆角值
/// - image: 图片类型
@objc public enum FWRadioButtonType: Int {
    case circular
    case rectangle
    case image
}

open class FWRadioButton : UIView {
    
    @objc public var vProperty : FWRadioButtonProperty!
    
    private var borderLayer: CAShapeLayer?
    private var insideLayer: CAShapeLayer?
    
    @objc public var isSelected : Bool = false {
        willSet {
            if self.vProperty.buttonType == .image {
                self.drawWithSelection(selected: newValue)
            } else {
                self.setNeedsDisplay()
            }
        }
    }
    
    @objc open class func radio(frame: CGRect, property : FWRadioButtonProperty) -> FWRadioButton {
        
        let radio = FWRadioButton()
        radio.setupUI(frame: frame, property: property)
        return radio
    }
}

extension FWRadioButton {
    
    private func setupUI(frame: CGRect, property: FWRadioButtonProperty?) {
        
        self.frame = frame
        self.backgroundColor = UIColor.clear
        
        if property != nil {
            self.vProperty = property
        } else {
            self.vProperty = FWRadioButtonProperty()
        }
        
        self.isUserInteractionEnabled = true
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(tapGesClick(tap:)))
        self.addGestureRecognizer(tapGest)
    }
    
    /// 点击手势
    ///
    /// - Parameter tap: 手势
    @objc private func tapGesClick(tap: UITapGestureRecognizer) {
        
        self.isSelected = !self.isSelected
    }
    
    /// 图片类型的切换
    ///
    /// - Parameter selected: true：选中
    private func drawWithSelection(selected: Bool) {
        
        if selected {
            
        } else {
            
        }
    }
    
    /// 除图片类型外的绘制过程
    ///
    /// - Parameter rect: rect
    open override func draw(_ rect: CGRect) {
        
        if self.borderLayer != nil {
            self.borderLayer?.removeFromSuperlayer()
        }
        if self.insideLayer != nil {
            self.insideLayer?.removeFromSuperlayer()
        }
        
        self.drawBorder(rect)
        if self.isSelected {
            self.drawInside(rect)
        }
        
        if self.vProperty.isAnimated && self.vProperty.animationDuration > 0 {
            self.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now()+self.vProperty.animationDuration) {
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    /// 绘制边框
    ///
    /// - Parameter rect: frame
    private func drawBorder(_ rect: CGRect) {
        
        // 边框
        let center = CGPoint(x: rect.width/2, y: rect.height/2)
        var borderPath : UIBezierPath!
        
        switch self.vProperty.buttonType {
        case .circular:
            borderPath = UIBezierPath(arcCenter: center, radius: rect.width*0.5-self.vProperty.lineWidth, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            break
        case .rectangle:
            borderPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rect.width-self.vProperty.lineWidth, height: rect.height-self.vProperty.lineWidth))
            break
            
        default: break
            
        }
        
        self.borderLayer = CAShapeLayer()
        self.layer.addSublayer(self.borderLayer!)
        self.borderLayer!.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        self.borderLayer!.path = borderPath.cgPath
        self.borderLayer!.lineWidth = self.vProperty.lineWidth
        self.borderLayer!.strokeColor = self.isSelected ? self.vProperty.selectedStateColor.cgColor : self.vProperty.normalStateColor.cgColor
        self.borderLayer!.fillColor = UIColor.clear.cgColor
    }
    
    /// 绘制内部选中状态
    ///
    /// - Parameter rect: frame
    private func drawInside(_ rect: CGRect) {
        
        // 选中
        let width = floor((rect.width - self.vProperty.lineWidth*2) * self.vProperty.insideMarginRate)
        
        var insidePath : UIBezierPath!
        
        switch self.vProperty.buttonType {
        case .circular:
            insidePath = UIBezierPath(ovalIn: CGRect(x: (self.frame.width-width)/2, y: (self.frame.width-width)/2, width: width, height: width))
            break
        case .rectangle:
            let ipWidth = (rect.width-self.vProperty.lineWidth)*self.vProperty.insideMarginRate
            let ipHeight = (rect.height-self.vProperty.lineWidth)*self.vProperty.insideMarginRate
            
            insidePath = UIBezierPath(rect: CGRect(x: (rect.width-ipWidth-self.vProperty.lineWidth)/2, y: (rect.height-ipHeight-self.vProperty.lineWidth)/2, width: ipWidth, height: ipHeight))
            break
            
        default: break
            
        }

        self.insideLayer = CAShapeLayer()
        self.layer.addSublayer(self.insideLayer!)
        self.insideLayer!.frame = CGRect(x: 0, y: 0, width: width, height: width)
        self.insideLayer!.path = insidePath.cgPath
        self.insideLayer!.lineWidth = 0
        self.insideLayer!.fillColor = self.vProperty.selectedStateColor.cgColor
        
        let scaleValue = NSNumber(value: ((self.isSelected) ? 1 : 0))
        if self.isSelected && self.vProperty.isAnimated {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = scaleValue
            animation.duration = self.vProperty.animationDuration
            self.insideLayer?.add(animation, forKey: "scale")
        }
        self.insideLayer?.transform = CATransform3DMakeScale(CGFloat(scaleValue.floatValue), CGFloat(scaleValue.floatValue), 0)
    }
}



// MARK: - 单选按钮的相关配置属性
open class FWRadioButtonProperty: NSObject {
    
    /// 未选中时的颜色
    @objc open var normalStateColor: UIColor        = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    /// 选中时的颜色
    @objc open var selectedStateColor: UIColor      = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    
    /// 按钮类型
    @objc open var buttonType : FWRadioButtonType   = .circular
    /// 是否需要动画
    @objc public var isAnimated : Bool              = true
    /// 动画所需的时间
    @objc open var animationDuration: TimeInterval  = 0.2
    
    /// 圆角值，注意：当 buttonType == .circular 时无效
    @objc public var radius: CGFloat                = 0
    /// 边的宽度
    @objc public var lineWidth: CGFloat             = 2
    
    /// 内部选中状态的宽度与内边框的比例
    @objc public var insideMarginRate: CGFloat      = 0.6
    
    
    public override init() {
        super.init()
        
        self.reSetParams()
    }
    
    /// 如果发现部分属性设置后没有生效，可执行该方法
    @objc public func reSetParams() {
        
    }
}
