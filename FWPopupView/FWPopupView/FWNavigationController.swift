//
//  FWNavigationController.swift
//  FanweApps
//
//  Created by xfg on 2018/1/23.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

let navTitleFont: CGFloat = 18.0
/// 无参数闭包
typealias FWVoidBlock = ()->Void

class FWNavigationController: UINavigationController {
    
    /// 点击某个VC的返回按钮的回调
    var vcBackActionBlock: FWVoidBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttrs = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: navTitleFont)]
        navigationBar.titleTextAttributes = textAttrs
        
        navigationBar.setBackgroundImage(FWNavigationController.resizableImage(imageName: "header_bg_message", edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)), for: .default)
        navigationBar.isTranslucent = false
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = []
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.children.count > 0 {
            
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "com_arrow_vc_back"), for: .normal)
            button.setImage(UIImage(named: "com_arrow_vc_back"), for: .highlighted)
            button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitleColor(.red, for: .highlighted)
            button.sizeToFit()
            // button.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
            button.contentHorizontalAlignment = .left
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
            
            button.frame = CGRect(x: 0, y: 0, width: (button.currentImage?.size.width)!+15, height: (button.currentImage?.size.height)!+5)
            viewController.navigationItem.leftBarButtonItem?.customView?.frame = button.frame
            
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if self.topViewController != nil {
                return self.topViewController!.preferredStatusBarStyle
            } else {
                return .default
            }
        }
    }
}

extension FWNavigationController {
    
    @objc func backAction() {
        self.popViewController(animated: true)
        
        if self.vcBackActionBlock != nil {
            vcBackActionBlock!()
        }
    }
    
    class func resizableImage(imageName: String, edgeInsets: UIEdgeInsets) -> UIImage? {
        
        let image = UIImage(named: imageName)
        if image == nil {
            return nil
        }
        let imageW = image!.size.width
        let imageH = image!.size.height
        
        return image?.resizableImage(withCapInsets: UIEdgeInsets(top: imageH * edgeInsets.top, left: imageW * edgeInsets.left, bottom: imageH * edgeInsets.bottom, right: imageW * edgeInsets.right), resizingMode: .stretch)
    }
}
