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
    
    var iconImgView: UIImageView!
    var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        
        self.iconImgView = UIImageView()
        self.iconImgView.contentMode = .center
        self.iconImgView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.iconImgView)
        
        self.titleLabel = UILabel()
        self.titleLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContent(title: String?, image: UIImage?, property: FWMenuViewProperty) {
        
        self.selectionStyle = property.selectionStyle
        
        if image != nil {
            self.iconImgView.isHidden = false
            self.iconImgView.image = image
            self.iconImgView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(property.letfRigthMargin)
                make.centerY.equalToSuperview()
                make.size.equalTo(image!.size)
            }
        } else {
            self.iconImgView.isHidden = true
        }
        
        if title != nil {
            self.titleLabel.textAlignment = property.textAlignment
            let attributedString = NSAttributedString(string: title!, attributes: property.titleTextAttributes)
            self.titleLabel.attributedText = attributedString
            self.titleLabel.snp.makeConstraints { (make) in
                if image != nil {
                    make.left.equalTo(self.iconImgView.snp.right).offset(property.commponentMargin)
                } else {
                    make.left.equalToSuperview().offset(property.letfRigthMargin)
                }
                make.right.equalToSuperview().offset(-property.letfRigthMargin)
                make.top.equalToSuperview().offset(property.topBottomMargin)
                make.bottom.equalToSuperview().offset(-property.topBottomMargin)
            }
        }
    }
}


open class FWMenuView: FWPopupView, UITableViewDelegate, UITableViewDataSource {
    
