//
//  FWCustomSheetView.swift
//  FWPopupView
//
//  Created by xfg on 2018/11/1.
//  Copyright © 2018 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWCustomSheetViewTableViewCell: UITableViewCell {
    
    var imgView: UIImageView!
    var titleLabel: UILabel!
    var secondaryTitleLabel: UILabel!
    var line: CALayer!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.imgView = UIImageView()
        self.addSubview(self.imgView)
        
        self.titleLabel = UILabel()
        self.titleLabel.numberOfLines = 1
        self.addSubview(self.titleLabel)
        
        self.secondaryTitleLabel = UILabel()
        self.secondaryTitleLabel.numberOfLines = 1
        self.addSubview(self.secondaryTitleLabel)
        
        self.line = CALayer()
        self.layer.addSublayer(self.line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContent(title: String?, secondaryTitle: String?, image: UIImage?, property: FWCustomSheetViewProperty) {
        self.selectionStyle = property.selectionStyle
        
        self.line.frame = CGRect(x: property.separatorInset.left, y: ceil(self.frame.height-property.splitWidth), width: self.frame.width-property.separatorInset.left-property.separatorInset.right, height: property.splitWidth)
        self.line.backgroundColor = property.splitColor.cgColor
        
        var leftMargin = property.letfRigthMargin
        
        if image != nil {
            self.imgView.frame = CGRect(x: leftMargin, y: (self.frame.height-image!.size.height)/2, width: image!.size.width, height: image!.size.height)
            self.imgView.image = image
            
            leftMargin += self.imgView.frame.width + property.commponentMargin
        }
        
        if title != nil && secondaryTitle != nil && !secondaryTitle!.isEmpty {
            let attributedString = NSAttributedString(string: title!, attributes: property.titleTextAttributes)
            let secondaryAttributedString = NSAttributedString(string: secondaryTitle!, attributes: property.secondaryTitleTextAttributes)
            
            let titleSize = (title! as NSString).size(withAttributes: property.titleTextAttributes)
            let secondaryTitleSize = (title! as NSString).size(withAttributes: property.secondaryTitleTextAttributes)
            
            self.titleLabel.frame = CGRect(x: leftMargin, y: (self.frame.height-property.commponentMargin/2-titleSize.height-secondaryTitleSize.height)/2, width: self.frame.width-leftMargin-property.letfRigthMargin*2, height: titleSize.height)
            self.titleLabel.attributedText = attributedString
            
            self.secondaryTitleLabel.frame = CGRect(x: leftMargin, y: self.titleLabel.frame.maxY+property.commponentMargin/2, width: self.frame.width-leftMargin-property.letfRigthMargin*2, height: secondaryTitleSize.height)
            self.secondaryTitleLabel.attributedText = secondaryAttributedString
        } else if title != nil && (secondaryTitle == nil || secondaryTitle!.isEmpty) {
            let attributedString = NSAttributedString(string: title!, attributes: property.titleTextAttributes)
            
            let titleSize = (title! as NSString).size(withAttributes: property.titleTextAttributes)
            
            self.titleLabel.frame = CGRect(x: leftMargin, y: (self.frame.height-titleSize.height)/2, width: self.frame.width-leftMargin-property.letfRigthMargin*2, height: titleSize.height)
            self.titleLabel.attributedText = attributedString
            
            // 防止复用产生问题
            self.secondaryTitleLabel.text = nil
        }
    }
}


open class FWCustomSheetView: FWPopupView, UITableViewDelegate, UITableViewDataSource {
    
    /// 当前选中下标
    @objc open var currentSelectedIndex: Int = 0
    /// 上一次选中的下标
    private var lastTimeSelectedIndex: Int = 0
    
    /// 外部传入的标题数组
    private var itemTitleArray: [String]?
    /// 外部传入的副标题数组
    private var itemSecondaryTitleArray: [String]?
    /// 外部传入的图片数组
    private var itemImageNameArray: [UIImage]?
    
    /// 头部视图
    private var headerView: UIView?
    
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
    ///   - headerTitle: 头部标题。注意：传入空字符串或者字符串菜显示该头部，反之，传nil表示不显示头部
    ///   - itemTitles: 标题
    ///   - itemSecondaryTitles: 副标题。注意：一定是现有标题才会有副标题
    ///   - itemImages: 图片
    ///   - itemBlock: 点击回调
    ///   - property: 可设置参数
    /// - Returns: self
    @objc open class func sheet(headerTitle: String?, itemTitles: [String]?, itemSecondaryTitles: [String]?, itemImages: [UIImage]?, itemBlock: FWPopupItemClickedBlock? = nil, property: FWCustomSheetViewProperty?) -> FWCustomSheetView {
        
