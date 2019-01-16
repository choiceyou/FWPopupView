//
//  FWMenuView.swift
//  FWPopupView
//
//  Created by xfg on 2018/5/19.
//  Copyright © 2018年 xfg. All rights reserved.
//  仿QQ、微信菜单

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

class FWMenuViewTableViewCell: UITableViewCell {
    
    var itemBtn: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        self.selectionStyle = property.selectionStyle
        
        if image != nil {
            self.itemBtn.setImage(image!, for: .normal)
        }
        
        if title != nil {
            let attributedString = NSAttributedString(string: title!, attributes: property.titleTextAttributes)
            let selectedAttributedString = NSAttributedString(string: title!, attributes: property.selectedTitleTextAttributes)
            self.itemBtn.setAttributedTitle(attributedString, for: .normal)
            self.itemBtn.setAttributedTitle(selectedAttributedString, for: .highlighted)
        }
        
        if image != nil && title != nil {
            self.itemBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: property.commponentMargin, bottom: 0, right: 0)
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
        
        self.clipsToBounds = true
        
        self.itemTitleArray = itemTitles
        self.itemImageNameArray = itemImageNames
        
        self.popupItemClickedBlock = itemBlock
        
        let property = self.vProperty as! FWMenuViewProperty
        
        self.maxItemSize = self.measureMaxSize()
        if property.popupViewItemHeight > 0 {
            self.maxItemSize.height = property.popupViewItemHeight
        }
        
        self.tableView.register(FWMenuViewTableViewCell.self, forCellReuseIdentifier: "cellId")
        self.tableView.separatorInset = property.separatorInset
        self.tableView.layoutMargins = property.separatorInset
        self.tableView.separatorColor = property.separatorColor
        self.tableView.backgroundColor = self.backgroundColor
        self.tableView.bounces = property.bounces
        
        var selfY: CGFloat = 0
        switch property.popupArrowStyle {
        case .none:
            selfY = 0
            self.layer.cornerRadius = self.vProperty.cornerRadius
            self.layer.borderColor = self.vProperty.splitColor.cgColor
            self.layer.borderWidth = self.vProperty.splitWidth
            break
        case .round, .triangle:
            selfY = property.popupArrowSize.height
            break
        }
        
        // 箭头方向
        var isUpArrow = true
        switch property.popupCustomAlignment {
        case .bottom, .bottomLeft, .bottomRight, .bottomCenter:
            isUpArrow = false
            break
        default:
            isUpArrow = true
            break
        }
        
        var selfSize: CGSize = CGSize(width: 0, height: 0)
        
        if property.popupViewSize.width > 0 && property.popupViewSize.height > 0 {
            selfSize = property.popupViewSize
        } else if self.vProperty.popupViewMaxHeight > 0 && self.maxItemSize.height * CGFloat(self.itemsCount()) > self.vProperty.popupViewMaxHeight {
            selfSize = CGSize(width: self.maxItemSize.width, height: self.vProperty.popupViewMaxHeight)
        } else {
            selfSize = CGSize(width: self.maxItemSize.width, height: self.maxItemSize.height * CGFloat(self.itemsCount()))
        }
        selfSize.height += selfY
        self.frame = CGRect(x: 0, y: selfY, width: selfSize.width, height: selfSize.height)
        self.tableView.frame = CGRect(x: 0, y: isUpArrow ? selfY : 0, width: selfSize.width, height: selfSize.height)
        
