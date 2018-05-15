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
public typealias FWPopupItemClickedBlock = (_ popupView: FWPopupView, _ index: Int) -> Void

open class FWPopupItem: NSObject {
    
    /// 是否高亮
    @objc open var highlight = false
    /// 是否不可点击
    @objc open var disabled = false
    
    /// 按钮颜色
    @objc open var color = UIColor.clear
    
    /// 标题
    @objc open var title: String
    
    /// 按钮类型
    @objc open var itemType: FWItemType
    /// 是否取消按钮
    @objc open var isCancel: Bool
    /// 点击该按钮后会自动隐藏弹窗
    @objc open var canAutoHide: Bool
    
    @objc open var itemClickedBlock: FWPopupItemClickedBlock?
    
    @objc public init(title: String, itemType: FWItemType, isCancel: Bool, canAutoHide: Bool, itemClickedBlock: FWPopupItemClickedBlock? = nil) {
        self.title = title
        self.itemType = itemType
        self.isCancel = isCancel
        self.canAutoHide = canAutoHide
        self.itemClickedBlock = itemClickedBlock
        
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
