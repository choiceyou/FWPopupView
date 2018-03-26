//
//  FWDemoViewController.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/26.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWDemoViewController: UITableViewController {
    
    var titleArray = ["Alert - 单个按钮", "Alert - 两个按钮", "Alert - 多个按钮", "Alert - 带输入框", "Alert - 带自定义视图", "Sheet - 少量Item", "Sheet - 大量Item"]
    
    let block: FWPopupItemHandler = { (index) in
        print("AlertView：点击了第\(index)个按钮")
    }
    
    let completeBlock: FWPopupCompletionBlock = { (popupView, isCompletion) in
        print(popupView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "FWPopupView"
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        // 设置弹窗外部可点击（当且仅当attachedView = FWPopupWindow.sharedInstance.attachView()时有效）
        FWPopupWindow.sharedInstance.touchWildToHide = true
    }
}

extension FWDemoViewController {
    
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
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述") { (index) in
                print("点击了确定")
            }
            alertView.show()
            break
        case 1:
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述描述描述描述描述描述描述", confirmBlock: { (index) in
                print("点击了确定")
            }, cancelBlock: { (index) in
                print("点击了取消")
            })
            // 设置AlertView外部背景色
            alertView.attachedView?.fwBackgroundViewColor = UIColor(white: 0, alpha: 0.4)
            alertView.show(completionBlock: { (popupView, isCompletion) in
                
            })
            break
        case 2:
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, handler: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, handler: block),
                         FWPopupItem(title: "其他", itemType: .normal, isCancel: false, handler: block)]
            
            let vProperty = FWAlertViewProperty()
            vProperty.detailColor = UIColor.red
            
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述描述描述描述描述描述描述", inputPlaceholder: nil, customView: nil, items: items, vProperty: vProperty)
            alertView.show()
            break
        case 3:
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, handler: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, handler: block)]
            
            let alertView = FWAlertView.alert(title: "标题", detail: "带输入框", inputPlaceholder: "请输入...", customView: nil, items: items)
                print("点击了确定")
            alertView.show(completionBlock: { (popupView, isCompletion) in
                print("点击了取消")
            })
            break
        case 4:
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, handler: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, handler: block)]
            // 注意：添加自定义的视图，需要设置确定的Frame值
            let customImageView = UIImageView(image: UIImage(named: "audio_bgm_4"))
            
            let alertView = FWAlertView.alert(title: "标题", detail: "带自定义视图", inputPlaceholder: nil, customView: customImageView, items: items)
                print("点击了确定")
            alertView.show(completionBlock: { (popupView, isCompletion) in
                print("点击了取消")
            })
            break
        case 5:
            let items = ["Sheet0", "Sheet1", "Sheet2", "Sheet3"]
            
            let sheetView = FWSheetView.sheet(title: "测试", itemTitles: items, itemBlock: { (index) in
                print("Sheet：点击了第\(index)个按钮")
            }, cancenlBlock: {
                print("点击了取消")
            })
            sheetView.show()
            break
        case 6:
            let items = ["Sheet0", "Sheet1", "Sheet2", "Sheet3", "Sheet4", "Sheet5", "Sheet6", "Sheet7", "Sheet8", "Sheet9", "Sheet10", "Sheet11", "Sheet12", "Sheet13", "Sheet14"]
            
            let sheetView = FWSheetView.sheet(title: "测试", itemTitles: items, itemBlock: { (index) in
                print("Sheet：点击了第\(index)个按钮")
            }, cancenlBlock: {
                print("点击了取消")
            })
            sheetView.show()
            break
            
        default:
            break
        }
    }
}
