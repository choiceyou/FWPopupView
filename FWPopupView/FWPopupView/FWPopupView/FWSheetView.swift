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
    
    private var commponenetArray: [UIView] = []
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - itemTitles: 点击项标题
    ///   - itemBlock: 点击回调
    ///   - cancenlBlock: 取消按钮回调
    /// - Returns: self
    @objc open class func sheet(title: String?, itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, cancenlBlock: FWPopupVoidBlock? = nil) -> FWSheetView {
        
        return self.sheet(title: title, itemTitles: itemTitles, itemBlock: itemBlock, cancenlBlock: cancenlBlock, property: nil)
    }
    
    /// 类初始化方法，可设置Sheet相关属性
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - itemTitles: 点击项标题
    ///   - itemBlock: 点击回调
    ///   - cancenlBlock: 取消按钮回调
    ///   - property: FWSheetView的相关属性
    /// - Returns: self
    @objc open class func sheet(title: String?, itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, cancenlBlock: FWPopupVoidBlock? = nil, property: FWSheetViewProperty?) -> FWSheetView {
        
        let sheetView = FWSheetView()
        sheetView.setupUI(title: title, itemTitles: itemTitles, itemBlock:itemBlock, cancenlBlock: cancenlBlock, property: property)
        return sheetView
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.vProperty = FWSheetViewProperty()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FWSheetView {
    
    private func setupUI(title: String?, itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, cancenlBlock: FWPopupVoidBlock? = nil, property: FWSheetViewProperty?) {
        
        if itemTitles.count == 0 {
            return
        }
        
        if property != nil {
            self.vProperty = property!
        }
        
        self.backgroundColor = self.vProperty.backgroundColor
        
        self.clipsToBounds = true
        
        self.popupType = .sheet
        self.animationDuration = 0.3
        
        let itemClickedBlock: FWPopupItemClickedBlock = { (popupView, index) in
            if itemBlock != nil {
                itemBlock!(self, index)
            }
        }
        for title in itemTitles {
            self.actionItemArray.append(FWPopupItem(title: title, itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: itemClickedBlock))
        }
        
        self.frame.origin.x = 0
        self.frame.origin.y = 100
        self.frame.size.width = UIScreen.main.bounds.width
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        let property = self.vProperty as! FWSheetViewProperty
        
        var currentMaxY:CGFloat = self.vProperty.topBottomMargin
        
        if title != nil && !title!.isEmpty {
            self.titleLabel = UILabel(frame: CGRect(x: self.vProperty.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.vProperty.letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.text = title
            self.titleLabel?.textColor = self.vProperty.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.vProperty.titleFontSize)
            self.titleLabel?.numberOfLines = 5
            self.titleLabel?.backgroundColor = UIColor.clear
            
            self.titleLabel?.sizeToFit()
            
            self.titleLabel?.frame = CGRect(x: self.vProperty.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.vProperty.letfRigthMargin * 2, height: self.titleLabel!.frame.height)
            
            currentMaxY = self.titleLabel!.frame.maxY
            
            self.commponenetArray.append(self.titleLabel!)
        }
        
        currentMaxY += self.vProperty.topBottomMargin
        
        // 开始配置Item
        let btnContrainerView = UIScrollView(frame: CGRect(x: 0, y: currentMaxY, width: self.frame.width, height: self.vProperty.buttonHeight))
        btnContrainerView.bounces = false
        btnContrainerView.backgroundColor = UIColor.clear
        self.addSubview(btnContrainerView)
        
        currentMaxY = btnContrainerView.frame.maxY
        
        let block: FWPopupItemClickedBlock = { (popupView, index) in
            if cancenlBlock != nil {
                cancenlBlock!()
            }
        }
        
        var tmpIndex = 0
        self.actionItemArray.append(FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: block))
        
        var cancelBtnTopView: UIView?
        var cancelBtn: UIButton?
        
        for popupItem: FWPopupItem in self.actionItemArray {
            
            let btn = UIButton(type: .custom)
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btn.tag = tmpIndex
            
            var btnY: CGFloat = 0.0
            if tmpIndex < self.actionItemArray.count - 1 {
                btnY = self.vProperty.buttonHeight * CGFloat(tmpIndex)
                btnContrainerView.addSubview(btn)
            } else {
                btnY = self.vProperty.buttonHeight * CGFloat(tmpIndex) + property.cancelBtnMarginTop
                
                cancelBtnTopView = UIView(frame: CGRect(x: 0, y: btnY - property.cancelBtnMarginTop, width: self.frame.width, height: property.cancelBtnMarginTop))
                cancelBtnTopView?.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
                self.addSubview(cancelBtnTopView!)
                
                cancelBtn = btn
                self.addSubview(cancelBtn!)
            }
            btn.frame = CGRect(x: -self.vProperty.splitWidth, y: btnY, width: btnContrainerView.frame.width + self.vProperty.splitWidth * 2, height: property.buttonHeight + property.splitWidth)
            
            if tmpIndex > 0 {
                currentMaxY += btn.frame.height
                if tmpIndex == self.actionItemArray.count - 1 {
                    if btn.frame.minY - property.cancelBtnMarginTop <= property.popupViewMaxHeight {
                        btnContrainerView.frame.size.height = btn.frame.minY - property.cancelBtnMarginTop
                    } else {
                        btnContrainerView.frame.size.height = self.vProperty.popupViewMaxHeight
                        btnContrainerView.contentSize = CGSize(width: self.frame.width, height: btn.frame.minY - property.cancelBtnMarginTop)
                    }
                    cancelBtnTopView?.frame.origin.y = btnContrainerView.frame.maxY
                    cancelBtn?.frame.origin.y = cancelBtnTopView!.frame.maxY
                }
            }
            
            // 按钮背景颜色
            if popupItem.itemBackgroundColor != nil {
                btn.backgroundColor = popupItem.itemBackgroundColor
            } else {
                btn.backgroundColor = self.vProperty.backgroundColor
            }
            // 按钮文字颜色
            if popupItem.itemTitleColor != nil {
                btn.setTitleColor(popupItem.itemTitleColor, for: .normal)
            } else {
                btn.setTitleColor(popupItem.highlight ? self.vProperty.itemHighlightColor : self.vProperty.itemNormalColor, for: .normal)
            }
            
            btn.setTitle(popupItem.title, for: .normal)
            btn.layer.borderWidth = self.vProperty.splitWidth
            btn.layer.borderColor = self.vProperty.splitColor.cgColor
            btn.setBackgroundImage(self.getImageWithColor(color: btn.backgroundColor!), for: .normal)
            btn.setBackgroundImage(self.getImageWithColor(color: self.vProperty.itemPressedColor), for: .highlighted)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.vProperty.buttonFontSize)
            
            tmpIndex += 1
        }
        
        self.frame.size.height = btnContrainerView.frame.maxY + self.vProperty.buttonHeight + property.cancelBtnMarginTop
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
            item.itemClickedBlock!(self, btn.tag)
        }
    }
}

/// FWSheetView的相关属性，请注意其父类中还有很多公共属性
open class FWSheetViewProperty: FWPopupViewProperty {
    
    // 取消按钮距离头部的距离
    @objc public var cancelBtnMarginTop: CGFloat = 6
    
}
