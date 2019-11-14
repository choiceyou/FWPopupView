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
/// - circular: 圆形，默认。注意：相同大小的视图，正方形看起来会比圆形大
/// - rectangle: 正方形，可设置圆角值。注意：相同大小的视图，正方形看起来会比圆形大
/// - image: 图片类型
@objc public enum FWRadioButtonType: Int {
    case circular
    case rectangle
    case image
}

/// 确定回调
public typealias FWRadioButtonClickedBlock = (_ isSelected: Bool) -> Void


open class FWRadioButton : UIView {
    
    /// 可设置参数
    @objc public var vProperty : FWRadioButtonProperty!
    /// true：选中 false：未选中
    @objc public var isSelected : Bool = false {
        willSet {
            self.changeSelection(selected: newValue)
        }
    }
    
    lazy var borderLayer: CAShapeLayer = {
        
        let borderLayer = CAShapeLayer()
        self.layer.addSublayer(borderLayer)
        borderLayer.lineWidth = self.vProperty.lineWidth
        borderLayer.fillColor = UIColor.clear.cgColor
        return borderLayer
    }()
    
    lazy var insideLayer: CAShapeLayer = {
        
        let insideLayer = CAShapeLayer()
        self.layer.addSublayer(insideLayer)
        insideLayer.lineWidth = 0
        insideLayer.fillColor = self.vProperty.selectedStateColor.cgColor
        insideLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return insideLayer
    }()
    
    lazy var radioImageView: UIImageView = {
        
        let imageView = UIImageView()
        self.addSubview(imageView)
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        
        let titleLabel = UILabel()
        self.addSubview(titleLabel)
        return titleLabel
    }()
    
    private var isAnimating : Bool = false {
        willSet {
            if newValue == true {
                self.isUserInteractionEnabled = false
            } else {
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    private var currentButtonType: FWRadioButtonType = .circular
    private var clickedBlock: FWRadioButtonClickedBlock?
    
    
    /// 初始化方法1：不显示标题
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - buttonType: 类型
    ///   - property: 单选按钮的相关配置属性
    ///   - clickedBlock: 单击回调
    /// - Returns: self
    @objc open class func radio(frame: CGRect, buttonType : FWRadioButtonType, property : FWRadioButtonProperty?, clickedBlock: FWRadioButtonClickedBlock? = nil) -> FWRadioButton {
        
        let radio = FWRadioButton()
        radio.setupUI(frame: frame, buttonType : buttonType, title: nil, selectedImage: nil, unSelectedImage: nil, property: property, clickedBlock: clickedBlock)
        return radio
    }
    
    /// 初始化方法2：可设置标题，可传入图片
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - buttonType: 类型
    ///   - title: 标题，为nil或者空字符串时不显示
    ///   - selectedImage: 选中图片
    ///   - unSelectedImage: 未选中的图片
    ///   - property: 单选按钮的相关配置属性
    ///   - clickedBlock: 单击回调
    /// - Returns: self
    @objc open class func radio(frame: CGRect, buttonType : FWRadioButtonType, title: String?, selectedImage: UIImage?, unSelectedImage: UIImage?, property : FWRadioButtonProperty?, clickedBlock: FWRadioButtonClickedBlock? = nil) -> FWRadioButton {
        
        let radio = FWRadioButton()
        radio.setupUI(frame: frame, buttonType : buttonType, title: title, selectedImage: selectedImage, unSelectedImage: unSelectedImage, property: property, clickedBlock: clickedBlock)
        return radio
    }
}

extension FWRadioButton {
    
    private func setupUI(frame: CGRect, buttonType : FWRadioButtonType, title: String?, selectedImage: UIImage?, unSelectedImage: UIImage?, property: FWRadioButtonProperty?, clickedBlock: FWRadioButtonClickedBlock? = nil) {
        
        self.frame = frame
        
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        
        self.currentButtonType = buttonType
        self.clickedBlock = clickedBlock
        
        if property != nil {
            self.vProperty = property
        } else {
            self.vProperty = FWRadioButtonProperty()
        }
        
        if selectedImage != nil {
            self.vProperty.selectedImage = selectedImage
        }
        if unSelectedImage != nil  {
            self.vProperty.unSelectedImage = unSelectedImage
        }
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(tapGesClick(tap:)))
        self.addGestureRecognizer(tapGest)
        
        var radioWidthHieght: CGFloat = 0.0
        if title != nil && !title!.isEmpty {
            let tmpWidth = self.frame.height-self.vProperty.radioViewEdgeInsets.left-self.vProperty.radioViewEdgeInsets.right
            let tmpHeight = self.frame.height-self.vProperty.radioViewEdgeInsets.top-self.vProperty.radioViewEdgeInsets.bottom
            if tmpWidth <= 0 {
                radioWidthHieght = tmpHeight
            } else if tmpHeight <= 0 {
                radioWidthHieght = tmpWidth
            } else {
                radioWidthHieght = min(tmpWidth, tmpHeight)
            }
        } else {
            let tmpWidth = self.frame.width-self.vProperty.radioViewEdgeInsets.left-self.vProperty.radioViewEdgeInsets.right
            let tmpHeight = self.frame.height-self.vProperty.radioViewEdgeInsets.top-self.vProperty.radioViewEdgeInsets.bottom
            if tmpWidth <= 0 {
                radioWidthHieght = tmpHeight
            } else if tmpHeight <= 0 {
                radioWidthHieght = tmpWidth
            } else {
                radioWidthHieght = min(tmpWidth, tmpHeight)
            }
        }
        let radioFrame = CGRect(x: self.vProperty.radioViewEdgeInsets.left, y: (frame.height - radioWidthHieght)/2, width: radioWidthHieght, height: radioWidthHieght)
        
        if self.currentButtonType == .image {
            self.radioImageView.frame = radioFrame
            self.isSelected = self.vProperty.isSelected
        } else {
            self.drawBorder(radioFrame)
            self.drawInside(radioFrame)
            if self.vProperty.isSelected == true {
                self.isSelected = self.vProperty.isSelected
            }
        }
        
        if title != nil && !title!.isEmpty {
            self.titleLabel.font = self.vProperty.titleFont
            self.titleLabel.textColor = self.vProperty.titleColor
            self.titleLabel.text = title
            self.titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self).offset(radioFrame.width + self.vProperty.radioViewEdgeInsets.left + self.vProperty.radioViewEdgeInsets.right)
                make.top.bottom.right.equalTo(self)
            }
        }
    }
    
