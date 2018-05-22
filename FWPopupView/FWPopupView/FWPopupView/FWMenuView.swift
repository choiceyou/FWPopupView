//
//  FWMenuView.swift
//  FWPopupView
//
//  Created by xfg on 2018/5/19.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

/// 弹窗箭头的样式
///
/// - none: 无箭头
/// - round: 圆角
/// - triangle: 菱角
@objc public enum FWMenuArrowStyle: Int {
    case none
    case round
    case triangle
}


class FWMenuViewTableViewCell: UITableViewCell {
    
    var itemBtn: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.itemBtn = UIButton(type: .custom)
        self.itemBtn.backgroundColor = UIColor.clear
        self.itemBtn.isUserInteractionEnabled = false
        self.contentView.addSubview(self.itemBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContent(title: String?, image: UIImage?, property: FWMenuViewProperty) {
        self.itemBtn.frame = CGRect(x: property.letfRigthMargin, y: property.topBottomMargin, width: self.frame.width - property.letfRigthMargin * 2, height: self.frame.height - property.topBottomMargin * 2)
        
        self.itemBtn.contentHorizontalAlignment = property.contentHorizontalAlignment
        
        if image != nil {
            self.itemBtn.setImage(image!, for: .normal)
        }
        
        if title != nil {
            let attributedString = NSAttributedString(string: title!, attributes: property.titleTextAttributes)
            self.itemBtn.setAttributedTitle(attributedString, for: .normal)
        }
        
        if image != nil && title != nil {
            self.itemBtn.titleEdgeInsets = UIEdgeInsetsMake(0, property.commponentMargin, 0, 0)
        }
    }
}


open class FWMenuView: FWPopupView, UITableViewDelegate, UITableViewDataSource {
    
    /// 外部传入的标题数组
    private var itemTitleArray: [String]?
    /// 外部传入的图片数组
    private var itemImageNameArray: [UIImage]?
    
    /// 当前选中下标
    private var selectedIndex: Int = 0
    
    /// 最大的那一项的size
    private var maxItemSize: CGSize!
    
    /// 保存点击回调
    private var popupItemClickedBlock: FWPopupItemClickedBlock?
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)
        return tableView
    }()
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - itemTitles: 标题
    ///   - itemBlock: 点击回调
    /// - Returns: self
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: nil)
    }
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - itemTitles: 标题
    ///   - itemBlock: 点击回调
    ///   - property: 可设置参数
    /// - Returns: self
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: property)
    }
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - itemTitles: 标题
    ///   - itemImageNames: 图片
    ///   - itemBlock: 点击回调
    ///   - property: 可设置参数
    /// - Returns: self
    @objc open class func menu(itemTitles: [String]?, itemImageNames: [UIImage]?, itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) -> FWMenuView {
        
        let popupMenu = FWMenuView()
        popupMenu.setupUI(itemTitles: itemTitles, itemImageNames: itemImageNames, itemBlock: itemBlock, property: property)
        return popupMenu
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.vProperty = FWMenuViewProperty()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FWMenuView {
    
    private func setupUI(itemTitles: [String]?, itemImageNames: [UIImage]?, itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) {
        
        if itemTitles == nil && itemImageNames == nil {
            return
        }
        
        if property != nil {
            self.vProperty = property!
        } else {
            self.vProperty = FWMenuViewProperty()
        }
        
        self.backgroundColor = self.vProperty.backgroundColor
        if self.vProperty.maskViewColor != nil {
            self.attachedView?.fwMaskViewColor = self.vProperty.maskViewColor!
        }
        
        if self.vProperty.touchWildToHide != nil && !self.vProperty.touchWildToHide!.isEmpty {
            FWPopupWindow.sharedInstance.touchWildToHide = (Int(self.vProperty.touchWildToHide!) == 1) ? true : false
        }
        
        self.layer.cornerRadius = self.vProperty.cornerRadius
        self.clipsToBounds = true
        
        self.popupType = .custom
        
        self.itemTitleArray = itemTitles
        self.itemImageNameArray = itemImageNames
        
        self.popupItemClickedBlock = itemBlock
        
        self.maxItemSize = self.measureMaxSize()
        
        self.tableView.register(FWMenuViewTableViewCell.self, forCellReuseIdentifier: "cellId")
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.separatorColor = self.vProperty.splitColor
        self.tableView.layer.borderColor = self.vProperty.splitColor.cgColor
        self.tableView.layer.borderWidth = self.vProperty.splitWidth
        
        let property = self.vProperty as! FWMenuViewProperty
        
        var selfSize: CGSize = CGSize(width: 0, height: 0)
        if property.popupViewSize.width > 0 && property.popupViewSize.height > 0 {
            selfSize = property.popupViewSize
        } else if self.vProperty.popupViewMaxHeight > 0 && self.maxItemSize.height * CGFloat(self.itemsCount()) > self.vProperty.popupViewMaxHeight {
            selfSize = CGSize(width: self.maxItemSize.width, height: self.vProperty.popupViewMaxHeight)
        } else {
            selfSize = CGSize(width: self.maxItemSize.width, height: self.maxItemSize.height * CGFloat(self.itemsCount()))
        }
        self.frame = CGRect(x: 0, y: 0, width: selfSize.width, height: selfSize.height)
        self.tableView.frame = self.frame
    }
}

extension FWMenuView {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsCount()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.maxItemSize.height
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! FWMenuViewTableViewCell
        cell.setupContent(title: (self.itemTitleArray != nil) ? self.itemTitleArray![indexPath.row] : nil , image: (self.itemImageNameArray != nil) ? self.itemImageNameArray![indexPath.row] : nil, property: self.vProperty as! FWMenuViewProperty)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.hide()
        
        if self.popupItemClickedBlock != nil {
            self.popupItemClickedBlock!(self, indexPath.row)
        }
    }
}

