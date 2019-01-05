//
//  FWPopupWindow.m
//  FWPopupViewOC
//
//  Created by xfg on 2017/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWPopupWindow.h"
#import "FWPopupRootController.h"

@implementation FWPopupWindow

+ (FWPopupWindow *)sharedWindow
{
    static FWPopupWindow *window;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        window = [[FWPopupWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = [FWPopupRootController new];
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
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        gesture.cancelsTouchesInView = NO;
        gesture.delegate = self;
        [self addGestureRecognizer:gesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)tapGestureAction:(UIGestureRecognizer *)gesture
{
    if (!self.dimMaskAnimating)
    {
        for (UIView *v in [self attachView].dimMaskView.subviews)
        {
            if ([v isKindOfClass:[FWPopupBaseView class]])
            {
                FWPopupBaseView *popupView = (FWPopupBaseView *)v;
                [popupView clicedMaskView];
                if (self.touchWildToHide)
                {
                    [popupView hide];
                }
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == self.attachView.dimMaskView;
}

- (UIView *)attachView
{
    return self.rootViewController.view;
}

@end
