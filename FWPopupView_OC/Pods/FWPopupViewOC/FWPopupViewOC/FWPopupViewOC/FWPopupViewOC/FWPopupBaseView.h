//
//  FWPopupBaseView.h
//  FWPopupViewOC
//
//  Created by xfg on 2017/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//  弹窗基类

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupViewOC
 bug反馈、交流群：670698309
 
 ***************************************************
 */


#import <UIKit/UIKit.h>
#import "UIView+PopupView.h"

/**
 自定义弹窗校准位置，注意：这边设置靠置哪边动画就从哪边出来

 - FWPopupAlignmentCenter: 中间，默认值
 - FWPopupAlignmentTopCenter: 上中
 - FWPopupAlignmentLeftCenter: 左中
 - FWPopupAlignmentBottomCenter: 下中
 - FWPopupAlignmentRightCenter: 右中
 - FWPopupAlignmentTopLeft: 上左
 - FWPopupAlignmentTopRight: 上右
 - FWPopupAlignmentBottomLeft: 下左
 - FWPopupAlignmentBottomRight: 下右
 */
typedef NS_ENUM(NSInteger, FWPopupAlignment) {
    FWPopupAlignmentCenter,
    FWPopupAlignmentTopCenter,
    FWPopupAlignmentLeftCenter,
    FWPopupAlignmentBottomCenter,
    FWPopupAlignmentRightCenter,
    FWPopupAlignmentTopLeft,
    FWPopupAlignmentTopRight,
    FWPopupAlignmentBottomLeft,
    FWPopupAlignmentBottomRight,
};

/**
 自定义弹窗动画类型

 - FWPopupAnimationStylePosition: 位移动画，视图靠边的时候建议使用
 - FWPopupAnimationStyleScale: 缩放动画
 - FWPopupAnimationStyleScale3D: 3D缩放动画（注意：这边隐藏时用的还是scale动画）
 - FWPopupAnimationStyleFrame: 修改frame值的动画，视图未靠边的时候建议使用
 */
typedef NS_ENUM(NSInteger, FWPopupAnimationStyle) {
    FWPopupAnimationStylePosition = 0,
    FWPopupAnimationStyleScale,
    FWPopupAnimationStyleScale3D,
    FWPopupAnimationStyleFrame,
};

/**
 弹窗箭头的样式

 - FWPopupArrowStyleNone: 无箭头
 - FWPopupArrowStyleRound: 圆角箭头
 - FWPopupArrowStyleTriangle: 菱角箭头
 */
typedef NS_ENUM(NSInteger, FWPopupArrowStyle) {
    FWPopupArrowStyleNone,
    FWPopupArrowStyleRound,
    FWPopupArrowStyleTriangle,
};

/**
 弹窗状态

 - FWPopupStateUnKnow: 未知
 - FWPopupStateWillAppear: 将要显示
 - FWPopupStateDidAppear: 已经显示
 - FWPopupStateWillDisappear: 将要隐藏
 - FWPopupStateDidDisappear: 已经隐藏
 - FWPopupStateDidAppearButCovered: 已经显示，但是被其他弹窗遮盖住了（实际上当前状态下弹窗是不可见）
 - FWPopupStateDidAppearAgain: 已经显示，其上面遮盖的弹窗消失了（实际上当前状态与FWPopupStateDidAppear状态相同）
 */
typedef NS_ENUM(NSInteger, FWPopupState) {
    FWPopupStateUnKnow,
    FWPopupStateWillAppear,
    FWPopupStateDidAppear,
    FWPopupStateWillDisappear,
    FWPopupStateDidDisappear,
    FWPopupStateDidAppearButCovered,
    FWPopupStateDidAppearAgain,
};


@class FWPopupBaseView;
@class FWPopupBaseViewProperty;

/**
 弹窗已经显示回调

 @param popupBaseView self
 */
typedef void(^FWPopupDidAppearBlock)(FWPopupBaseView *popupBaseView);

/**
 弹窗已经隐藏回调

 @param popupBaseView self
 */
typedef void(^FWPopupDidDisappearBlock)(FWPopupBaseView *popupBaseView);