    /// 外部传入的标题数组
    @objc public var itemTitleArray: [String]? {
        didSet {
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    /// 外部传入的图片数组
    @objc public var itemImageArray: [UIImage]? {
        didSet {
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    /// 当前选中下标
    private var selectedIndex: Int = 0
    
    /// 最大的那一项的size
    private var maxItemSize: CGSize = CGSize.zero
    
    /// 保存点击回调
    private var popupItemClickedBlock: FWPopupItemClickedBlock?
    
    /// 有箭头时：当前layer的mask
    private var maskLayer: CAShapeLayer?
    /// 有箭头时：当前layer的border
    private var borderLayer: CAShapeLayer?
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.register(FWMenuViewTableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        self.addSubview(tableView)
        return tableView
    }()
    
    /// 类初始化方法1
    ///
    /// - Parameters:
    ///   - itemTitles: 标题
    ///   - itemBlock: 点击回调
    /// - Returns: self
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: nil)
    }
    
    /// 类初始化方法2
    ///
    /// - Parameters:
    ///   - itemTitles: 标题
    ///   - itemBlock: 点击回调
    ///   - property: 可设置参数
    /// - Returns: self
    @objc open class func menu(itemTitles: [String], itemBlock: FWPopupItemClickedBlock? = nil, property: FWMenuViewProperty?) -> FWMenuView {
        
        return self.menu(itemTitles: itemTitles, itemImageNames: nil, itemBlock: itemBlock, property: property)
    }
    
    /// 类初始化方法3
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
    
    /// 刷新当前视图及数据
    @objc open func refreshData() {
        self.setupFrame(property: self.vProperty as! FWMenuViewProperty)
        self.tableView.reloadData()
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
        self.itemImageArray = itemImageNames
        
        self.popupItemClickedBlock = itemBlock
        
        let property = self.vProperty as! FWMenuViewProperty
        
        self.tableView.separatorInset = property.separatorInset
        self.tableView.layoutMargins = property.separatorInset
        self.tableView.separatorColor = property.separatorColor
        self.tableView.bounces = property.bounces
        
        self.maxItemSize = self.measureMaxSize()
        self.setupFrame(property: property)
        
        var tableViewY: CGFloat = 0
        if property.popupArrowStyle == .none {
            self.layer.cornerRadius = self.vProperty.cornerRadius
            self.layer.borderColor = self.vProperty.splitColor.cgColor
            self.layer.borderWidth = self.vProperty.splitWidth
        } else {
            tableViewY = property.popupArrowSize.height
        }
        
        // 箭头方向
        var isUpArrow = true
        switch property.popupCustomAlignment {
        case .bottomLeft, .bottomRight, .bottomCenter:
            isUpArrow = false
            break
        default:
            isUpArrow = true
            break
        }
        
        // 用来隐藏多余的线条，不想自定义线条
        let footerViewHeight: CGFloat = 1
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: footerViewHeight))
        footerView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = footerView
        
        self.tableView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(isUpArrow ? tableViewY : 0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-((isUpArrow ? 0 : tableViewY ) - footerViewHeight))
        }
    }
    
    private func setupFrame(property: FWMenuViewProperty) {
        var tableViewY: CGFloat = 0
        switch property.popupArrowStyle {
        case .none:
            tableViewY = 0
            break
        case .round, .triangle:
            tableViewY = property.popupArrowSize.height
            break
        }
        
        var tmpMaxHeight: CGFloat = 0.0
        if self.superview != nil {
            tmpMaxHeight = self.vProperty.popupViewMaxHeightRate * self.superview!.frame.size.height
        } else {
            tmpMaxHeight = self.vProperty.popupViewMaxHeightRate * UIScreen.main.bounds.height
        }
        
        var selfSize: CGSize = CGSize.zero
        if property.popupViewSize.width > 0 && property.popupViewSize.height > 0 {
            selfSize = property.popupViewSize
        } else if self.vProperty.popupViewMaxHeightRate > 0 && self.maxItemSize.height * CGFloat(self.itemsCount()) > tmpMaxHeight {
            selfSize = CGSize(width: self.maxItemSize.width, height: tmpMaxHeight)
        } else {
            selfSize = CGSize(width: self.maxItemSize.width, height: self.maxItemSize.height * CGFloat(self.itemsCount()))
        }
        selfSize.height += tableViewY
        self.frame = CGRect(x: 0, y: tableViewY, width: selfSize.width, height: selfSize.height)
        self.finalSize = selfSize
        
        self.setupMaskLayer(property: property)
    }
    
    private func setupMaskLayer(property: FWMenuViewProperty) {
        // 绘制箭头
        if property.popupArrowStyle != .none {
            if self.maskLayer != nil {
                self.layer.mask = nil
                self.maskLayer?.removeFromSuperlayer()
                self.maskLayer = nil
            }
            
            if self.borderLayer != nil {
                self.borderLayer?.removeFromSuperlayer()
                self.borderLayer = nil
            }
            
            // 圆角值
            let cornerRadius = property.cornerRadius
            /// 箭头的尺寸
            let arrowSize = property.popupArrowSize
            
            if property.popupArrowVertexScaleX > 1 {
                property.popupArrowVertexScaleX = 1
            } else if property.popupArrowVertexScaleX < 0 {
                property.popupArrowVertexScaleX = 0
            }
            
            // 箭头方向
            var isUpArrow = true
            switch property.popupCustomAlignment {
            case .bottomLeft, .bottomRight, .bottomCenter:
                isUpArrow = false
                break
            default:
                isUpArrow = true
                break
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
            self.maskLayer = CAShapeLayer()
            self.maskLayer?.frame = self.bounds
            self.maskLayer?.path = maskPath.cgPath
            self.layer.mask = self.maskLayer
            
            // 边框
            self.borderLayer = CAShapeLayer()
            self.borderLayer?.frame = self.bounds
            self.borderLayer?.path = maskPath.cgPath
            self.borderLayer?.lineWidth = 1
            self.borderLayer?.fillColor = UIColor.clear.cgColor
            self.borderLayer?.strokeColor = property.splitColor.cgColor
            self.layer.addSublayer(self.borderLayer!)
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
        cell.setupContent(title: (self.itemTitleArray != nil) ? self.itemTitleArray![indexPath.row] : nil , image: (self.itemImageArray != nil) ? self.itemImageArray![indexPath.row] : nil, property: self.vProperty as! FWMenuViewProperty)
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
        
        if self.itemTitleArray == nil && self.itemImageArray == nil {
            return CGSize.zero
        }
        
        let property = self.vProperty as! FWMenuViewProperty
        
        var titleSize = CGSize.zero
        var imageSize = CGSize.zero
        var totalMaxSize = CGSize.zero
        
        let titleAttrs = property.titleTextAttributes
        
        if self.itemTitleArray != nil {
            var tmpSize = CGSize.zero
            var index = 0
            for title: String in self.itemTitleArray! {
                titleSize = (title as NSString).size(withAttributes: titleAttrs)
                
                if self.itemImageArray != nil && self.itemImageArray!.count == self.itemTitleArray!.count {
                    let image = self.itemImageArray![index]
                    imageSize = image.size
                }
                tmpSize = CGSize(width: titleSize.width + imageSize.width, height: titleSize.height + imageSize.height)
                
                totalMaxSize.width = max(totalMaxSize.width, tmpSize.width)
                totalMaxSize.height = max(totalMaxSize.height, tmpSize.height)
                
                index += 1
            }
        } else if self.itemTitleArray == nil && self.itemImageArray != nil {
            for image: UIImage in self.itemImageArray! {
                imageSize = image.size
                
                totalMaxSize.width = max(totalMaxSize.width, imageSize.width)
                totalMaxSize.height = max(totalMaxSize.height, imageSize.height)
            }
        }
        
        totalMaxSize.width += property.letfRigthMargin * 2
        if self.itemTitleArray != nil && self.itemImageArray != nil {
            totalMaxSize.width += property.commponentMargin
        }
        
        totalMaxSize.height += property.topBottomMargin * 2
        
        var width = min(ceil(totalMaxSize.width), property.popupViewMaxWidth)
        width = max(width, property.popupViewMinWidth)
        totalMaxSize.width = width
        
        if property.popupViewItemHeight > 0 {
            totalMaxSize.height = property.popupViewItemHeight
        } else {
            totalMaxSize.height = ceil(totalMaxSize.height)
        }
        
        return totalMaxSize
    }
    
    /// 计算总计行数
    ///
    /// - Returns: 行数
    fileprivate func itemsCount() -> Int {
        
        if self.itemTitleArray != nil {
            return self.itemTitleArray!.count
        } else if self.itemImageArray != nil {
            return self.itemImageArray!.count
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
    @objc public var popupViewSize = CGSize.zero
    /// 指定行高优先级 > 自动计算的优先级
    @objc public var popupViewItemHeight: CGFloat = 0
    
    /// 未选中时按钮字体属性
    @objc public var titleTextAttributes: [NSAttributedString.Key: Any]!
    /// 文字位置
    @objc public var textAlignment : NSTextAlignment = .left
    
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
    
    /// 弹窗的最大宽度
    @objc open var popupViewMaxWidth: CGFloat  = UIScreen.main.bounds.width * 0.6
    /// 弹窗的最小宽度
    @objc open var popupViewMinWidth: CGFloat  = 20
    
    public override func reSetParams() {
        super.reSetParams()
        
        self.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.itemNormalColor, NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.buttonFontSize)]
        
        self.letfRigthMargin = 20
        
        self.popupViewMaxHeightRate = 0.7
    }
}

