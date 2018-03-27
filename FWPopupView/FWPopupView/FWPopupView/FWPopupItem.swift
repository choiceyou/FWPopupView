//
//  FWPopupItem.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/21.
//  Copyright © 2018年 xfg. All rights reserved.
//

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

public typealias FWPopupItemHandler = (_ index: Int) -> Void

open class FWPopupItem: NSObject {
    
    /// 是否高亮
    @objc var highlight = false
    /// 是否不可点击
    @objc var disabled = false
    
    /// 按钮颜色
    @objc var color = UIColor.clear
    
    /// 标题
    @objc var title: String
    
    /// 按钮类型
    @objc var itemType: FWItemType
    /// 是否取消按钮
    @objc var isCancel: Bool
    
    @objc var itemHandler: FWPopupItemHandler?
    
    @objc public init(title: String, itemType: FWItemType, isCancel: Bool, handler: @escaping FWPopupItemHandler) {
        self.title = title
        self.itemType = itemType
        self.isCancel = isCancel
        self.itemHandler = handler
        
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
