//
//  FWPopupItem.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/21.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

/// Item类型
///
/// - normal: 普通
/// - highlight: 高亮
/// - disabled: 不可点击
@objc public enum FWItemType: Int {
    case normal
    case highlight
    case disabled
}

/// 点击Item回调
public typealias FWPopupItemClickedBlock = (_ popupView: FWPopupView, _ index: Int, _ title: String?) -> Void

open class FWPopupItem: NSObject {
    
    /// 是否高亮
    @objc open var highlight = false
    /// 是否不可点击
    @objc open var disabled = false
    
    /// 按钮文字颜色
    @objc open var itemTitleColor: UIColor?
    /// 按钮背景颜色
    @objc open var itemBackgroundColor: UIColor?
    
    /// 标题
    @objc open var title: String
    
    /// 按钮类型
    @objc open var itemType: FWItemType
    /// 是否取消按钮
    @objc open var isCancel: Bool
    /// 点击该按钮后会自动隐藏弹窗
    @objc open var canAutoHide: Bool
    
    /// 点击按钮回调
    @objc open var itemClickedBlock: FWPopupItemClickedBlock?
    
    @objc public init(title: String, itemType: FWItemType, isCancel: Bool, canAutoHide: Bool, itemClickedBlock: FWPopupItemClickedBlock? = nil) {
        
        self.title = title
        self.itemType = itemType
        self.isCancel = isCancel
        self.canAutoHide = canAutoHide
        self.itemClickedBlock = itemClickedBlock
        
        super.init()
        
        self.setupItemType(itemType: itemType)
    }
    
    @objc public init(title: String, itemType: FWItemType, isCancel: Bool, canAutoHide: Bool, itemTitleColor: UIColor?, itemBackgroundColor: UIColor?, itemClickedBlock: FWPopupItemClickedBlock? = nil) {
        
        self.title = title
        self.itemType = itemType
        self.isCancel = isCancel
        self.canAutoHide = canAutoHide
        self.itemTitleColor = itemTitleColor
        self.itemBackgroundColor = itemBackgroundColor
        self.itemClickedBlock = itemClickedBlock
        
        super.init()
        
        self.setupItemType(itemType: itemType)
    }
    
    private func setupItemType(itemType: FWItemType) {
    
        switch itemType {
        case .normal:
            break
        case .highlight:
            self.highlight = true
            break
        case .disabled:
            self.disabled = true
            break
        }
    }
}
