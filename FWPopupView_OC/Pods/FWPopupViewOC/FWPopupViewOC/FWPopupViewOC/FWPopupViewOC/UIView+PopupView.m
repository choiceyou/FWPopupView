//
//  UIView+PopupView.m
//  FWPopupViewOC
//
//  Created by xfg on 2017/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

static const void *dimReferenceCountKey             = &dimReferenceCountKey;

static const void *dimMaskViewKey                   = &dimMaskViewKey;
static const void *dimMaskViewColorKey              = &dimMaskViewColorKey;
static const void *dimMaskAnimationDurationKey      = &dimMaskAnimationDurationKey;
static const void *dimMaskAnimatingKey              = &dimMaskAnimatingKey;

/**
 遮罩层的默认背景色
 */
#define kDefaultMaskViewColor [UIColor colorWithWhite:0 alpha:0.5]

#import "UIView+PopupView.h"
#import <objc/runtime.h>
#import "FWPopupWindow.h"
#import "Masonry.h"

@implementation UIView (PopupView)

@dynamic dimMaskView;
@dynamic dimMaskAnimationDuration;
@dynamic dimMaskAnimating;

- (NSInteger)dimReferenceCount {
    id count = objc_getAssociatedObject(self, dimReferenceCountKey);
    if (count == nil) {
        return 0;
    } else {
        return [count integerValue];
    }
}

- (void)setDimReferenceCount:(NSInteger)dimReferenceCount
{
    objc_setAssociatedObject(self, dimReferenceCountKey, @(dimReferenceCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)dimMaskViewColor
{
    id color = objc_getAssociatedObject(self, dimMaskViewColorKey);
    if (color == nil) {
        return kDefaultMaskViewColor;
    } else {
        return color;
    }
}

- (void)setDimMaskViewColor:(UIColor *)dimMaskViewColor
{
    objc_setAssociatedObject(self, dimMaskViewColorKey, dimMaskViewColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dimMaskAnimating
{
    id isAnimating = objc_getAssociatedObject(self, dimMaskAnimatingKey);
    if (isAnimating == nil) {
        return NO;
    } else {
        return [isAnimating boolValue];
    }
}

- (void)setDimMaskAnimating:(BOOL)dimMaskAnimating
{
    objc_setAssociatedObject(self, dimMaskAnimatingKey, @(dimMaskAnimating), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)dimMaskAnimationDuration
{
    id duration = objc_getAssociatedObject(self, dimMaskAnimationDurationKey);
    if (duration == nil) {
        return 0;
    } else {
        return [duration doubleValue];
    }
}

- (void)setDimMaskAnimationDuration:(NSTimeInterval)dimMaskAnimationDuration
{
    objc_setAssociatedObject(self, dimMaskAnimationDurationKey, @(dimMaskAnimationDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)dimMaskView
{
    UIView *dimView = objc_getAssociatedObject(self, dimMaskViewKey);
    
    if (!dimView)
    {
        dimView = [[UIView alloc] init];
        [self addSubview:dimView];
        [dimView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.width.height.equalTo(self);
        }];
        
        dimView.alpha = 0.0f;
        dimView.layer.zPosition = FLT_MAX;
    }
    dimView.backgroundColor = self.dimMaskViewColor;
    objc_setAssociatedObject(self, dimMaskViewKey, dimView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return dimView;
}

- (void)resetDimMaskView
{
    objc_setAssociatedObject(self, dimMaskViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showDimMask
{
    ++self.dimReferenceCount;
    if (self.dimReferenceCount > 1)
    {
        --self.dimReferenceCount;
        return;
    }
    
    self.dimMaskView.hidden = NO;
    
    if (self == [FWPopupWindow sharedWindow].attachView)
    {
        [FWPopupWindow sharedWindow].hidden = NO;
        [[FWPopupWindow sharedWindow] makeKeyAndVisible];
    }
    else if ([self isKindOfClass:[UIWindow class]])
    {
        self.hidden = NO;
        [(UIWindow *)self makeKeyAndVisible];
    }
    else
    {
        [self bringSubviewToFront:self.dimMaskView];
    }
    
    [UIView animateWithDuration:self.dimMaskAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.dimMaskView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideDimMask
{
    if (self.dimReferenceCount > 1)
    {
        return;
    }
    
    [UIView animateWithDuration:self.dimMaskAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.dimMaskView.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         if (self == [FWPopupWindow sharedWindow].attachView)
                         {
                             [FWPopupWindow sharedWindow].hidden = YES;
                         }
                         else if (self == [FWPopupWindow sharedWindow])
                         {
                             self.hidden = YES;
                         }
                         
                         --self.dimReferenceCount;
                     }];
}

@end
