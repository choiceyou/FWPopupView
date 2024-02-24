//
//  FWDemoViewController.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/26.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class FWDemoViewController: UITableViewController {
    
    /// 注意：这边不同的示例可能还附加演示了一些特性（比如：遮罩层是否能够点击、遮罩层的背景颜色等等），有用到时可以参考
    var titleArray = ["0、Alert - 单个按钮", 
                      "1、Alert - 两个按钮",
                      "2、Alert - 两个按钮（演示修改各种配置）",
                      "3、Alert - 自定义按钮",
                      "4、Alert - 多个按钮",
                      "5、Alert - 带输入框",
                      "6、Alert - 带自定义视图",
                      "7、Sheet - 少量Item",
                      "8、Sheet - 标题+少量Item",
                      "9、Sheet - 大量Item",
                      "10、Date - 自定义日期选择",
                      "11、Menu - 自定义菜单",
                      "12、Custom - 自定义弹窗",
                      "13、CustomSheet - 类似Sheet效果",
                      "14、CustomSheet - 类似Sheet效果2",
                      "15、同时显示两个弹窗（展示可以同时调用多个弹窗的显示方法，但是显示过程按“后来者先显示”的原则，隐藏过程则反之）",
                      "16、RadioButton",
                      "17、含RadioButton的Alert",
                      "18、xib 方式创建弹窗"
    ]
    
    let block: FWPopupItemClickedBlock = { (popupView, index, title) in
        print("AlertView：点击了第\(index)个按钮")
    }
    
    lazy var customSheetView: FWCustomSheetView = {
        
        let property = FWCustomSheetViewProperty()
        property.popupViewItemHeight = 40
        property.selectedIndex = 1
        
        let titles = ["Objective-C", "Swift", "Java", "python"]
        
        let customSheetView = FWCustomSheetView.sheet(headerTitle: "选择开发语言", itemTitles: titles, itemSecondaryTitles: nil, itemImages: nil, itemBlock: { (popupView, index, title) in
            print("customSheet：点击了第\(index)个按钮")
        }, property: property)
        
        return customSheetView
    }()
    
    lazy var customSheetView2: FWCustomSheetView = {
        
        let property = FWCustomSheetViewProperty()
        property.lastNeedAccessoryView = true
        // 设置默认不选中
        property.selectedIndex = -1
        
        let titles = ["Objective-C", "Swift", "其他开发语言"]
        let secondaryTitles = ["Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C", "Swift 是苹果推出的编程语言，专门针对 OS X 和 iOS 的应用开发",""]
        let images = [UIImage(named: "right_menu_addFri"),
                      UIImage(named: "right_menu_addFri"),
                      UIImage(named: "right_menu_multichat")]
        
        let customSheetView = FWCustomSheetView.sheet(headerTitle: "选择一种开发语言", itemTitles: titles, itemSecondaryTitles: secondaryTitles, itemImages: images as? [UIImage], itemBlock: { (popupView, index, title) in
            print("customSheet：点击了第\(index)个按钮")
        }, property: property)
        
        return customSheetView
    }()
    
    lazy var alertImage: FWAlertView = {
        
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
        
        let alertImage = FWAlertView.alert(title: "标题", detail: "带自定义视图", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: customImageView, items: items, vProperty: vProperty)
        return alertImage
    }()
    
    lazy var sheetView: FWSheetView = {
       
        let items = ["确定"]
        
        let vProperty = FWSheetViewProperty()
        vProperty.touchWildToHide = "1"
        vProperty.titleColor = UIColor.lightGray
        vProperty.titleFont = UIFont.systemFont(ofSize: 15.0)
        // 取消按钮底下区域通铺效果（必须修改以下属性）
        vProperty.bottomCoherent = true
        vProperty.backgroundColor = UIColor.white
        vProperty.dark_backgroundColor = kPV_RGBA(r: 44, g: 44, b: 44, a: 1)
        
        let sheetView = FWSheetView.sheet(title: "你们知道微信中为什么经常使用这种提示，而不使用Alert加两个按钮的那种提示吗？", itemTitles: items, itemBlock: { (popupView, index, title) in
            print("Sheet：点击了第\(index)个按钮")
        }, cancenlBlock: {
            print("点击了取消")
        }, property: vProperty)
        return sheetView
    }()
    
    lazy var radioButton: FWRadioButton = {
        
        let property = FWRadioButtonProperty()
        property.selectedStateColor = UIColor.red
        property.animationDuration = 0.2
        property.isAnimated = true
        property.isSelected = true
        property.insideMarginRate = 0.5
        property.isBorderColorNeedChanged = true
        property.lineWidth = 3
        property.radioViewEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 2)
        
        let radioButton = FWRadioButton.radio(frame: CGRect(x: 0, y: 0, width: 150, height: 40), buttonType: .circular, title: "这个是标题啦", selectedImage: nil, unSelectedImage: nil, property: property, clickedBlock: { (isSelected) in
            print("FWRadioButtonProperty点击了，是否选中：\(isSelected)")
        })
        return radioButton
    }()
    
    var customBtnAlert: FWAlertView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "FWPopupView"
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        // 设置弹窗外部可点击
        // FWPopupSWindow.sharedInstance.touchWildToHide = true
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{get { return .lightContent}}
}

