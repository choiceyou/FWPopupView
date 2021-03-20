//
//  FWPColorCategory.swift
//  FWPopupView
//
//  Created by xfg on 2021/3/17.
//  Copyright © 2021 xfg. All rights reserved.
//

import Foundation
import UIKit

public func kPV_RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

extension UIColor {
    /// 适配暗黑模式：设置颜色方法
    /// - Parameters:
    ///   - lightColor: 浅色模式颜色
    ///   - darkColor: 深色模式颜色
    /// - Returns: 颜色
    open class func fw_colorWithStyleColors(lightColor: UIColor?, darkColor: UIColor?) -> UIColor {
        if #available(iOS 13.0, *), FWPopupSWindow.sharedInstance.compatibleDarkStyle == true {
            return UIColor.init { (tc: UITraitCollection) -> UIColor in
                if tc.userInterfaceStyle == .light {
                    return (lightColor != nil) ? lightColor! : ((darkColor != nil) ? darkColor! : UIColor.clear)
                } else {
                    return (darkColor != nil) ? darkColor! : ((lightColor != nil) ? lightColor! : UIColor.clear)
                }
            }
        } else {
            return (lightColor != nil) ? lightColor! : ((darkColor != nil) ? darkColor! : UIColor.clear)
        }
    }
}
