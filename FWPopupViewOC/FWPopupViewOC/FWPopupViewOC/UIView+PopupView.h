//
//  UIView+PopupView.h
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PopupView)

@property (nonatomic, strong, readonly) UIView  *dimMaskView;
@property (nonatomic, strong) UIColor           *dimMaskViewColor;
@property (nonatomic, assign, readonly) BOOL    dimMaskAnimating;
@property (nonatomic, assign) NSTimeInterval    dimMaskAnimationDuration;

- (void)showDimMask;
- (void)hideDimMask;

@end
