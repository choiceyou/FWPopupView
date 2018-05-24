//
//  FWCustomPopupDemoVC.swift
//  FWPopupView
//
//  Created by xfg on 2018/5/24.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWCustomPopupDemoVC: UITableViewController {
    
    /// 注意：这边不同的示例可能还附加演示了一些特性（比如：遮罩层是否能够点击、遮罩层的背景颜色等等），有用到时可以参考
    var titleArray = ["头部弹窗 - 位移动画", "Alert - 两个按钮", "Alert - 两个按钮（修改参数）", "Alert - 多个按钮", "Alert - 带输入框", "Alert - 带自定义视图", "Sheet - 少量Item", "Sheet - 大量Item", "Date - 自定义日期选择", "Menu - 自定义菜单", "Custom - 自定义弹窗"]
    
    lazy var customPopupView1: FWCustomPopupView = {
        
        let customPopupView = FWCustomPopupView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4))
        
        let vProperty = FWPopupViewProperty()
        vProperty.popupCustomAlignment = .topCenter
        vProperty.popupAnimationType = .frame
        vProperty.maskViewColor = UIColor(white: 0, alpha: 0.5)
        vProperty.touchWildToHide = "1"
        vProperty.popupViewEdgeInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        vProperty.animationDuration = 0.2
        customPopupView.vProperty = vProperty
        
        return customPopupView
    }()
    
    lazy var customPopupView2: FWCustomPopupView = {
        
        let customPopupView = FWCustomPopupView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4))
        
        let vProperty = FWPopupViewProperty()
        vProperty.popupCustomAlignment = .topCenter
        vProperty.popupAnimationType = .frame
        vProperty.maskViewColor = UIColor(white: 0, alpha: 0.5)
        vProperty.touchWildToHide = "1"
        vProperty.popupViewEdgeInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        vProperty.animationDuration = 0.2
        customPopupView.vProperty = vProperty
        
        return customPopupView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "自定义弹窗"
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
    }
}

extension FWCustomPopupDemoVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            
            break
        default:
            break
        }
    }
}
