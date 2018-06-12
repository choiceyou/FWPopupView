//
//  FWMenuViewDemoVC.swift
//  FWPopupView
//
//  Created by xfg on 2018/5/24.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

/// 状态栏高度
let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
/// 导航栏高度
let kNavBarHeight: CGFloat = 44.0

class FWMenuViewDemoVC: UIViewController {
    
    /// 注意：这边不同的示例可能还附加演示了一些特性（比如：遮罩层是否能够点击、遮罩层的背景颜色等等），有用到时可以参考
    var titleArray = ["头部弹窗 - 位移动画", "Alert - 两个按钮", "Alert - 两个按钮（修改参数）", "Alert - 多个按钮", "Alert - 带输入框", "Alert - 带自定义视图", "Sheet - 少量Item", "Sheet - 大量Item", "Date - 自定义日期选择", "Menu - 自定义菜单", "Custom - 自定义弹窗"]
    
    let titles = ["创建群聊", "加好友/群", "扫一扫", "面对面快传", "付款", "拍摄"]
    let images = [UIImage(named: "right_menu_multichat"),
                  UIImage(named: "right_menu_addFri"),
                  UIImage(named: "right_menu_QR"),
                  UIImage(named: "right_menu_facetoface"),
                  UIImage(named: "right_menu_payMoney"),
                  UIImage(named: "right_menu_sendvideo")]
    
    lazy var menuView1: FWMenuView = {
        
        let vProperty = FWMenuViewProperty()
        vProperty.popupCustomAlignment = .topCenter
        vProperty.popupAnimationType = .scale
        vProperty.popupArrowStyle = .round
        vProperty.touchWildToHide = "1"
        vProperty.topBottomMargin = 0
        vProperty.maskViewColor = UIColor(white: 0, alpha: 0.3)
        
        let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: images as? [UIImage], itemBlock: { (popupView, index, title) in
            print("Menu：点击了第\(index)个按钮")
        }, property: vProperty)
        menuView.attachedView = self.view
        
        return menuView
    }()
    
    lazy var menuView2: FWMenuView = {
        
        let vProperty = FWMenuViewProperty()
        vProperty.popupCustomAlignment = .topRight
        vProperty.popupAnimationType = .scale
        vProperty.maskViewColor = UIColor(white: 0, alpha: 0.2)
        vProperty.touchWildToHide = "1"
        vProperty.popupViewEdgeInsets = UIEdgeInsetsMake(kStatusBarHeight + kNavBarHeight, 0, 0, 8)
        vProperty.topBottomMargin = 0
        vProperty.animationDuration = 0.3
        vProperty.popupArrowStyle = .round
        vProperty.popupArrowVertexScaleX = 1
        
        let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: images as? [UIImage], itemBlock: { (popupView, index, title) in
            print("Menu：点击了第\(index)个按钮")
        }, property: vProperty)
        //                menuView.attachedView = self.view
        
        return menuView
    }()
    
    lazy var vProperty: FWMenuViewProperty = {
       
        let vProperty = FWMenuViewProperty()
        return vProperty
    }()
    
    var centerBtn: UIButton!
    var leftBottomBtn: UIButton!
    var rightBottomBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let buttonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "mqz_nav_add"), style: .plain, target: self, action: #selector(barBtnAction(_:)))
        buttonItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -6)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        btn.setTitle("下拉▼", for: .normal)
        btn.tag = 0
        self.navigationItem.titleView = btn
        
        centerBtn = self.setupBtn(title: "中间按钮", frame: CGRect(x: (UIScreen.main.bounds.width - 100)/2, y: UIScreen.main.bounds.height * 0.25, width: 100, height: 50), tag: 1) as! UIButton
        self.view.addSubview(centerBtn)
        
        leftBottomBtn = self.setupBtn(title: "左下角按钮", frame: CGRect(x: 10, y: UIScreen.main.bounds.height * 0.8, width: 100, height: 50), tag: 2) as! UIButton
        self.view.addSubview(leftBottomBtn)
        
        rightBottomBtn = self.setupBtn(title: "右下角按钮", frame: CGRect(x: UIScreen.main.bounds.width - 110, y: UIScreen.main.bounds.height * 0.8, width: 100, height: 50), tag: 3) as! UIButton
        self.view.addSubview(rightBottomBtn)
    }
}

