//
//  FWPopupWindow.h
//  FWPopupViewOC
//
//  Created by xfg on 2017/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupViewOC
 bug反馈、交流群：670698309
 
 ***************************************************
 */


#import <UIKit/UIKit.h>
#import "UIView+PopupView.h"
#import "FWPopupBaseView.h"

#define kPvRGB(r,g,b)      [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:1.f]

#define kPvRGBA(r,g,b,a)   [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:(a)]

@interface FWPopupWindow : UIWindow <UIGestureRecognizerDelegate>

+ (FWPopupWindow *)sharedWindow;

@property (nonatomic, readonly) UIView  *attachView;

/**
 默认NO，当为YES时：用户点击外部遮罩层页面可以消失
 */
@property (nonatomic, assign) BOOL      touchWildToHide;

/**
 默认NO，当为YES时：用户拖动外部遮罩层页面可以消失
 */
@property (nonatomic, assign) BOOL      panWildToHide;

/**
 被隐藏的视图队列（A视图正在显示，接着B视图显示，此时就把A视图隐藏同时放入该队列）
 */
@property (nonatomic, strong) NSMutableArray *hiddenViews;
/**
 将要展示的视图队列（A视图的显示或者隐藏动画正在进行中时，此时如果B视图要显示，则把B视图放入该队列，等动画结束从该队列中拿出来显示）
 */
@property (nonatomic, strong) NSMutableArray *willShowingViews;
/**
 需要提前设置约束的视图（这些视图不一定会马上展示，但是因为要设置约束，因此要提前设置父视图）
 */
@property (nonatomic, strong) NSMutableArray *needConstraintsViews;

/**
 是否需要重置DimMaskView
 */
@property (nonatomic, assign) BOOL shouldResetDimMaskView;


/// 隐藏全部的弹窗（包括当前不可见的弹窗）
- (void)removeAllPopupView;

@end
