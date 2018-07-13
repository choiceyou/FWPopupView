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

@end
