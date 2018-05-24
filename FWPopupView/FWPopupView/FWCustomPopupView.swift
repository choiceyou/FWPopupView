//
//  FWCustomPopupView.swift
//  FWPopupView
//
//  Created by xfg on 2018/5/23.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWCustomPopupView: FWPopupView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        // 注意：必须得告诉父类现在用的是自定义弹窗方式，不然程序会崩掉
        self.popupType = .custom
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