        // 用来隐藏多余的线条，不想自定义线条
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 1))
        footerView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = footerView
        
        // 绘制箭头
        if property.popupArrowStyle != .none {
            
            // 圆角值
            let cornerRadius = property.cornerRadius
            /// 箭头的尺寸
            let arrowSize = property.popupArrowSize
            
            if property.popupArrowVertexScaleX > 1 {
                property.popupArrowVertexScaleX = 1
            } else if property.popupArrowVertexScaleX < 0 {
                property.popupArrowVertexScaleX = 0
            }
            
            // 弹窗箭头顶点坐标
            let arrowPoint = CGPoint(x: (self.frame.width - arrowSize.width - cornerRadius * 2) * property.popupArrowVertexScaleX + arrowSize.width/2 + cornerRadius, y: isUpArrow ? 0 : self.frame.height)
            
            // 顶部Y值
            let maskTop = isUpArrow ? arrowSize.height : 0
            // 底部Y值
            let maskBottom = isUpArrow ? self.frame.height : self.frame.height - arrowSize.height
            
            // 开始画贝塞尔曲线
            let maskPath = UIBezierPath()
            
            // 左上圆角
            maskPath.move(to: CGPoint(x: 0, y: cornerRadius + maskTop))
            maskPath.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius + maskTop), radius: cornerRadius, startAngle: self.degreesToRadians(angle: 180), endAngle: self.degreesToRadians(angle: 270), clockwise: true)
            
            // 箭头向上时的箭头位置
            if isUpArrow {
                maskPath.addLine(to: CGPoint(x: arrowPoint.x - arrowSize.width/2, y: arrowSize.height))
                
                if property.popupArrowStyle == .triangle { // 菱角箭头
                    maskPath.addLine(to: arrowPoint)
                    maskPath.addLine(to: CGPoint(x: arrowPoint.x + arrowSize.width/2, y: arrowSize.height))
                } else { // 圆角箭头
                    maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x - property.popupArrowCornerRadius, y: property.popupArrowCornerRadius), controlPoint: CGPoint(x: arrowPoint.x - arrowSize.width/2 + property.popupArrowBottomCornerRadius, y: arrowSize.height))
                    maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x + property.popupArrowCornerRadius, y: property.popupArrowCornerRadius), controlPoint: arrowPoint)
                    maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x + arrowSize.width/2, y: arrowSize.height), controlPoint: CGPoint(x: arrowPoint.x + arrowSize.width/2 - property.popupArrowBottomCornerRadius, y: arrowSize.height))
                }
            }
            
            // 右上圆角
            maskPath.addLine(to: CGPoint(x: self.frame.width - cornerRadius, y: maskTop))
            maskPath.addArc(withCenter: CGPoint(x: self.frame.width - cornerRadius, y: maskTop + cornerRadius), radius: cornerRadius, startAngle: self.degreesToRadians(angle: 270), endAngle: self.degreesToRadians(angle: 0), clockwise: true)
            
            // 右下圆角
            maskPath.addLine(to: CGPoint(x: self.frame.width, y: maskBottom - cornerRadius))
            maskPath.addArc(withCenter: CGPoint(x: self.frame.width - cornerRadius, y: maskBottom - cornerRadius), radius: cornerRadius, startAngle: self.degreesToRadians(angle: 0), endAngle: self.degreesToRadians(angle: 90), clockwise: true)
            
            // 箭头向下时的箭头位置
            if !isUpArrow {
                maskPath.addLine(to: CGPoint(x: arrowPoint.x + arrowSize.width/2, y:self.frame.height - arrowSize.height))
                
                if property.popupArrowStyle == .triangle { // 菱角箭头
                    maskPath.addLine(to: arrowPoint)
                    maskPath.addLine(to: CGPoint(x: arrowPoint.x - arrowSize.width/2, y: self.frame.height - arrowSize.height))
                } else { // 圆角箭头
                    maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x + property.popupArrowCornerRadius, y: self.frame.height -  property.popupArrowCornerRadius), controlPoint: CGPoint(x: arrowPoint.x + arrowSize.width/2 - property.popupArrowBottomCornerRadius, y: self.frame.height - arrowSize.height))
                    
                    maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x - property.popupArrowCornerRadius, y: self.frame.height - property.popupArrowCornerRadius), controlPoint: arrowPoint)
                    
                    maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x - arrowSize.width/2, y: self.frame.height - arrowSize.height), controlPoint: CGPoint(x: arrowPoint.x - arrowSize.width/2 + property.popupArrowBottomCornerRadius, y: self.frame.height - arrowSize.height))
                }
            }
            
            // 左下圆角
            maskPath.addLine(to: CGPoint(x: cornerRadius, y: maskBottom))
            maskPath.addArc(withCenter: CGPoint(x: cornerRadius, y: maskBottom - cornerRadius), radius: cornerRadius, startAngle: self.degreesToRadians(angle: 90), endAngle: self.degreesToRadians(angle: 180), clockwise: true)
            
            maskPath.close()
            
            // 截取圆角和箭头
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = maskPath.cgPath
            self.layer.mask = maskLayer
            
            // 边框
            let borderLayer = CAShapeLayer()
            borderLayer.frame = self.bounds
            borderLayer.path = maskPath.cgPath
            borderLayer.lineWidth = 1
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = property.splitColor.cgColor
            self.layer.addSublayer(borderLayer)
        }
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
        cell.backgroundColor = self.vProperty.backgroundColor
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.hide()
        
        if self.popupItemClickedBlock != nil {
            self.popupItemClickedBlock!(self, indexPath.row, (self.itemTitleArray != nil) ? self.itemTitleArray![indexPath.row] : nil)
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
    
    /// 角度转换
    ///
    /// - Parameter angle: 传入的角度值
    /// - Returns: CGFloat
    fileprivate func degreesToRadians(angle: CGFloat) -> CGFloat {
        return angle * CGFloat(Double.pi) / 180
    }
}


/// FWMenuView的相关属性，请注意其父类中还有很多公共属性
open class FWMenuViewProperty: FWPopupViewProperty {
    
    /// 弹窗大小，如果没有设置，将按照统一的计算方式
    @objc public var popupViewSize = CGSize(width: 0, height: 0)
    
    /// 指定行高优先级 > 自动计算的优先级
    @objc public var popupViewItemHeight: CGFloat = 0
    
    /// 未选中时按钮字体属性
    @objc public var titleTextAttributes: [NSAttributedString.Key: Any]!
    /// 选中时按钮字体属性
    @objc public var selectedTitleTextAttributes: [NSAttributedString.Key: Any]!
    
    /// 内容位置
    @objc public var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .left
    /// 选中风格
    @objc public var selectionStyle: UITableViewCell.SelectionStyle = .none
    
    /// 分割线颜色
    @objc public var separatorColor: UIColor = kPV_RGBA(r: 231, g: 231, b: 231, a: 1)
    /// 分割线偏移量
    @objc public var separatorInset: UIEdgeInsets = UIEdgeInsets.zero
    
    /// 是否开启tableview回弹效果
    @objc public var bounces: Bool = false
    
    public override func reSetParams() {
        super.reSetParams()
        
        self.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.itemNormalColor, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.buttonFontSize)]
        
        self.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: self.itemNormalColor, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.buttonFontSize)]
        
        self.letfRigthMargin = 20
        
        self.popupViewMaxHeight = UIScreen.main.bounds.height * CGFloat(0.7)
    }
}

