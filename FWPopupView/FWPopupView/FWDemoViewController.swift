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
    
    var alertImage: FWAlertView!
    
    /// 注意：这边不同的示例可能还附加演示了一些特性（比如：遮罩层是否能够点击、遮罩层的背景颜色等等），有用到时可以参考
    var titleArray = ["Alert - 单个按钮", "Alert - 两个按钮", "Alert - 两个按钮（修改参数）", "Alert - 多个按钮", "Alert - 带输入框", "Alert - 带自定义视图", "Sheet - 少量Item", "Sheet - 大量Item", "Date - 自定义日期选择", "Menu - 自定义菜单", "Custom - 自定义弹窗", "CustomSheet - 类似Sheet效果", "CustomSheet - 类似Sheet效果2", "RadioButton"]
    
    let block: FWPopupItemClickedBlock = { (popupView, index, title) in
        print("AlertView：点击了第\(index)个按钮")
    }
    
    lazy var customSheetView: FWCustomSheetView = {
        
        let property = FWCustomSheetViewProperty()
        property.popupViewItemHeight = 40
        
        let titles = ["EOS", "DICE", "ZKS"]
        
        let customSheetView = FWCustomSheetView.sheet(headerTitle: "选择代币", itemTitles: titles, itemSecondaryTitles: nil, itemImages: nil, itemBlock: { (popupView, index, title) in
            print("customSheet：点击了第\(index)个按钮")
        }, property: property)
        
        return customSheetView
    }()
    
    lazy var customSheetView2: FWCustomSheetView = {
        
        let property = FWCustomSheetViewProperty()
        property.lastNeedAccessoryView = true
        
        let titles = ["fdksds123123", "fdksds112233", "导入钱包"]
        let secondaryTitles = ["EOS6sHTCXbm4Gz5WRhKxuuBgVZYttvM9tEdU6ThH6kseMWLYDTk9q", "EOS1sdksbm4Gz5WRhKxuuBgVZYttvM9tEdU6ThH6kseMWLYDTk9q",""]
        let images = [UIImage(named: "right_menu_addFri"),
                      UIImage(named: "right_menu_addFri"),
                      UIImage(named: "right_menu_multichat")]
        
        let customSheetView = FWCustomSheetView.sheet(headerTitle: "选择一个钱包", itemTitles: titles, itemSecondaryTitles: secondaryTitles, itemImages: images as? [UIImage], itemBlock: { (popupView, index, title) in
            print("customSheet：点击了第\(index)个按钮")
        }, property: property)
        
        return customSheetView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "FWPopupView"
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        // 设置弹窗外部可点击
        // FWPopupWindow.sharedInstance.touchWildToHide = true
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
        if indexPath.row == 9 || indexPath.row == 10 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.row == 13 {
            let property = FWRadioButtonProperty()
            property.selectedStateColor = UIColor.red
            property.buttonType = .rectangle
            cell.accessoryView = FWRadioButton.radio(frame: CGRect(x: 0, y: 0, width: 25, height: 25), property: property)
        } else {
            cell.accessoryType = .none
            cell.accessoryView = nil
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述") { (popupView, index, title) in
                print("点击了确定")
            }
            alertView.show()
            break
        case 1:
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述描述描述描述描述描述描述", confirmBlock: { (popupView, index, title) in
                print("点击了确定")
            }, cancelBlock: { (popupView, index, title) in
                print("点击了取消")
            })
            // 设置AlertView外部背景色
            alertView.attachedView?.fwMaskViewColor = UIColor(white: 0, alpha: 0.2)
            alertView.show { (popupView, popupViewState) in
                print("当前弹窗状态：\(popupViewState.rawValue)")
                if popupViewState == .didDisappear {
                    // 隐藏时把背景色改回来（这个非必要，我这边只是一个演示）
                    alertView.attachedView?.fwMaskViewColor = UIColor(white: 0, alpha: 0.5)
                }
            }
            break
        case 2:
            // 注意：此时“确定”按钮是不让按钮自己隐藏的
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemTitleColor: kPV_RGBA(r: 141, g: 151, b: 163, a: 1.0), itemBackgroundColor: nil, itemClickedBlock: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: true, itemTitleColor: kPV_RGBA(r: 29, g: 150, b: 227, a: 1.0), itemBackgroundColor: nil, itemClickedBlock: block)]
            
            // 主要演示修改参数
            let vProperty = FWAlertViewProperty()
            vProperty.alertViewWidth = max(UIScreen.main.bounds.width * 0.65, 275)
            vProperty.titleFontSize = 17.0
            vProperty.detailFontSize = 14.0
            vProperty.detailColor = kPV_RGBA(r: 141, g: 151, b: 163, a: 1.0)
            vProperty.buttonFontSize = 14.0
            vProperty.maskViewColor = UIColor(white: 0, alpha: 0.5)
            vProperty.touchWildToHide = "1"
            // 还有很多参数可设置...
            
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述描述描述描述描述描述描述", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: nil, items: items, vProperty: vProperty)
            
            alertView.show()
            break
        case 3:
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: block),
                         FWPopupItem(title: "其他", itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: block)]
            
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述描述描述描述描述描述描述", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: nil, items: items)
            alertView.show()
            break
        case 4:
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: block)]
            
            let alertView = FWAlertView.alert(title: "标题", detail: "带输入框", inputPlaceholder: "请输入...", keyboardType: .numberPad, isSecureTextEntry: true, customView: nil, items: items)
            alertView.show()
            break
        case 5:
            if self.alertImage == nil {
                
                let block2: FWPopupItemClickedBlock = { [weak self] (popupView, index, title) in
                    
                    if index == 1 {
                        // 这边演示了如何手动去调用隐藏
                        self?.alertImage.hide()
                    }
                }
                
                // 注意：此时“确定”按钮是不让按钮自己隐藏的
                let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: block2),
                             FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: false, itemClickedBlock: block2)]
                // 注意：添加自定义的视图，需要设置确定的Frame值
                let customImageView = UIImageView(image: UIImage(named: "audio_bgm_4"))
                
                let vProperty = FWAlertViewProperty()
                vProperty.touchWildToHide = "1"
                
                self.alertImage = FWAlertView.alert(title: "标题", detail: "带自定义视图", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: customImageView, items: items, vProperty: vProperty)
            }
            
            self.alertImage.show()
            break
        case 6:
            let items = ["Sheet0", "Sheet1", "Sheet2", "Sheet3"]
            
            let vProperty = FWSheetViewProperty()
            vProperty.touchWildToHide = "1"
            
            let sheetView = FWSheetView.sheet(title: nil, itemTitles: items, itemBlock: { (popupView, index, title) in
                print("Sheet：点击了第\(index)个按钮")
            }, cancenlBlock: {
                print("点击了取消")
            }, property: vProperty)
            sheetView.show()
            break
        case 7:
            let items = ["Sheet0", "Sheet1", "Sheet2", "Sheet3", "Sheet4", "Sheet5", "Sheet6", "Sheet7", "Sheet8", "Sheet9", "Sheet10", "Sheet11", "Sheet12", "Sheet13", "Sheet14"]
            
            let sheetView = FWSheetView.sheet(title: "标题", itemTitles: items, itemBlock: { (popupView, index, title) in
                print("Sheet：点击了第\(index)个按钮，名称为：\(String(describing: title))")
            }, cancenlBlock: {
                print("点击了取消")
            })
            sheetView.show()
            break
        case 8:
            let dateView = FWDateView.date(confirmBlock: { (datePicker) in
                print("当前选定时间：\(datePicker.date)")
            }, cancelBlock: {
                print("点击了 FWDateView 的取消")
            })
            dateView.datePicker.minimumDate = Date()
            dateView.datePicker.locale = Locale(identifier: "zh_Hans_CN")
            dateView.datePicker.datePickerMode = .dateAndTime
            dateView.datePicker.calendar = Calendar.current
            dateView.show()
            break
        case 9:
            self.navigationController?.pushViewController(FWMenuViewDemoVC(), animated: true)
            break
        case 10:
            self.navigationController?.pushViewController(FWCustomPopupDemoVC(), animated: true)
            break
        case 11:
            self.customSheetView.show()
            break
        case 12:
            self.customSheetView2.show()
            break
        default:
            break
        }
    }
}
