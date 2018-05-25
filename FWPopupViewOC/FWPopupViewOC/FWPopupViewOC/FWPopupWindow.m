//
//  FWPopupWindow.m
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWPopupWindow.h"

@implementation FWPopupWindow

+ (FWPopupWindow *)sharedWindow
{
    static FWPopupWindow *window;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        window = [[FWPopupWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = [UIViewController new];
    });
    
    return window;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.width == 0 || frame.size.height == 0) {
        frame = [UIScreen mainScreen].bounds;
    }
    self = [super initWithFrame:frame];
    if (self) {
        
        self.windowLevel = UIWindowLevelStatusBar + 1;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        gesture.cancelsTouchesInView = NO;
        gesture.delegate = self;
        [self addGestureRecognizer:gesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)tapGestureAction:(UIGestureRecognizer *)gesture
{
    if (self.touchWildToHide && !self.dimMaskAnimating)
    {
        for (UIView *v in [self attachView].dimMaskView.subviews)
        {
            if ([v isKindOfClass:[FWPopupBaseView class]])
            {
                FWPopupBaseView *popupView = (FWPopupBaseView *)v;
                [popupView hide];
            }
        }
    }
}

- (void)panGestureAction:(UIGestureRecognizer *)gesture
{
    if (self.panWildToHide) {
        [self tapGestureAction:gesture];
    }
}

- (UIView *)attachView
{
    return self.rootViewController.view;
}

@end