    /// 点击手势
    ///
    /// - Parameter tap: 手势
    @objc private func tapGesClick(tap: UITapGestureRecognizer) {
        
        if self.isAnimating == false {
            self.isSelected = !self.isSelected
        }
        if self.clickedBlock != nil {
            self.clickedBlock!(self.isSelected)
        }
    }
    
    /// 切换
    ///
    /// - Parameter selected: true：选中
    private func changeSelection(selected: Bool) {
        
        if self.currentButtonType == .image {
            if self.vProperty.selectedImage != nil && self.vProperty.unSelectedImage != nil {
                self.radioImageView.image = selected ? self.vProperty.selectedImage : self.vProperty.unSelectedImage
            } else {
                let url = Bundle(for: FWCustomSheetView.self).url(forResource: "FWPopupView", withExtension: "bundle")
                if url != nil {
                    let imageBundle = Bundle(url: url!)
                    let path = imageBundle?.path(forResource: selected ? "rb_seleted@2x" : "rb_not_seleted@2x", ofType: "png")
                    if path != nil {
                        self.radioImageView.image = UIImage(contentsOfFile: path!)
                    }
                }
            }
        } else {
            if self.vProperty.isBorderColorNeedChanged {
                self.borderLayer.strokeColor = selected ? self.vProperty.selectedStateColor.cgColor : self.vProperty.normalStateColor.cgColor
            }
            
            if self.vProperty.isAnimated && self.vProperty.animationDuration > 0 {
                let scaleValue = NSNumber(value: ((self.isSelected == true) ? 0 : 1))
                let fromValue = NSNumber(value: ((self.isSelected == true) ? 1 : 0))
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.fromValue = fromValue
                animation.toValue = scaleValue
                animation.duration = self.vProperty.animationDuration
                animation.fillMode = CAMediaTimingFillMode.forwards
                animation.isRemovedOnCompletion = false
                self.insideLayer.add(animation, forKey: selected ? "scale" : "scale2")
                self.isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now()+self.vProperty.animationDuration) {
                    self.isAnimating = false
                }
            } else {
                if selected {
                    self.insideLayer.isHidden = false
                } else {
                    self.insideLayer.isHidden = true
                }
            }
        }
    }
    
    /// 绘制非图片类型的边框
    ///
    /// - Parameter rect: frame
    private func drawBorder(_ rect: CGRect) {
        
        // 边框
        var borderPath : UIBezierPath!
        
        switch self.currentButtonType {
        case .circular:
            let center = CGPoint(x: rect.width/2, y: rect.height/2)
            borderPath = UIBezierPath(arcCenter: center, radius: rect.width*0.5-self.vProperty.lineWidth, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            break
        case .rectangle:
            borderPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
            break
            
        default: break
            
        }
        
        self.borderLayer.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
        self.borderLayer.strokeColor = self.vProperty.normalStateColor.cgColor
        self.borderLayer.path = borderPath.cgPath
    }
    
    /// 绘制非图片类型的内部选中状态
    ///
    /// - Parameter rect: frame
    private func drawInside(_ rect: CGRect) {
        
        // 选中
        var insideLayerWidthAndHeight: CGFloat = 0.0
        if self.currentButtonType == .circular {
            insideLayerWidthAndHeight = ((rect.height - self.vProperty.lineWidth*2) * self.vProperty.insideMarginRate)
        } else {
            insideLayerWidthAndHeight = ((rect.height - self.vProperty.lineWidth) * self.vProperty.insideMarginRate)
        }
        let insidePathFrame = CGRect(x: 0, y: 0, width: insideLayerWidthAndHeight, height: insideLayerWidthAndHeight)
        
        var insidePath : UIBezierPath!
        
        switch self.currentButtonType {
        case .circular:
            insidePath = UIBezierPath(ovalIn: insidePathFrame)
            break
        case .rectangle:
            insidePath = UIBezierPath(rect: insidePathFrame)
            break
            
        default: break
            
        }

        self.insideLayer.frame = CGRect(x: rect.origin.x + (rect.width-insideLayerWidthAndHeight)/2, y: rect.origin.y + (rect.height-insideLayerWidthAndHeight)/2, width: insideLayerWidthAndHeight, height: insideLayerWidthAndHeight)
        self.insideLayer.path = insidePath.cgPath
        
        if !isSelected {
            if self.vProperty.isAnimated && self.vProperty.animationDuration > 0 {
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.fromValue = NSNumber(value: 1.0)
                animation.toValue = NSNumber(value: 0.0)
                animation.duration = 0.01
                animation.fillMode = CAMediaTimingFillMode.forwards
                animation.isRemovedOnCompletion = false
                self.insideLayer.add(animation, forKey: "tscale")
            } else {
                self.insideLayer.isHidden = true
            }
        }
    }
}



