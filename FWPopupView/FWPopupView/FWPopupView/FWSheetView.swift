//
//  FWSheetView.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/26.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

@objc open class FWSheetView: FWPopupView {
    
    var property = FWSheetViewProperty()
    
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
    open class func sheet(title: String?, itemTitles: [String], itemBlock:@escaping FWPopupItemHandler, cancenlBlock:@escaping FWPopupVoidBlock) -> FWSheetView {
        
        let sheetView = FWSheetView()
        sheetView.setupUI(title: title, itemTitles: itemTitles, itemBlock:itemBlock, cancenlBlock: cancenlBlock)
        return sheetView
    }
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - itemTitles: 点击项标题
    ///   - itemBlock: 点击回调
    ///   - cancenlBlock: 取消按钮回调
    ///   - property: FWSheetView的相关属性
    /// - Returns: self
    open class func sheet(title: String?, itemTitles: [String], itemBlock:@escaping FWPopupItemHandler, cancenlBlock:@escaping FWPopupVoidBlock, property: FWSheetViewProperty?) -> FWSheetView {
        
        let sheetView = FWSheetView()
        if property != nil {
            sheetView.property = property!
        }
        sheetView.setupUI(title: title, itemTitles: itemTitles, itemBlock:itemBlock, cancenlBlock: cancenlBlock)
        return sheetView
    }
}

extension FWSheetView {
    
    func setupUI(title: String?, itemTitles: [String], itemBlock:@escaping FWPopupItemHandler, cancenlBlock:@escaping FWPopupVoidBlock) {
        
        if itemTitles.count == 0 {
            return
        }
        
        self.backgroundColor = self.property.vbackgroundColor
        self.clipsToBounds = true
        
        self.popupType = .sheet
        self.animationDuration = 0.3
        
        let itemClickBlock: FWPopupItemHandler = { (index) in
            itemBlock(index)
        }
        for title in itemTitles {
            self.actionItemArray.append(FWPopupItem(title: title, itemType: .normal, isCancel: true, handler: itemClickBlock))
        }
        
        self.clipsToBounds = true
        
        self.frame.origin.x = 0
        self.frame.origin.y = 100
        self.frame.size.width = UIScreen.main.bounds.width
        
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        
        var currentMaxY:CGFloat = self.property.topBottomMargin
        
        if title != nil && !title!.isEmpty {
            self.titleLabel = UILabel(frame: CGRect(x: self.property.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.property.letfRigthMargin * 2, height: CGFloat.greatestFiniteMagnitude))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.text = title
            self.titleLabel?.textColor = self.property.titleColor
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.property.titleFontSize)
            self.titleLabel?.numberOfLines = 5
            self.titleLabel?.backgroundColor = UIColor.clear
            
            self.titleLabel?.sizeToFit()
            
            self.titleLabel?.frame = CGRect(x: self.property.letfRigthMargin, y: currentMaxY, width: self.frame.width - self.property.letfRigthMargin * 2, height: self.titleLabel!.frame.height)
            
            currentMaxY = self.titleLabel!.frame.maxY
            
            self.commponenetArray.append(self.titleLabel!)
        }
        
        currentMaxY += self.property.topBottomMargin
        
        // 开始配置Item
        let btnContrainerView = UIScrollView(frame: CGRect(x: 0, y: currentMaxY, width: self.frame.width, height: self.property.buttonHeight))
        btnContrainerView.bounces = false
        btnContrainerView.backgroundColor = UIColor.clear
        self.addSubview(btnContrainerView)
        
        currentMaxY = btnContrainerView.frame.maxY
        
        let block: FWPopupItemHandler = { (index) in
            cancenlBlock()
        }
        
        var tmpIndex = 0
        self.actionItemArray.append(FWPopupItem(title: "取消", itemType: .normal, isCancel: true, handler: block))
        
        var cancelBtnTopView: UIView?
        var cancelBtn: UIButton?
        
        for popupItem: FWPopupItem in self.actionItemArray {
            
            let btn = UIButton(type: .custom)
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btn.tag = tmpIndex
            
            var btnY: CGFloat = 0.0
            if tmpIndex < self.actionItemArray.count - 1 {
                btnY = self.property.buttonHeight * CGFloat(tmpIndex)
                btnContrainerView.addSubview(btn)
            } else {
                btnY = self.property.buttonHeight * CGFloat(tmpIndex) + self.property.cancelBtnMarginTop
                
                cancelBtnTopView = UIView(frame: CGRect(x: 0, y: btnY - self.property.cancelBtnMarginTop, width: self.frame.width, height: self.property.cancelBtnMarginTop))
                cancelBtnTopView?.backgroundColor = UIColor.lightGray
                self.addSubview(cancelBtnTopView!)
                
                cancelBtn = btn
                self.addSubview(cancelBtn!)
            }
            btn.frame = CGRect(x: -self.property.splitWidth, y: btnY, width: btnContrainerView.frame.width + self.property.splitWidth * 2, height: self.property.buttonHeight + self.property.splitWidth)
            
            if tmpIndex > 0 {
                currentMaxY += btn.frame.height
                if tmpIndex == self.actionItemArray.count - 1 {
                    if btn.frame.minY - self.property.cancelBtnMarginTop <= self.property.btnContrainerViewMaxHeight {
                        btnContrainerView.frame.size.height = btn.frame.minY - self.property.cancelBtnMarginTop
                    } else {
                        btnContrainerView.frame.size.height = self.property.btnContrainerViewMaxHeight
                        btnContrainerView.contentSize = CGSize(width: self.frame.width, height: btn.frame.minY - self.property.cancelBtnMarginTop)
                    }
                    cancelBtnTopView?.frame.origin.y = btnContrainerView.frame.maxY
                    cancelBtn?.frame.origin.y = cancelBtnTopView!.frame.maxY
                }
            }
            
            btn.backgroundColor = self.property.vbackgroundColor
            btn.setTitle(popupItem.title, for: .normal)
            btn.setTitleColor(popupItem.highlight ? self.property.itemHighlightColor : self.property.itemNormalColor, for: .normal)
            btn.layer.borderWidth = self.property.splitWidth
            btn.layer.borderColor = self.property.splitColor.cgColor
            btn.setBackgroundImage(self.getImageWithColor(color: btn.backgroundColor!), for: .normal)
            btn.setBackgroundImage(self.getImageWithColor(color: self.property.itemPressedColor), for: .highlighted)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.property.buttonFontSize)
            
            tmpIndex += 1
        }
        
        self.frame.size.height = btnContrainerView.frame.maxY + self.property.buttonHeight + self.property.cancelBtnMarginTop
    }
}

extension FWSheetView {
    
    @objc private func btnAction(_ sender: Any) {
        
        let btn = sender as! UIButton
        let item = self.actionItemArray[btn.tag]
        if item.disabled {
            return
        }
        
        self.hide()
        
        if item.itemHandler != nil {
            item.itemHandler!(btn.tag)
        }
    }
}

/// FWSheetView的相关属性
@objc open class FWSheetViewProperty: FWPopupViewProperty {
    
    // 取消按钮距离头部的距离
    public var cancelBtnMarginTop: CGFloat = 6
    
    public var btnContrainerViewMaxHeight: CGFloat = UIScreen.main.bounds.height * CGFloat(0.6)
    
}
