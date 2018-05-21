//
//  FWMenuView.swift
//  FWPopupView
//
//  Created by xfg on 2018/5/19.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

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


class FWMenuViewTableViewCell: UITableViewCell {
    
}


open class FWMenuView: FWPopupView, UITableViewDelegate, UITableViewDataSource {
    
    /// 外部传入的标题数组
    private var itemTitleArray: [String]?
    /// 外部传入的图片数组
    private var itemImageNameArray: [String]?
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)
        return tableView
    }()
    
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: nil)
    }
    
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: property)
    }
    
    @objc open class func menu(itemTitles: [String]?, itemImageNames: [String]?, itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) -> FWMenuView {
        
        let popupMenu = FWMenuView()
        popupMenu.setupUI(itemTitles: itemTitles, itemImageNames: itemImageNames, itemBlock: itemBlock, property: property)
        return popupMenu
    }
}

extension FWMenuView {
    
    private func setupUI(itemTitles: [String]?, itemImageNames: [String]?, itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) {
        
        if itemTitles == nil && itemImageNames == nil {
            return
        }
        
        if property != nil {
            self.vProperty = property!
        } else {
            self.vProperty = FWMenuViewProperty()
        }
        
        self.backgroundColor = self.vProperty?.backgroundColor
        if self.vProperty?.maskViewColor != nil {
            self.attachedView?.fwMaskViewColor = self.vProperty!.maskViewColor!
        }
        
        if self.vProperty!.touchWildToHide != nil && !self.vProperty!.touchWildToHide!.isEmpty {
            FWPopupWindow.sharedInstance.touchWildToHide = (Int(self.vProperty!.touchWildToHide!) == 1) ? true : false
        }
        
        self.clipsToBounds = true
        
        self.popupType = .custom
        
        self.itemTitleArray = itemTitles
        self.itemImageNameArray = itemImageNames
        
        self.tableView.register(FWMenuViewTableViewCell.self, forCellReuseIdentifier: "cellId")
        self.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        self.tableView.frame = self.frame
    }
}

extension FWMenuView {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.itemTitleArray != nil {
            return self.itemTitleArray!.count
        } else {
            return self.itemImageNameArray!.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! FWMenuViewTableViewCell
        cell.textLabel?.text = self.itemTitleArray![indexPath.row]
        return cell
    }
}


/// FWMenuView的相关属性，请注意其父类中还有很多公共属性
open class FWMenuViewProperty: FWPopupViewProperty {
    
    /// 弹窗箭头的样式
    @objc public var menuArrowStyle: FWMenuArrowStyle = .round
    
}

