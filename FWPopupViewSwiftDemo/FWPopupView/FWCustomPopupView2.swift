//
//  FWCustomPopupView2.swift
//  FWPopupView
//
//  Created by xfg on 2020/5/29.
//  Copyright © 2020 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWCustomPopupView2: FWPopupView {
    
    var contentView:UIView!

    // 初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadViewFromNib()
        contentView.frame = self.bounds
        self.insertSubview(contentView, at: 0)
    }

    // 初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 加载xib
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.backgroundColor = UIColor.clear
        return view
    }
}
