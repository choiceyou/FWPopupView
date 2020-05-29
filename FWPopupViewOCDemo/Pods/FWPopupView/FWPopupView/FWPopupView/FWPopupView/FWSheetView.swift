//
//  FWSheetView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/26.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

open class FWSheetView: FWPopupView {
    
    private var actionItemArray: [FWPopupItem] = []
    
    private var titleLabel: UILabel?
    private var titleContainerView: UIView?
    
    private var commponenetArray: [UIView] = []
    
    /// 类初始化方法1
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - itemTitles: 点击项标题
    ///   - itemBlock: 点击回调
    ///   - cancenlBlock: 取消按钮回调（单词拼错了，将错就错吧，哈哈）
    /// - Returns: self
    @objc open class func sheet(title: String?, itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, cancenlBlock: FWPopupVoidBlock? = nil) -> FWSheetView {
        
        return self.sheet(title: title, itemTitles: itemTitles, itemBlock: itemBlock, cancenlBlock: cancenlBlock, property: nil)
    }
    
    /// 类初始化方法2：可设置Sheet相关属性
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - itemTitles: 点击项标题
    ///   - itemBlock: 点击回调
    ///   - cancenlBlock: 取消按钮回调
    ///   - property: FWSheetView的相关属性
    /// - Returns: self
    @objc open class func sheet(title: String?, itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, cancenlBlock: FWPopupVoidBlock? = nil, property: FWSheetViewProperty?) -> FWSheetView {
        
        return self.sheet(title: title, itemTitles: itemTitles, itemBlock: itemBlock, cancelItemTitle: nil, cancenlBlock: cancenlBlock, property: property)
    }
    
    /// 类初始化方法3：可设置Sheet相关属性
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - itemTitles: 点击项标题
    ///   - itemBlock: 点击回调
    ///   - cancelItemTitle: 取消按钮的名称
    ///   - cancenlBlock: 取消按钮回调
    ///   - property: FWSheetView的相关属性
    /// - Returns: self
    @objc open class func sheet(title: String?, itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, cancelItemTitle: String?, cancenlBlock: FWPopupVoidBlock? = nil, property: FWSheetViewProperty?) -> FWSheetView {
        
