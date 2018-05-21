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

open class FWMenuView: FWPopupView {
    
    // 可设置属性
    @objc open var property = FWMenuViewProperty()
    
    
    private lazy var tableView: UITableView = {
       
        let tableView = UITableView()
        return tableView
    }()
    
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: nil)
    }
    
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: property)
    }
    
    @objc open class func menu(itemTitles: [String], itemImageNames: [String]?, itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) -> FWMenuView {
        
        let popupMenu = FWMenuView()
        popupMenu.setupUI(itemTitles: itemTitles, itemImageNames: itemImageNames, itemBlock: itemBlock)
        return popupMenu
    }
}

extension FWMenuView {
    
    private func setupUI(itemTitles: [String], itemImageNames: [String]?, itemBlock: FWPopupItemClickedBlock? = nil) {
        
        
    }
}


/// FWMenuView的相关属性，请注意其父类中还有很多公共属性
open class FWMenuViewProperty: FWPopupViewProperty {
    
    
    
}

