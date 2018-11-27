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
    
    let titles = ["创建群聊", "加好友/群", "扫一扫", "面对面快传", "付款", "拍摄"]
    let images = [UIImage(named: "right_menu_multichat"),
                  UIImage(named: "right_menu_addFri"),
                  UIImage(named: "right_menu_QR"),
                  UIImage(named: "right_menu_facetoface"),
                  UIImage(named: "right_menu_payMoney"),
                  UIImage(named: "right_menu_sendvideo")]
    
    let images2 = [UIImage(named: "right_menu_multichat_white"),
                   UIImage(named: "right_menu_addFri_white"),
                   UIImage(named: "right_menu_QR_white"),
                   UIImage(named: "right_menu_facetoface_white"),
                   UIImage(named: "right_menu_payMoney_white"),
                   UIImage(named: "right_menu_sendvideo_white")]
    
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
        vProperty.backgroundColor = kPV_RGBA(r: 64, g: 63, b: 66, a: 1)
        vProperty.splitColor = kPV_RGBA(r: 64, g: 63, b: 66, a: 1)
        vProperty.separatorColor = kPV_RGBA(r: 91, g: 91, b: 93, a: 1)
        vProperty.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.clear, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)]
        vProperty.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        
        let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: images2 as? [UIImage], itemBlock: { (popupView, index, title) in
            print("Menu：点击了第\(index)个按钮")
        }, property: vProperty)
        //                menuView.attachedView = self.view
        
        return menuView
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
        
        centerBtn = self.setupBtn(title: "中间按钮", frame: CGRect(x: (UIScreen.main.bounds.width - 100)/2, y: UIScreen.main.bounds.height * 0.25, width: 100, height: 50), tag: 1) as? UIButton
        self.view.addSubview(centerBtn)
        
        leftBottomBtn = self.setupBtn(title: "左下角按钮", frame: CGRect(x: 10, y: UIScreen.main.bounds.height * 0.8, width: 100, height: 50), tag: 2) as? UIButton
        self.view.addSubview(leftBottomBtn)
        
        rightBottomBtn = self.setupBtn(title: "右下角按钮", frame: CGRect(x: UIScreen.main.bounds.width - 110, y: UIScreen.main.bounds.height * 0.8, width: 100, height: 50), tag: 3) as? UIButton
        self.view.addSubview(rightBottomBtn)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{get { return .lightContent}}
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
            let property = FWMenuViewProperty()
            property.popupCustomAlignment = .topCenter
            property.popupAnimationType = .scale
            property.maskViewColor = UIColor.clear
            property.touchWildToHide = "1"
            property.popupViewEdgeInsets = UIEdgeInsetsMake(self.centerBtn.frame.maxY + kStatusBarHeight + kNavBarHeight, 0, 0, 0)
            property.topBottomMargin = 10
            property.animationDuration = 0.3
            property.popupArrowStyle = .round
            property.popupArrowVertexScaleX = 0.5
            property.cornerRadius = 5
            
            let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: nil, itemBlock: { (popupView, index, title) in
                print("Menu：点击了第\(index)个按钮")
            }, property: property)
            menuView.show()
            break
            
        case 2:
            let property = FWMenuViewProperty()
            property.popupCustomAlignment = .bottomLeft
            property.popupAnimationType = .frame
            property.maskViewColor = UIColor(white: 0, alpha: 0.4)
            property.touchWildToHide = "1"
            property.popupViewEdgeInsets = UIEdgeInsetsMake(0, 10, UIScreen.main.bounds.height - self.leftBottomBtn.frame.minY - kStatusBarHeight - kNavBarHeight, 0)
            property.topBottomMargin = 10
            property.animationDuration = 0.3
            property.popupArrowStyle = .none
            property.popupArrowVertexScaleX = 0.5
            property.cornerRadius = 0
            
            let titles = ["Menu0", "Menu1", "Menu2", "Menu3", "Menu4", "Menu5", "Menu6", "Menu7", "Menu8", "Menu9", "Menu10", "Menu11", "Menu12", "Menu13", "Menu14", "Menu15", "Menu16"]
            let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: nil, itemBlock: { (popupView, index, title) in
                print("Menu：点击了第\(index)个按钮")
            }, property: property)
            menuView.show()
            break
            
        case 3:
            let property = FWMenuViewProperty()
            property.popupCustomAlignment = .bottomRight
            property.popupAnimationType = .scale
            property.maskViewColor = UIColor.clear
            property.touchWildToHide = "1"
            property.popupViewEdgeInsets = UIEdgeInsetsMake(0, 0, UIScreen.main.bounds.height - self.leftBottomBtn.frame.minY - kStatusBarHeight - kNavBarHeight, 10)
            property.topBottomMargin = 0
            property.animationDuration = 0.3
            property.popupArrowStyle = .round
            property.popupArrowVertexScaleX = 0.8
            property.cornerRadius = 5
            
            let menuView = FWMenuView.menu(itemTitles: titles, itemImageNames: images as? [UIImage], itemBlock: { (popupView, index, title) in
                print("Menu：点击了第\(index)个按钮")
            }, property: property)
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