        let customSheet = FWCustomSheetView()
        customSheet.setupUI(headerTitle: headerTitle, itemTitles: itemTitles, itemSecondaryTitles: itemSecondaryTitles, itemImages: itemImages, itemBlock: itemBlock, property: property)
        return customSheet
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.vProperty = FWCustomSheetViewProperty()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FWCustomSheetView {
    
    private func setupUI(headerTitle: String?, itemTitles: [String]?, itemSecondaryTitles: [String]?, itemImages: [UIImage]?, itemBlock: FWPopupItemClickedBlock? = nil, property: FWCustomSheetViewProperty?) {
        
        if itemTitles == nil && itemImages == nil {
            return
        }
        
        if property != nil {
            self.vProperty = property!
        } else {
            self.vProperty = FWCustomSheetViewProperty()
        }
        
        self.clipsToBounds = true
        
        self.itemTitleArray = itemTitles
        self.itemSecondaryTitleArray = itemSecondaryTitles
        self.itemImageNameArray = itemImages
        
        self.popupItemClickedBlock = itemBlock
        
        let property = self.vProperty as! FWCustomSheetViewProperty
        var selfSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        self.currentSelectedIndex = property.selectedIndex
        self.lastTimeSelectedIndex = property.selectedIndex
        
        // 绘制头部视图
        if headerTitle != nil {
            self.headerView = UIView(frame: CGRect(x: 0, y: 0, width: selfSize.width, height: property.headerViewHeight))
            self.headerView?.backgroundColor = self.vProperty.backgroundColor
            self.addSubview(self.headerView!)
            
            let line = CALayer()
            line.frame = CGRect(x: 0, y: floor(property.headerViewHeight-property.splitWidth), width: selfSize.width, height: property.splitWidth)
            line.backgroundColor = property.splitColor.cgColor
            self.headerView!.layer.addSublayer(line)
            
            let titleLabel = UILabel(frame: CGRect(x: property.letfRigthMargin, y: 0, width: selfSize.width-property.letfRigthMargin*3, height: property.headerViewHeight))
            self.headerView!.addSubview(titleLabel)
            titleLabel.attributedText = NSAttributedString(string: headerTitle!, attributes: property.titleTextAttributes)
            
            let closeBtn = UIButton(frame: CGRect(x: selfSize.width-(property.headerViewHeight-2)-property.letfRigthMargin/2, y: 1, width: property.headerViewHeight-2, height: property.headerViewHeight-2))
            closeBtn.backgroundColor = UIColor.clear
            closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            self.headerView!.addSubview(closeBtn)
            if property.closeImage != nil {
                closeBtn.setImage(property.choiceImage!, for: .normal)
            } else {
                let url = Bundle(for: FWCustomSheetView.self).url(forResource: "FWPopupView", withExtension: "bundle")
                if url != nil {
                    let imageBundle = Bundle(url: url!)
                    let path = imageBundle?.path(forResource: "cs_close@3x", ofType: "png")
                    if path != nil {
                        closeBtn.setImage(UIImage(contentsOfFile: path!), for: .normal)
                    }
                }
            }
        } else {
            property.headerViewHeight = 0
        }
        
        property.popupCustomAlignment = .bottomCenter
        property.popupAnimationType = .position
        
        self.tableView.register(FWCustomSheetViewTableViewCell.self, forCellReuseIdentifier: "cellId")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = self.backgroundColor
        self.tableView.bounces = property.bounces
        
        if property.popupViewMaxHeightRate > 0 && property.popupViewItemHeight * CGFloat(self.itemsCount()) > property.popupViewMaxHeightRate*self.superview!.frame.size.height  {
            selfSize.height = property.popupViewMaxHeightRate*self.superview!.frame.size.height
        } else if property.popupViewMinHeight > 0 && property.popupViewItemHeight * CGFloat(self.itemsCount()) < property.popupViewMinHeight {
            selfSize.height = property.popupViewMinHeight
        } else {
            selfSize.height = property.popupViewItemHeight * CGFloat(self.itemsCount())
        }
        selfSize.height += property.headerViewHeight
        self.frame = CGRect(x: 0, y: 0, width: selfSize.width, height: selfSize.height)
        self.tableView.frame = CGRect(x: 0, y: property.headerViewHeight, width: selfSize.width, height: selfSize.height-property.headerViewHeight)
        
        // 用来隐藏多余的线条，不想自定义线条
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 1))
        footerView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = footerView
    }
}

extension FWCustomSheetView {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsCount()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let property = self.vProperty as! FWCustomSheetViewProperty
        return property.popupViewItemHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! FWCustomSheetViewTableViewCell
        cell.setupContent(title: (self.itemTitleArray != nil) ? self.itemTitleArray![indexPath.row] : nil, secondaryTitle: (self.itemSecondaryTitleArray != nil) ? self.itemSecondaryTitleArray![indexPath.row] : nil,  image: (self.itemImageNameArray != nil) ? self.itemImageNameArray![indexPath.row] : nil, property: self.vProperty as! FWCustomSheetViewProperty)
        cell.backgroundColor = self.vProperty.backgroundColor
        
