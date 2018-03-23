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
        
        let items = [FWPopupItem(title: "Done", itemType: .normal, isCancel: false, handler: block),
                     FWPopupItem(title: "Cancel", itemType: .normal, isCancel: true, handler: block)]
        
        let customView = UILabel(frame: CGRect(x: 0, y: 0, width: 255, height: 60))
        customView.text = "自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图自定义视图"
        customView.textColor = UIColor.red
        customView.textAlignment = .center
        customView.font = UIFont.boldSystemFont(ofSize: 14.0)
        customView.numberOfLines = 5
        customView.backgroundColor = UIColor.clear
        
        let alertView = FWAlertView.alert(title: "测试", detail: "开始测试了哦开始测试了哦", inputPlaceholder: nil, customView: customView, items: items)
        alertView.attachedView = self.view
        alertView.show(completionBlock: completeBlock)
        
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

