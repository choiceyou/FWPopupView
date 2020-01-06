//
//  FWPopupRootViewController.swift
//  FWPopupView
//
//  Created by xfg on 2018/12/3.
//  Copyright © 2018 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWPopupRootViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarStyle ?? UIStatusBarStyle.default
        } else {
            return UIApplication.shared.statusBarStyle
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.isStatusBarHidden ?? false
        } else {
            return UIApplication.shared.isStatusBarHidden
        }
    }
}