        let property = self.vProperty as! FWCustomSheetViewProperty
        if property.lastNeedAccessoryView == true && indexPath.row == (self.itemsCount()-1) {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.row == self.currentSelectedIndex {
            if cell.accessoryView == nil {
                if property.choiceImage != nil {
                    cell.accessoryView = UIImageView(image: property.choiceImage!)
                } else {
                    let url = Bundle(for: FWCustomSheetView.self).url(forResource: "FWPopupView", withExtension: "bundle")
                    if url != nil {
                        let imageBundle = Bundle(url: url!)
                        let path = imageBundle?.path(forResource: "cs_choice@3x", ofType: "png")
                        if path != nil {
                            cell.accessoryView = UIImageView(image: UIImage(contentsOfFile: path!))
                        }
                    }
                }
            }
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.hide()
        
        let property = self.vProperty as! FWCustomSheetViewProperty
        if !(property.lastNeedAccessoryView == true && indexPath.row == (self.itemsCount()-1)) {
            self.lastTimeSelectedIndex = self.currentSelectedIndex
            self.currentSelectedIndex = indexPath.row
        }
        
        self.tableView.reloadData()
        
        if self.popupItemClickedBlock != nil {
            self.popupItemClickedBlock!(self, indexPath.row, (self.itemTitleArray != nil) ? self.itemTitleArray![indexPath.row] : nil)
        }
    }
}

extension FWCustomSheetView {
    
    /// 更改当前选中的下标
    ///
    /// - Parameter backToLastChoice: true：回到上一次选择的下标 false：-1，表示没有选中的了
    @objc open func changeSelectedIndex(backToLastChoice: Bool) {
        if backToLastChoice {
            self.currentSelectedIndex = self.lastTimeSelectedIndex
        } else {
            self.currentSelectedIndex = -1
        }
        self.tableView.reloadData()
    }
    
    /// 计算总计行数
    ///
    /// - Returns: 行数
    fileprivate func itemsCount() -> Int {
        
        if self.itemTitleArray != nil {
            return self.itemTitleArray!.count
        } else if self.itemSecondaryTitleArray != nil {
            return self.itemSecondaryTitleArray!.count
        }  else if self.itemImageNameArray != nil {
            return self.itemImageNameArray!.count
        } else {
            return 0
        }
    }
    
    /// 角度转换
    ///
    /// - Parameter angle: 传入的角度值
    /// - Returns: CGFloat
    fileprivate func degreesToRadians(angle: CGFloat) -> CGFloat {
        return angle * CGFloat(Double.pi) / 180
    }
    
    @objc private func closeAction() {
        self.hide()
    }
}


/// FWCustomSheetView的相关属性，请注意其父类中还有很多公共属性
open class FWCustomSheetViewProperty: FWPopupViewProperty {
    
    /// 弹窗的最小高度，0：表示不限制
    @objc open var popupViewMinHeight: CGFloat = 200
    
    /// 指定行高
    @objc public var popupViewItemHeight: CGFloat = 60
    
    /// 头部视图高度
    @objc public var headerViewHeight: CGFloat = 40
    
    /// 默认选中下标，如果传入小于0或者大于当前数据源的数值，则不会有对应的行选中，如：传入-1则表示当前表格中没有默认选中的
    @objc public var selectedIndex: NSInteger = 0
    
    /// 最后一项是否需要AccessoryView
    @objc public var lastNeedAccessoryView: Bool = false
    
    /// 关闭按钮图标
    @objc public var closeImage: UIImage?
    /// 选中项对应的图标
    @objc public var choiceImage: UIImage?
    
    /// 标题字体属性
    @objc public var titleTextAttributes: [NSAttributedString.Key: Any]!
    /// 副标题字体属性
    @objc public var secondaryTitleTextAttributes: [NSAttributedString.Key: Any]!
    
    /// 内容位置
    @objc public var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .left
    /// 选中风格
    @objc public var selectionStyle: UITableViewCell.SelectionStyle = .none
    
    /// 分割线颜色
    @objc public var separatorColor: UIColor = kPV_RGBA(r: 231, g: 231, b: 231, a: 1)
    /// 分割线偏移量
    @objc public var separatorInset: UIEdgeInsets = UIEdgeInsets.zero
    
    /// 是否开启tableview回弹效果
    @objc public var bounces: Bool = true
    
    public override func reSetParams() {
        super.reSetParams()
        
        self.buttonFontSize = 15
        
        self.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.itemNormalColor, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.buttonFontSize)]
        
        let tmpColor = kPV_RGBA(r: 138, g: 146, b: 165, a: 1)
        self.secondaryTitleTextAttributes = [NSAttributedString.Key.foregroundColor: tmpColor, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        
        self.letfRigthMargin = 20
        
        self.popupViewMaxHeightRate = 0.7
        
        self.touchWildToHide = "1"
    }
}
