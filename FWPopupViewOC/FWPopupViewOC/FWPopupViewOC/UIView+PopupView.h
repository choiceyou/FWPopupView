//
//  UIView+PopupView.h
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PopupView)

@property (nonatomic, strong, readonly ) UIView            *fw_dimBackgroundView;
@property (nonatomic, assign, readonly ) BOOL              fw_dimBackgroundAnimating;
@property (nonatomic, assign           ) NSTimeInterval    fw_dimAnimationDuration;

- (void) fw_showDimBackground;
- (void) fw_hideDimBackground;

@end