/**
 弹窗状态回调，注意：该回调会走N次

 @param popupBaseView self
 */
typedef void(^FWPopupStateBlock)(FWPopupBaseView *popupBaseView, FWPopupState popupState);

/**
 普通无参数回调
 */
typedef void(^FWPopupVoidBlock)(void);

// 隐藏所有弹窗的通知
static NSString *const FWHideAllPopupViewNotification = @"FWHideAllPopupViewNotification";


@interface FWPopupBaseView : UIView <UIGestureRecognizerDelegate>

/**
 1、当外部没有传入该参数时，默认为UIWindow的根控制器的视图，即表示弹窗放在FWPopupWindow上；
 2、当外部传入该参数时，该视图为传入的UIView，即表示弹窗放在传入的UIView上；
 */
@property (nonatomic, strong) UIView                    *attachedView;

/**
 弹窗真正的frame
 */
@property (nonatomic, assign, readonly) CGRect          realFrame;

/**
 可设置属性
 */
@property (nonatomic, strong) FWPopupBaseViewProperty   *vProperty;

/**
 单击隐藏弹窗，这个当且仅当：attachedView为用户传入的UIView并且 touchWildToHide == YES 时有效
 */
@property (nonatomic, strong) UITapGestureRecognizer    *tapGest;

/**
 当前弹窗是否可见
 */
@property (nonatomic, assign, readonly) BOOL            visible;

/**
 是否有用到键盘
 */
@property (nonatomic, assign) BOOL                      withKeyboard;

/**
 是否不需要设置Frame（当前基类使用Masonry，如果子类不希望该父类重置他的Frame，可以传入true）
 */
@property (nonatomic, assign) BOOL                      isNotMakeFrame;

/**
 当前弹窗状态
 */
@property (nonatomic, assign) FWPopupState              currentPopupState;


/**
 显示
 */
- (void)show;

/**
 弹窗已经显示

 @param didAppearBlock 弹窗已经显示回调
 */
- (void)showWithDidAppearBlock:(FWPopupDidAppearBlock)didAppearBlock;

/**
 显示：弹窗状态回调，注意：该回调会走N次

 @param stateBlock 弹窗状态回调，注意：该回调会走N次
 */
- (void)showWithStateBlock:(FWPopupStateBlock)stateBlock;

/**
 隐藏
 */
- (void)hide;

/**
 弹窗已经隐藏

 @param didDisappearBlock 弹窗已经隐藏回调
 */
- (void)hideWithDidDisappearBlock:(FWPopupDidDisappearBlock)didDisappearBlock;

/**
 遮罩层被单击，主要用来给子类重写
 */
- (void)clickedMaskView;

/**
 获取当前视图AnchorPoint

 @return CGPoint
 */
- (CGPoint)obtainAnchorPoint;

/**
 如要初始化视图后要设置当前视图的约束，必须要使用该方法，因为这个方法会提前将当前视图加入父视图，使用该方法有以下几个注意点：
 1、使用该方法不支持更换父视图，即不支持修改：attachedView；
 2、使用该方法不建议把当前视图设置为成员变量，因为调用隐藏方法时会把当前视图从父视图中移除，调用显示方法后会重新添加到父视图，此时约束就会丢失相对于父视图的那部分；
 3、有些约束可能会影响到某些动画的效果。

 @return self
 */
- (instancetype)initWithConstraints;

/**
 重置视图size

 @param size 新的size
 @param isImmediateEffect 是否立即生效，当 currentPopupState==FWPopupStateDidAppear 时有效，此时弹窗会重新显示，此时相应的回调也会重新走
 */
- (void)resetSize:(CGSize)size isImmediateEffect:(BOOL)isImmediateEffect;

@end



#pragma mark - ======================= 可配置属性 =======================

@interface FWPopupBaseViewProperty: NSObject

+ (instancetype)manager;

/**
 标题字体大小
 */
@property (nonatomic, assign) CGFloat titleFontSize;
/**
 标题文字颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 按钮字体大小
 */
@property (nonatomic, assign) CGFloat buttonFontSize;
/**
 按钮高度
 */
