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


static const void *fw_dimReferenceCountKey            = &fw_dimReferenceCountKey;

static const void *fw_dimBackgroundViewKey            = &fw_dimBackgroundViewKey;
static const void *fw_dimAnimationDurationKey         = &fw_dimAnimationDurationKey;
static const void *fw_dimBackgroundAnimatingKey       = &fw_dimBackgroundAnimatingKey;

#import "UIView+PopupView.h"
#import <objc/runtime.h>
#import "FWPopupWindow.h"

@implementation UIView (PopupView)

@dynamic fw_dimBackgroundView;
@dynamic fw_dimAnimationDuration;
@dynamic fw_dimBackgroundAnimating;

- (NSInteger)fw_dimReferenceCount {
    return [objc_getAssociatedObject(self, fw_dimReferenceCountKey) integerValue];
}

- (void)setFw_dimReferenceCount:(NSInteger)fw_dimReferenceCount
{
    objc_setAssociatedObject(self, fw_dimReferenceCountKey, @(fw_dimReferenceCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)fw_dimBackgroundView
{
    UIView *dimView = objc_getAssociatedObject(self, fw_dimBackgroundViewKey);
    
    if ( !dimView )
    {
        dimView = [UIView new];
        dimView.center = self.center;
        [self addSubview:dimView];
        
        dimView.alpha = 0.0f;
        dimView.layer.zPosition = FLT_MAX;
        
        self.fw_dimAnimationDuration = 0.3f;
        
        objc_setAssociatedObject(self, fw_dimBackgroundViewKey, dimView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return dimView;
}

- (BOOL)fw_dimBackgroundAnimating
{
    return [objc_getAssociatedObject(self, fw_dimBackgroundAnimatingKey) boolValue];
}

- (void)setFw_dimBackgroundAnimating:(BOOL)fw_dimBackgroundAnimating
{
    objc_setAssociatedObject(self, fw_dimBackgroundAnimatingKey, @(fw_dimBackgroundAnimating), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)fw_dimAnimationDuration
{
    return [objc_getAssociatedObject(self, fw_dimAnimationDurationKey) doubleValue];
}

- (void)setFw_dimAnimationDuration:(NSTimeInterval)fw_dimAnimationDuration
{
    objc_setAssociatedObject(self, fw_dimAnimationDurationKey, @(fw_dimAnimationDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)fw_showDimBackground
{
    ++self.fw_dimReferenceCount;
    
    if ( self.fw_dimReferenceCount > 1 )
    {
        return;
    }
    
    self.fw_dimBackgroundView.hidden = NO;
    self.fw_dimBackgroundAnimating = YES;
    
    if ( self == [FWPopupWindow sharedWindow].attachView )
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
        [self bringSubviewToFront:self.fw_dimBackgroundView];
    }
    
    [UIView animateWithDuration:self.fw_dimAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.fw_dimBackgroundView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         if ( finished )
                         {
                             self.fw_dimBackgroundAnimating = NO;
                         }
                         
                     }];
}

- (void)fw_hideDimBackground
{
    --self.fw_dimReferenceCount;
    
    if ( self.fw_dimReferenceCount > 0 )
    {
        return;
    }
    
    self.fw_dimBackgroundAnimating = YES;
    [UIView animateWithDuration:self.fw_dimAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.fw_dimBackgroundView.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         if ( finished )
                         {
                             self.fw_dimBackgroundAnimating = NO;
                             
                             if ( self == [FWPopupWindow sharedWindow].attachView )
                             {
                                 [FWPopupWindow sharedWindow].hidden = YES;
                                 [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
                             }
                             else if ( self == [FWPopupWindow sharedWindow] )
                             {
                                 self.hidden = YES;
                                 [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
                             }
                         }
                     }];
}

@end
