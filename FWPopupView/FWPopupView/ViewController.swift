//
//  ViewController.swift
//  FWPopupView
//
//  Created by xfg on 2018/3/19.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {

    let block: FWPopupItemHandler = { (index) in
        print(index)
    }
    
    let completeBlock: FWPopupCompletionBlock = { (popupView, isCompletion) in
        print(popupView)
    }
    
    @IBAction func alertAction(_ sender: Any) {
        
//        let items = [FWPopupItem(title: "取消", itemType: .normal, isCancel: true, handler: block),
//            FWPopupItem(title: "确定", itemType: .normal, isCancel: false, handler: block)]
//
//        let customView = UILabel(frame: CGRect(x: 0, y: 0, width: 255, height: 60))
//        customView.text = "自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图"
//        customView.textColor = UIColor.red
//        customView.textAlignment = .center
//        customView.font = UIFont.boldSystemFont(ofSize: 14.0)
//        customView.numberOfLines = 5
//        customView.backgroundColor = UIColor.clear
//
//        let alertView = FWAlertView.alert(title: "测试", detail: "开始测试了哦", inputPlaceholder: "", customView: nil, items: items)
//        alertView.attachedView = self.view
//        alertView.show(completionBlock: completeBlock)
        
//        let alertView2 = FWAlertView.alert(title: "测试", detail: "开始测试了哦", confirmBlock: { (index) in
//            print("1111111111")
//        }) { (index) in
//            print("2222222")
//        }
//        alertView2.show()
        
        let alertView2 = FWAlertView.alert(title: "测试", detail: "开始测试了哦") { (index) in
            print("1111111111")
        }
        alertView2.attachedView?.fwBackgroundViewColor = UIColor(white: 0.5, alpha: 0.5)
        alertView2.show()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FWPopupWindow.sharedInstance.touchWildToHide = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