@property (nonatomic, assign) CGFloat buttonHeight;
/**
 普通按钮文字颜色
 */
@property (nonatomic, strong) UIColor *itemNormalColor;
/**
 高亮按钮文字颜色
 */
@property (nonatomic, strong) UIColor *itemHighlightColor;
/**
 选中按钮文字颜色
 */
@property (nonatomic, strong) UIColor *itemPressedColor;

/**
 上下间距
 */
@property (nonatomic, assign) CGFloat topBottomMargin;
/**
 左右间距
 */
@property (nonatomic, assign) CGFloat letfRigthMargin;
/**
 控件之间的间距
 */
@property (nonatomic, assign) CGFloat commponentMargin;

/**
 边框、分割线颜色
 */
@property (nonatomic, strong) UIColor *splitColor;
/**
 边框宽度
 */
@property (nonatomic, assign) CGFloat splitWidth;
/**
 圆角值
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 弹窗的背景色（注意：这边指的是弹窗而不是遮罩层，遮罩层背景色的设置是：fwMaskViewColor）
 */
@property (nonatomic, strong) UIColor *backgroundColor;
/**
 弹窗的最大高度，0：表示不限制
 */
@property (nonatomic, assign) CGFloat popupViewMaxHeight;

/**
 弹窗箭头的样式
 */
@property (nonatomic, assign) FWPopupArrowStyle popupArrowStyle;
/**
 弹窗箭头的尺寸
 */
@property (nonatomic, assign) CGSize popupArrowSize;
/**
 弹窗箭头的顶点的X值相对于弹窗的宽度，默认在弹窗X轴的一半，因此设置范围：0~1
 */
@property (nonatomic, assign) CGFloat popupArrowVertexScaleX;
/**
 弹窗圆角箭头的圆角值
 */
@property (nonatomic, assign) CGFloat popupArrowCornerRadius;
/**
 弹窗圆角箭头与边线交汇处的圆角值
 */
@property (nonatomic, assign) CGFloat popupArrowBottomCornerRadius;


// ===== 自定义弹窗（继承FWPopupView）时可能会用到 =====

/**
 弹窗校准位置
 */
@property (nonatomic, assign) FWPopupAlignment popupAlignment;
/**
 弹窗动画类型
 */
@property (nonatomic, assign) FWPopupAnimationStyle popupAnimationStyle;

/**
 弹窗偏移量
 */
@property (nonatomic, assign) UIEdgeInsets popupEdgeInsets;
/**
 遮罩层的背景色（也可以使用fwMaskViewColor），注意：该参数在弹窗隐藏后，还原为弹窗弹起时的值
 */
@property (nonatomic, strong) UIColor *maskViewColor;

/**
 0表示NO，1表示YES，YES：用户点击外部遮罩层页面可以隐藏，注意：该参数在弹窗隐藏后，还原为弹窗弹起时的值
 */
@property (nonatomic, copy) NSString *touchWildToHide;

/**
 显示、隐藏动画所需的时间
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 阻尼系数，范围：0.0f~1.0f，数值越小「弹簧」的振动效果越明显。默认：-1，表示没有「弹簧」效果
 */
@property (nonatomic, assign) CGFloat usingSpringWithDamping;

/**
 初始速率，数值越大一开始移动越快，默认为：5
 */
@property (nonatomic, assign) CGFloat initialSpringVelocity;

/**
 3D放射动画（当且仅当：popupAnimationStyle == .scale3D 时有效）
 */
@property (nonatomic, assign) CATransform3D transform3D;
/**
 2D放射动画
 */
@property (nonatomic, assign) CGAffineTransform transform;

/**
 是否需要让多余部分的遮罩层变为无色（当弹窗没有任何一条边跟遮罩层的任意一条边重合的时候，就可能会把遮罩层分成几部分，此时看上去就不大美观了，因此可以使用该属性把某些部分设置为无色）。注意：使用该属性后不支持横竖屏切换，会出现视图显示的问题
 */
@property (nonatomic, assign) BOOL shouldClearSpilthMask;

/**
 初始化相关属性
 */
- (void)setupParams;

@end