        let sheetView = FWSheetView()
        sheetView.setupUI(title: title, itemTitles: itemTitles, itemBlock:itemBlock, cancelItemTitle: cancelItemTitle, cancenlBlock: cancenlBlock, property: property)
        return sheetView
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.vProperty = FWSheetViewProperty()
        self.backgroundColor = self.vProperty.backgroundColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FWSheetView {
    
    private func setupUI(title: String?, itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, cancelItemTitle: String?, cancenlBlock: FWPopupVoidBlock? = nil, property: FWSheetViewProperty?) {
        
        if property != nil {
            self.vProperty = property!
        }
        
        let itemClickedBlock: FWPopupItemClickedBlock = { (popupView, index, title) in
            if itemBlock != nil {
                itemBlock!(self, index, title)
            }
        }
        for title in itemTitles {
            self.actionItemArray.append(FWPopupItem(title: title, itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: itemClickedBlock))
        }
        
        self.clipsToBounds = true
        self.isNotMakeSize = true
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        let property = self.vProperty as! FWSheetViewProperty
        
        property.popupCustomAlignment = .bottomCenter
        property.popupAnimationType = .position
        
        var lastConstraintItem = self.snp.top
        
        if title != nil && !title!.isEmpty {
            
            self.titleContainerView = UIView()
            self.addSubview(self.titleContainerView!)
            self.titleContainerView?.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
            })
            self.titleContainerView?.backgroundColor = UIColor.white
            
            self.titleLabel = UILabel()
            self.titleContainerView?.addSubview(self.titleLabel!)
            self.titleLabel?.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: round(self.vProperty.topBottomMargin*1.5), left: self.vProperty.letfRigthMargin, bottom: round(self.vProperty.topBottomMargin*1.5), right: self.vProperty.letfRigthMargin))
            })
            self.titleLabel?.text = title
            self.titleLabel?.textColor = self.vProperty.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = (self.vProperty.titleFont != nil) ? self.vProperty.titleFont! : UIFont.systemFont(ofSize: self.vProperty.titleFontSize)
            self.titleLabel?.numberOfLines = 10
            self.titleLabel?.backgroundColor = UIColor.clear
            
            self.commponenetArray.append(self.titleLabel!)
            
            lastConstraintItem = self.titleContainerView!.snp.bottom
        }
        
        // 开始配置Item
        let btnContrainerView = UIScrollView()
        self.addSubview(btnContrainerView)
        btnContrainerView.bounces = false
        btnContrainerView.backgroundColor = UIColor.clear
        btnContrainerView.snp.makeConstraints { (make) in
            make.top.equalTo(lastConstraintItem)
            make.left.right.equalTo(self)
        }
        
        let block: FWPopupItemClickedBlock = { (popupView, index, title) in
            if cancenlBlock != nil {
                cancenlBlock!()
            }
        }
        
        self.actionItemArray.append(FWPopupItem(title: (cancelItemTitle != nil) ? cancelItemTitle! : property.cancelItemTitle, itemType: .normal, isCancel: true, canAutoHide: true, itemTitleColor: property.cancelItemTitleColor, itemTitleFont: property.cancelItemTitleFont, itemBackgroundColor: property.cancelItemBackgroundColor, itemClickedBlock: block))
        
        var tmpIndex = 0
        var lastBtn: UIButton!
        var cancelBtn: UIButton!
        
        for popupItem: FWPopupItem in self.actionItemArray {
            
            let btn = UIButton(type: .custom)
            if tmpIndex == self.actionItemArray.count - 1 {
                self.addSubview(btn)
                cancelBtn = btn
            } else {
                btnContrainerView.addSubview(btn)
            }
            
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btn.tag = tmpIndex
            
            btn.snp.makeConstraints { (make) in
                make.left.right.equalTo(btnContrainerView).inset(UIEdgeInsets(top: 0, left: -self.vProperty.splitWidth, bottom: 0, right: -self.vProperty.splitWidth))
                make.height.equalTo(property.buttonHeight + property.splitWidth)
                make.width.equalTo(btnContrainerView).offset(property.splitWidth*2)
                if tmpIndex == 0 {
                    make.top.equalToSuperview()
                    lastBtn = btn
                } else if tmpIndex > 0 && tmpIndex < self.actionItemArray.count - 1 {
                    make.top.equalTo(lastBtn.snp.bottom).offset(-self.vProperty.splitWidth)
                    lastBtn = btn
                }
            }
            // 按钮标题
            btn.setTitle(popupItem.title, for: .normal)
            // 按钮标题字体颜色
            if popupItem.itemTitleColor != nil {
                btn.setTitleColor(popupItem.itemTitleColor, for: .normal)
            } else {
                btn.setTitleColor(popupItem.highlight ? self.vProperty.itemHighlightColor : self.vProperty.itemNormalColor, for: .normal)
            }
            // 按钮标题字体大小
            if popupItem.itemTitleFont != nil {
                btn.titleLabel?.font = popupItem.itemTitleFont
            } else {
                btn.titleLabel?.font = (self.vProperty.buttonFont != nil) ? self.vProperty.buttonFont! : UIFont.systemFont(ofSize: self.vProperty.buttonFontSize)
            }
            // 按钮背景颜色
            if popupItem.itemBackgroundColor != nil {
                btn.setBackgroundImage(self.getImageWithColor(color: popupItem.itemBackgroundColor!), for: .normal)
            } else {
                btn.setBackgroundImage(self.getImageWithColor(color: UIColor.white), for: .normal)
            }
            // 按钮选中高亮颜色
            btn.setBackgroundImage(self.getImageWithColor(color: self.vProperty.itemPressedColor), for: .highlighted)
            
            btn.layer.borderWidth = self.vProperty.splitWidth
            btn.layer.borderColor = self.vProperty.splitColor.cgColor
            
            tmpIndex += 1
        }
        
        btnContrainerView.snp.makeConstraints { (make) in
            var tmpHeight: CGFloat = property.buttonHeight * CGFloat(self.actionItemArray.count-1)
            if self.vProperty.popupViewMaxHeightRate > 0 && self.superview != nil && self.superview!.frame.height > 0 {
                tmpHeight = min(tmpHeight, self.superview!.frame.height * self.vProperty.popupViewMaxHeightRate)
            }
            make.height.equalTo(tmpHeight)
            make.bottom.equalTo(lastBtn.snp.bottom).offset(-self.vProperty.splitWidth)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.top.equalTo(btnContrainerView.snp.bottom).offset(property.cancelBtnMarginTop)
        }
        
        self.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(cancelBtn.snp.bottom).inset(-FWPopupSWindow.sharedInstance.safeAreaInsets.bottom)
            } else {
                make.bottom.equalTo(cancelBtn.snp.bottom)
            }
        }
    }
}

extension FWSheetView {
    
    @objc private func btnAction(_ sender: Any) {
        
        let btn = sender as! UIButton
        let item = self.actionItemArray[btn.tag]
        if item.disabled {
            return
        }
        
        if item.canAutoHide {
            self.hide()
        }
        
        if item.itemClickedBlock != nil {
            item.itemClickedBlock!(self, btn.tag, item.title)
        }
    }
}

/// FWSheetView的相关属性，请注意其父类中还有很多公共属性
open class FWSheetViewProperty: FWPopupViewProperty {
    
    // 取消按钮距离头部的距离
    @objc public var cancelBtnMarginTop: CGFloat = 6
    // 取消按钮名称
    @objc public var cancelItemTitle = "取消"
    // 取消按钮字体颜色
    @objc public var cancelItemTitleColor: UIColor?
    // 取消按钮字体大小
    @objc public var cancelItemTitleFont: UIFont?
    // 取消按钮背景颜色
    @objc public var cancelItemBackgroundColor: UIColor?
    
    public override func reSetParams() {
        super.reSetParams()
        
        self.backgroundColor = kPV_RGBA(r: 230, g: 230, b: 230, a: 1)
    }
}