extension FWMenuView {
    
    /// 计算控件的最大宽度、高度
    ///
    /// - Returns: CGSize
    fileprivate func measureMaxSize() -> CGSize {
        
        if self.itemTitleArray == nil && self.itemImageNameArray == nil {
            return CGSize(width: 0, height: 0)
        }
        
        let property = self.vProperty as! FWMenuViewProperty
        
        var titleSize = CGSize(width: 0, height: 0)
        var imageSize = CGSize(width: 0, height: 0)
        var totalMaxSize = CGSize(width: 0, height: 0)
        
        let titleAttrs = property.titleTextAttributes
        
        if self.itemTitleArray != nil {
            var tmpSize = CGSize(width: 0, height: 0)
            var index = 0
            for title: String in self.itemTitleArray! {
                titleSize = (title as NSString).size(withAttributes: titleAttrs)
                
                if self.itemImageNameArray != nil && self.itemImageNameArray!.count == self.itemTitleArray!.count {
                    let image = self.itemImageNameArray![index]
                    imageSize = image.size
                }
                tmpSize = CGSize(width: titleSize.width + imageSize.width, height: titleSize.height + imageSize.height)
                
                totalMaxSize.width = max(totalMaxSize.width, tmpSize.width)
                totalMaxSize.height = max(totalMaxSize.height, tmpSize.height)
                
                index += 1
            }
        } else if self.itemTitleArray == nil && self.itemImageNameArray != nil {
            for image: UIImage in self.itemImageNameArray! {
                imageSize = image.size
                
                totalMaxSize.width = max(totalMaxSize.width, imageSize.width)
                totalMaxSize.height = max(totalMaxSize.height, imageSize.height)
            }
        }
        
        totalMaxSize.width += property.letfRigthMargin * 2
        if self.itemTitleArray != nil && self.itemImageNameArray != nil {
            totalMaxSize.width += property.commponentMargin
        }
        
        totalMaxSize.height += property.topBottomMargin * 2
        
        totalMaxSize.width = ceil(totalMaxSize.width)
        totalMaxSize.height = ceil(totalMaxSize.height)
        
        return totalMaxSize
    }
    
    /// 计算总计行数
    ///
    /// - Returns: 行数
    fileprivate func itemsCount() -> Int {
        
        if self.itemTitleArray != nil {
            return self.itemTitleArray!.count
        } else if self.itemImageNameArray != nil {
            return self.itemImageNameArray!.count
        } else {
            return 0
        }
    }
}


/// FWMenuView的相关属性，请注意其父类中还有很多公共属性
open class FWMenuViewProperty: FWPopupViewProperty {
    
    /// 弹窗箭头的样式
    @objc public var menuArrowStyle: FWMenuArrowStyle = .none
    
    /// 弹窗大小，如果没有设置，将按照统一的计算方式
    @objc public var popupViewSize = CGSize(width: 0, height: 0)
    
    /// 未选中时按钮字体属性
    @objc public var titleTextAttributes: [NSAttributedStringKey: Any]!
    /// 选中时按钮字体属性
    @objc public var selectedTitleTextAttributes: [NSAttributedStringKey: Any]!
    
    /// 内容位置
    @objc public var contentHorizontalAlignment: UIControlContentHorizontalAlignment = .left
    
    public override init() {
        super.init()
        
        self.titleTextAttributes = [NSAttributedStringKey.foregroundColor: self.itemNormalColor, NSAttributedStringKey.backgroundColor: UIColor.clear, NSAttributedStringKey.font: UIFont.systemFont(ofSize: self.buttonFontSize)]
        
        self.selectedTitleTextAttributes = [NSAttributedStringKey.foregroundColor: self.itemNormalColor, NSAttributedStringKey.backgroundColor: UIColor.clear, NSAttributedStringKey.font: UIFont.systemFont(ofSize: self.buttonFontSize)]
        
        // 修改圆角默认值
        if self.menuArrowStyle == .none {
            self.cornerRadius = 0.0
        }
        
        self.letfRigthMargin = 20
        
        self.popupViewMaxHeight = UIScreen.main.bounds.height * CGFloat(0.7)
        
    }
}

