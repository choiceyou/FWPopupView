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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
