//
//  FWPopupBaseView.h
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupView
 bug反馈、交流群：670698309
 
 ***************************************************
 */


#import <UIKit/UIKit.h>
#import "UIView+PopupView.h"

/**
 自定义弹窗校准位置，注意：这边设置靠置哪边动画就从哪边出来

 - FWPopupAlignmentCenter: 中间，默认值
 - FWPopupAlignmentTop: 上
 - FWPopupAlignmentLeft: 左
 - FWPopupAlignmentBottom: 下
 - FWPopupAlignmentRight: 右
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
    FWPopupAlignmentTop,
    FWPopupAlignmentLeft,
    FWPopupAlignmentBottom,
    FWPopupAlignmentRight,
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

 - FWPopupAnimationTypePosition: 位移动画，视图靠边的时候建议使用
 - FWPopupAnimationTypeScale: 缩放动画
 - FWPopupAnimationTypeScale3D: 3D缩放动画（注意：这边隐藏时用的还是scale动画）
 - FWPopupAnimationTypeFrame: 修改frame值的动画，视图未靠边的时候建议使用
 */
typedef NS_ENUM(NSInteger, FWPopupAnimationType) {
    FWPopupAnimationTypePosition,
    FWPopupAnimationTypeScale,
    FWPopupAnimationTypeScale3D,
    FWPopupAnimationTypeFrame,
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

@class FWPopupBaseView;
@class FWPopupBaseViewProperty;

/**
 显示、隐藏回调

 @param popupBaseView self
 */
typedef void(^FWPopupBlock)(FWPopupBaseView *popupBaseView);

/**
 显示、隐藏完成回调

 @param popupBaseView self
 @param isShow YES：显示 NO：隐藏
 */
typedef void(^FWPopupCompletionBlock)(FWPopupBaseView *popupBaseView, BOOL isShow);

/**
 普通无参数回调
 */
typedef void(^FWPopupVoidBlock)(void);

// 隐藏所有弹窗的通知
static NSString *const FWHideAllPopupViewNotification = @"FWHideAllPopupViewNotification";


@interface FWPopupBaseView : UIView

/**
 1、当外部没有传入该参数时，默认为UIWindow的根控制器的视图，即表示弹窗放在FWPopupWindow上；
 2、当外部传入该参数时，该视图为传入的UIView，即表示弹窗放在传入的UIView上；
 */
@property (nonatomic, strong) UIView                    *attachedView;

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
@property (nonatomic, assign, readonly ) BOOL           visible;


- (void)show;

- (void)showWithBlock:(FWPopupCompletionBlock)completionBlock;

- (void)hide;

- (void)hideWithBlock:(FWPopupCompletionBlock)completionBlock;

@end


@interface FWPopupBaseViewProperty: NSObject

@end
