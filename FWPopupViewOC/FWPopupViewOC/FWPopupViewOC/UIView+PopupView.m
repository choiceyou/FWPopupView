//
//  UIView+PopupView.m
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


static const void *dimReferenceCountKey             = &dimReferenceCountKey;

static const void *dimMaskViewKey                   = &dimMaskViewKey;
static const void *dimMaskViewColorKey              = &dimMaskViewColorKey;
static const void *dimMaskAnimationDurationKey      = &dimMaskAnimationDurationKey;
static const void *dimMaskAnimatingKey              = &dimMaskAnimatingKey;

#import "UIView+PopupView.h"
#import <objc/runtime.h>
#import "FWPopupWindow.h"

@implementation UIView (PopupView)

@dynamic dimMaskView;
@dynamic dimMaskAnimationDuration;
@dynamic dimMaskAnimating;

- (NSInteger)dimReferenceCount {
    return [objc_getAssociatedObject(self, dimReferenceCountKey) integerValue];
}

- (void)setDimReferenceCount:(NSInteger)dimReferenceCount
{
    objc_setAssociatedObject(self, dimReferenceCountKey, @(dimReferenceCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)dimMaskViewColor
{
    return objc_getAssociatedObject(self, dimMaskViewColorKey);
}

- (void)setDimMaskViewColor:(UIColor *)dimMaskViewColor
{
    objc_setAssociatedObject(self, dimMaskViewColorKey, dimMaskViewColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)dimMaskView
{
    UIView *dimView = objc_getAssociatedObject(self, dimMaskViewKey);
    
    if (!dimView)
    {
        dimView = [UIView new];
        dimView.center = self.center;
        [self addSubview:dimView];
        
        dimView.alpha = 0.0f;
        dimView.layer.zPosition = FLT_MAX;
        
        self.dimMaskAnimationDuration = 0.3f;
        
        objc_setAssociatedObject(self, dimMaskViewKey, dimView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return dimView;
}

- (BOOL)dimMaskAnimating
{
    return [objc_getAssociatedObject(self, dimMaskAnimatingKey) boolValue];
}

- (void)setDimMaskAnimating:(BOOL)dimMaskAnimating
{
    objc_setAssociatedObject(self, dimMaskAnimatingKey, @(dimMaskAnimating), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)dimMaskAnimationDuration
{
    return [objc_getAssociatedObject(self, dimMaskAnimationDurationKey) doubleValue];
}

- (void)setDimMaskAnimationDuration:(NSTimeInterval)dimMaskAnimationDuration
{
    objc_setAssociatedObject(self, dimMaskAnimationDurationKey, @(dimMaskAnimationDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showDimMask
{
    ++self.dimReferenceCount;
    
    if ( self.dimReferenceCount > 1 )
    {
        return;
    }
    
    self.dimMaskView.hidden = NO;
    self.dimMaskAnimating = YES;
    
    if (self == [FWPopupWindow sharedWindow].attachView )
    {
        [FWPopupWindow sharedWindow].hidden = NO;
        [[FWPopupWindow sharedWindow] makeKeyAndVisible];
    }
    else if ( [self isKindOfClass:[UIWindow class]] )
    {
        self.hidden = NO;
        [(UIWindow*)self makeKeyAndVisible];
    }
    else
    {
        [self bringSubviewToFront:self.dimMaskView];
    }
    
    [UIView animateWithDuration:self.dimMaskAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.dimMaskView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         if ( finished )
                         {
                             self.dimMaskAnimating = NO;
                         }
                         
                     }];
}

- (void)hideDimMask
{
    --self.dimReferenceCount;
    
    if ( self.dimReferenceCount > 0 )
    {
        return;
    }
    
    self.dimMaskAnimating = YES;
    [UIView animateWithDuration:self.dimMaskAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.dimMaskView.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         if (finished)
                         {
                             self.dimMaskAnimating = NO;
                             
                             if (self == [FWPopupWindow sharedWindow].attachView)
                             {
                                 [FWPopupWindow sharedWindow].hidden = YES;
                                 [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
                             }
                             else if (self == [FWPopupWindow sharedWindow])
                             {
                                 self.hidden = YES;
                                 [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
                             }
                         }
                     }];
}

@end