// MARK: - 单选按钮的相关配置属性
open class FWRadioButtonProperty: NSObject {
    
    /// 是否默认选中
    @objc public var isSelected : Bool = false
    /// 是否需要动画
    @objc public var isAnimated : Bool = true
    /// 动画所需的时间
    @objc open var animationDuration: TimeInterval = 0.2
    /// 偏移量。当视图比较小时会出现不好点击的问题，此时可以把视图frame值设置大一些，同时配合该属性，既可以达到想要的效果，也可以增大点击的接触面积
    @objc open var radioViewEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /// 标题字体大小
    @objc open var titleFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    /// 标题文字颜色
    @objc open var titleColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    
    
    // ------------ 以下属性为：buttonType == .circular | .rectangle 时有效 ------------
    /// 未选中时的颜色
    @objc open var normalStateColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    /// 选中时的颜色
    @objc open var selectedStateColor: UIColor = kPV_RGBA(r: 51, g: 51, b: 51, a: 1)
    /// 边框颜色是否需要跟随选中颜色
    @objc public var isBorderColorNeedChanged : Bool = true
    /// 边的宽度
    @objc public var lineWidth: CGFloat = 2
    /// 内部选中状态的宽度与内边框的比例
    @objc public var insideMarginRate: CGFloat = 0.6
    
    
    // ------------ 以下属性为：buttonType == .image 时有效 ------------
    /// 选中图片
    @objc public var selectedImage: UIImage?
    /// 未选中图片
    @objc public var unSelectedImage: UIImage?
    
    
    public override init() {
        super.init()
        
        self.reSetParams()
    }
    
    /// 如果发现部分属性设置后没有生效，可执行该方法
    @objc public func reSetParams() {
        
    }
}
