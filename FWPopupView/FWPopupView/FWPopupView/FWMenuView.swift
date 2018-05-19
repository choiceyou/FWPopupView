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

open class FWMenuView: FWPopupView {
    
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock)
    }
    
    @objc open class func menu(itemTitles: [String], itemImageNames: [String]?, itemBlock: FWPopupItemClickedBlock? = nil) -> FWMenuView {
        
        let popupMenu = FWMenuView()
        popupMenu.setupUI(itemTitles: itemTitles, itemImageNames: itemImageNames, itemBlock: itemBlock)
        return popupMenu
    }
}

extension FWMenuView {
    
    private func setupUI(itemTitles: [String], itemImageNames: [String]?, itemBlock: FWPopupItemClickedBlock? = nil) {
        
        
    }
}