extension FWMenuViewDemoVC {
    
    func setupBtn(title: String, frame: CGRect, tag: Int) -> UIView {
        
        let btn = UIButton(type: .custom)
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        btn.backgroundColor = UIColor.lightGray
        btn.tag = tag
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        
        return btn
    }
    
    @objc func btnAction(_ sender: Any) {
     
        let btn = sender as! UIButton
        switch btn.tag {
        case 0:
            if self.menuView1.visible {
                self.menuView1.hide()
            } else {
                self.menuView1.show()
            }
            break
            
        case 1:
            self.vProperty.popupCustomAlignment = .topCenter
            self.vProperty.popupAnimationType = .scale
            self.vProperty.maskViewColor = UIColor.clear
            self.vProperty.touchWildToHide = "1"
            self.vProperty.popupViewEdgeInsets = UIEdgeInsetsMake(self.centerBtn.frame.maxY + kStatusBarHeight + kNavBarHeight, 0, 0, 0)
            self.vProperty.topBottomMargin = 10
            self.vProperty.animationDuration = 0.3
            self.vProperty.popupArrowStyle = .round
            self.vProperty.popupArrowVertexScaleX = 0.5
            self.vProperty.cornerRadius = 5
            
            let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: nil, itemBlock: { (popupView, index, title) in
                print("Menu：点击了第\(index)个按钮")
            }, property: self.vProperty)
            menuView.show()
            break
            
        case 2:
            self.vProperty.popupCustomAlignment = .bottomLeft
            self.vProperty.popupAnimationType = .frame
            self.vProperty.maskViewColor = UIColor(white: 0, alpha: 0.4)
            self.vProperty.touchWildToHide = "1"
            self.vProperty.popupViewEdgeInsets = UIEdgeInsetsMake(0, 10, UIScreen.main.bounds.height - self.leftBottomBtn.frame.minY - kStatusBarHeight - kNavBarHeight, 0)
            self.vProperty.topBottomMargin = 10
            self.vProperty.animationDuration = 0.3
            self.vProperty.popupArrowStyle = .none
            self.vProperty.popupArrowVertexScaleX = 0.5
            self.vProperty.cornerRadius = 0
            
            let titles = ["Menu0", "Menu1", "Menu2", "Menu3", "Menu4", "Menu5", "Menu6", "Menu7", "Menu8", "Menu9", "Menu10", "Menu11", "Menu12", "Menu13", "Menu14", "Menu15", "Menu16"]
            let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: nil, itemBlock: { (popupView, index, title) in
                print("Menu：点击了第\(index)个按钮")
            }, property: self.vProperty)
            menuView.show()
            break
            
        case 3:
            self.vProperty.popupCustomAlignment = .bottomRight
            self.vProperty.popupAnimationType = .scale
            self.vProperty.maskViewColor = UIColor.clear
            self.vProperty.touchWildToHide = "1"
            self.vProperty.popupViewEdgeInsets = UIEdgeInsetsMake(0, 0, UIScreen.main.bounds.height - self.leftBottomBtn.frame.minY - kStatusBarHeight - kNavBarHeight, 10)
            self.vProperty.topBottomMargin = 0
            self.vProperty.animationDuration = 0.3
            self.vProperty.popupArrowStyle = .round
            self.vProperty.popupArrowVertexScaleX = 0.8
            self.vProperty.cornerRadius = 5
            
            let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: images as? [UIImage], itemBlock: { (popupView, index, title) in
                print("Menu：点击了第\(index)个按钮")
            }, property: self.vProperty)
            menuView.show()
            break
            
        default:
            break
        }
    }
    
    @objc func barBtnAction(_ sender: Any) {
        
        self.menuView2.show()
    }
}