extension FWDemoViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        if indexPath.row == 10 || indexPath.row == 11 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.row == 15 {
            cell.accessoryView = self.radioButton
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
            let alertView = FWAlertView.alert(title: "温馨提示", detail: "您确认退出当前账号吗？", confirmBlock: { (popupView, index, title) in
                print("点击了确定")
            }, cancelBlock: { (popupView, index, title) in
                print("点击了取消")
            })
            alertView.show()
            break
        case 2:
            // 注意：此时“确定”按钮是不让按钮自己隐藏的
            let items: [FWPopupItem] = [
                FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemTitleColor: kPV_RGBA(r: 141, g: 151, b: 163, a: 1.0), itemBackgroundColor: nil, itemClickedBlock: block),
                FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: true, itemTitleColor: kPV_RGBA(r: 29, g: 150, b: 227, a: 1.0), itemTitleFont: UIFont.systemFont(ofSize: 20.0), itemBackgroundColor: nil, itemClickedBlock: block)
            ]
            
            // 演示：修改参数
            let vProperty = FWAlertViewProperty()
            vProperty.alertViewWidth = max(UIScreen.main.bounds.width * 0.65, 275)
            vProperty.titleFont = UIFont.systemFont(ofSize: 17.0)
            vProperty.detailFont = UIFont.systemFont(ofSize: 14.0)
            vProperty.detailColor = kPV_RGBA(r: 141, g: 151, b: 163, a: 1.0)
            vProperty.buttonFont = UIFont.systemFont(ofSize: 14.0)
            vProperty.maskViewColor = UIColor(white: 0, alpha: 0.5)
            vProperty.touchWildToHide = "1"
            vProperty.dark_backgroundColor = kPV_RGBA(r: 90, g: 90, b: 90, a: 1)
            vProperty.dark_splitColor = kPV_RGBA(r: 100, g: 100, b: 100, a: 1)
            // 还有很多参数可设置...
            
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: nil, items: items, vProperty: vProperty)
            alertView.show { (popupView, popupViewState) in
                print("当前弹窗状态：\(popupViewState.rawValue)")
                if popupViewState == .didDisappear {
                    print("当前弹窗已经隐藏")
                }
            }
            break
        case 3:
            let tmpWidth = max(UIScreen.main.bounds.width * 0.65, 275)
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: tmpWidth, height: 90))
            
            let tmpMargin: CGFloat = 20
            let btn1 = UIButton(type: .custom)
            btn1.frame = CGRect(x: tmpMargin, y: 20, width: ((tmpWidth - tmpMargin * 2 - 26)/2), height: 44)
            btn1.backgroundColor = kPV_RGBA(r: 69, g: 85, b: 255, a: 1)
            btn1.clipsToBounds = true
            btn1.layer.cornerRadius = 10
            btn1.setTitle("OK", for: .normal)
            btn1.setTitleColor(UIColor.white, for: .normal)
            btn1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn1.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
            customView.addSubview(btn1)
            
            let btn2 = UIButton(type: .custom)
            btn2.frame = CGRect(x: CGRectGetMaxX(btn1.frame) + 26, y: 20, width: ((tmpWidth - tmpMargin * 2 - 26)/2), height: 44)
            btn2.backgroundColor = UIColor.white
            btn2.clipsToBounds = true
            btn2.layer.borderColor = UIColor.black.cgColor
            btn2.layer.borderWidth = 1
            btn2.layer.cornerRadius = 10
            btn2.setTitle("CANCEL", for: .normal)
            btn2.setTitleColor(UIColor.black, for: .normal)
            btn2.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn2.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
            customView.addSubview(btn2)
            
            // 演示：修改参数
            let vProperty = FWAlertViewProperty()
            vProperty.alertViewWidth = tmpWidth
            vProperty.detailFont = UIFont.systemFont(ofSize: 14.0)
            vProperty.titleColor = kPV_RGBA(r: 25, g: 32, b: 45, a: 1)
            vProperty.maskViewColor = UIColor(white: 0, alpha: 0.5)
            vProperty.touchWildToHide = "1"
            vProperty.dark_backgroundColor = kPV_RGBA(r: 90, g: 90, b: 90, a: 1)
            vProperty.cornerRadius = 16
            // 还有很多参数可设置...
            
            let items: [FWPopupItem] = []
            
            customBtnAlert = FWAlertView.alert(title: nil, detail: "描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述述描述描述描述描述描述述描述描述描述描述描述", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: customView, items: items, vProperty: vProperty)
            customBtnAlert?.show { (popupView, popupViewState) in
                print("当前弹窗状态：\(popupViewState.rawValue)")
                if popupViewState == .didDisappear {
                    print("当前弹窗已经隐藏")
                }
            }
            break
        case 4:
            let myBlock: FWPopupItemClickedBlock = { [weak self] (popupView, index, title) in
                print("AlertView：点击了第\(index)个按钮")
                if index == 2 {
                    self?.sheetView.show()
                }
            }
            
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: myBlock),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: myBlock),
                         FWPopupItem(title: "弹出Sheet", itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: myBlock)]
            
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述描述描述描述描述描述描述", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: nil, items: items)
            alertView.show()
            break
        case 5:
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: block)]
            
            // 演示：修改参数
            let vProperty = FWAlertViewProperty()
            vProperty.inputTextFont = UIFont.systemFont(ofSize: 15)
            
            let alertView = FWAlertView.alert(title: "标题", detail: "带输入框", inputPlaceholder: "请输入...", keyboardType: .numberPad, isSecureTextEntry: false, customView: nil, items: items, vProperty: vProperty)
            alertView.inputBlock = { (text) in
                print("您当前输入的文字是：\(text)")
            }
            alertView.show()
            break
        case 6:
            self.alertImage.show()
            break
        case 7:
            let items = ["Sheet0", "Sheet1", "Sheet2", "Sheet3"]
            
            let vProperty = FWSheetViewProperty()
            vProperty.touchWildToHide = "1"
            vProperty.cancelItemTitleColor = UIColor.red
            vProperty.dark_cancelItemTitleColor = kPV_RGBA(r: 125, g: 144, b: 169, a: 1)
            // 取消按钮底下区域通铺效果（必须修改以下属性）
            vProperty.bottomCoherent = true
            vProperty.backgroundColor = UIColor.white
            vProperty.dark_backgroundColor = kPV_RGBA(r: 44, g: 44, b: 44, a: 1)
            vProperty.leftRightTopCornerRadius = 10
            
            let sheetView = FWSheetView.sheet(title: "", itemTitles: items, itemBlock: { (popupView, index, title) in
                print("Sheet：点击了第\(index)个按钮")
            }, cancenlBlock: {
                print("点击了取消")
            }, property: vProperty)
            sheetView.show { popupView, popupViewState in
                print("当前sheet状态：\(popupViewState.rawValue)")
            }
            break
        case 8:
            self.sheetView.show()
            break
        case 9:
            let items = ["Sheet0", "Sheet1", "Sheet2", "Sheet3", "Sheet4", "Sheet5", "Sheet6", "Sheet7", "Sheet8", "Sheet9", "Sheet10", "Sheet11", "Sheet12", "Sheet13", "Sheet14"]
            
            let sheetView = FWSheetView.sheet(title: "标题", itemTitles: items, itemBlock: { (popupView, index, title) in
                print("Sheet：点击了第\(index)个按钮，名称为：\(String(describing: title))")
            }, cancenlBlock: {
                print("点击了取消")
            })
            sheetView.show()
            break
        case 10:
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
        case 11:
            self.navigationController?.pushViewController(FWMenuViewDemoVC(), animated: true)
            break
        case 12:
            self.navigationController?.pushViewController(FWCustomPopupDemoVC(), animated: true)
            break
        case 13:
            self.customSheetView.show()
            break
        case 14:
            self.customSheetView2.show()
            break
        case 15:
            let alertView = FWAlertView.alert(title: "标题", detail: "描述描述描述描述") { (popupView, index, title) in
                print("点击了确定")
            }
            alertView.show { (popupView, popupViewState) in
                print("当前alertView状态：\(popupViewState.rawValue)")
            }
            
            let items = ["Sheet0", "Sheet1", "Sheet2", "Sheet3"]
            let vProperty = FWSheetViewProperty()
            vProperty.touchWildToHide = "1"
            let sheetView = FWSheetView.sheet(title: "", itemTitles: items, itemBlock: { (popupView, index, title) in
                print("Sheet：点击了第\(index)个按钮")
            }, cancenlBlock: {
                print("点击了取消")
            }, property: vProperty)
            sheetView.show()
            break
        case 16:
            // 演示如何修改是否选中的状态
            self.radioButton.isSelected = !self.radioButton.isSelected
            break
        case 17:
            let property = FWRadioButtonProperty()
            property.animationDuration = 0.2
            property.isAnimated = true
            property.isSelected = true
            property.radioViewEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 2)
            
            let radioButton = FWRadioButton.radio(frame: CGRect(x: 0, y: 0, width: 260, height: 35), buttonType: .image, title: "勾选表示记住当前状态哦！！！", selectedImage: nil, unSelectedImage: nil, property: property, clickedBlock: { (isSelected) in
                print("FWRadioButtonProperty点击了，是否选中：\(isSelected)")
            })
            
            let block: FWPopupItemClickedBlock = { (popupView, index, title) in
                print("AlertView：点击了第\(index)个按钮")
                popupView.hide()
            }
            
            // 注意：此时“确定”按钮是不让按钮自己隐藏的
            let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: block),
                         FWPopupItem(title: "确定", itemType: .normal, isCancel: false, canAutoHide: false, itemClickedBlock: block)]
            
            let alertView = FWAlertView.alert(title: "温馨提示", detail: "是否记住当前状态？", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: radioButton, items: items)
            alertView.show()
            break
        case 18:
            let customPopupView = FWCustomPopupView2(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.5))
            customPopupView.backgroundColor = UIColor.yellow
            
            let vProperty = FWPopupViewProperty()
            vProperty.popupCustomAlignment = .center
            vProperty.popupAnimationType = .scale
            vProperty.maskViewColor = UIColor(white: 0, alpha: 0.5)
            vProperty.touchWildToHide = "1"
            vProperty.popupViewEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            vProperty.animationDuration = 0.3
            customPopupView.vProperty = vProperty
            
            customPopupView.show()
            break;
            
        default:
            break
        }
    }
}


extension FWDemoViewController {
    @objc private func confirmBtnAction() {
        customBtnAlert?.hide()
    }
    
    @objc private func cancelBtnAction() {
        customBtnAlert?.hide()
    }
}
