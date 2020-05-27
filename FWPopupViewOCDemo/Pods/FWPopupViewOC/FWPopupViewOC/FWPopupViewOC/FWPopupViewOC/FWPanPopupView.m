//
//  FWPanPopupView.m
//  FWPopupViewOC
//
//  Created by xfg on 2018/6/8.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWPanPopupView.h"

@interface FWPanPopupView()

/**
 开始拖动位置
 */
@property (nonatomic, assign) CGPoint panGestureOrigin;

/**
 视图弹窗方向：
 FWPopupAlignmentTop,
 FWPopupAlignmentLeft,
 FWPopupAlignmentBottom,
 FWPopupAlignmentRight,
 */
@property (nonatomic, assign) FWPopupAlignment viewShowedDirection;

/**
 拖动方向，需要跟视图弹窗方向相反：
 FWPopupAlignmentTop,
 FWPopupAlignmentLeft,
 FWPopupAlignmentBottom,
 FWPopupAlignmentRight,
 */
@property (nonatomic, assign) FWPopupAlignment panGestureDirection;

@end

@implementation FWPanPopupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:panGesture];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture
{
    if (self.dimMaskAnimating) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.panGestureOrigin = self.frame.origin;
        self.panGestureDirection = 0;
    }
    
    if (self.viewShowedDirection == FWPopupAlignmentLeftCenter || self.viewShowedDirection == FWPopupAlignmentRightCenter)  // 向左、右拖动
    {
        [self handleLeftRightPan:gesture];
    }
    else if (self.viewShowedDirection == FWPopupAlignmentTopCenter || self.viewShowedDirection == FWPopupAlignmentBottomCenter)  // 向上、下拖动
    {
        [self handleTopBottomPan:gesture];
    }
}

- (void)handleLeftRightPan:(UIPanGestureRecognizer *)gesture
{
    CGPoint originTranslatedPoint = [gesture translationInView:self.attachedView];
    
    CGPoint translatedPoint = originTranslatedPoint;
    if (translatedPoint.x < 0) // 拖动方向：向左
    {
        self.panGestureDirection = FWPopupAlignmentLeftCenter;
    }
    else // 拖动方向：向右
    {
        self.panGestureDirection = FWPopupAlignmentRightCenter;
    }
    
    translatedPoint = CGPointMake(self.panGestureOrigin.x + translatedPoint.x, self.panGestureOrigin.y + translatedPoint.y);
    
    if (self.viewShowedDirection == FWPopupAlignmentLeftCenter)  // 视图弹窗方向：向左的情况
    {
        if (self.panGestureDirection == FWPopupAlignmentLeftCenter)
        {
            translatedPoint.x = MAX(translatedPoint.x, (self.panGestureOrigin.x-self.realFrame.size.width));
        }
        else
        {
            translatedPoint.x = MIN(translatedPoint.x, self.panGestureOrigin.x);
        }
    }
    else // 视图弹窗方向：向右的情况
    {
        if (self.panGestureDirection == FWPopupAlignmentLeftCenter)
        {
            translatedPoint.x = MAX(translatedPoint.x, self.panGestureOrigin.x);
        }
        else
        {
            translatedPoint.x = MAX(translatedPoint.x, self.panGestureOrigin.x);
            translatedPoint.x = MIN(translatedPoint.x, CGRectGetMaxX(self.realFrame));
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (fabs(translatedPoint.x - self.panGestureOrigin.x) > self.realFrame.size.width/3)
        {
            [self hide];
        }
        else
        {
            [UIView animateWithDuration:self.vProperty.animationDuration/2 animations:^{
                
                if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition || self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame)
                {
                    self.frame = self.realFrame;
                }
                else
                {
                    self.transform = CGAffineTransformIdentity;
                }
                
            }];
        }
    }
    else
    {
        if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition)
        {
            CGRect tmpFrame = self.frame;
            tmpFrame.origin.x = translatedPoint.x;
            self.frame = tmpFrame;
        }
        else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame)
        {
            CGRect tmpFrame = self.frame;
            tmpFrame.size.width = self.realFrame.size.width - fabs(self.panGestureOrigin.x - translatedPoint.x);
            if (self.viewShowedDirection == FWPopupAlignmentRightCenter)  // 视图弹窗方向：向右的情况
            {
                tmpFrame.origin.x =  self.realFrame.origin.x + (translatedPoint.x - self.panGestureOrigin.x);
            }
            self.frame = tmpFrame;
        }
        else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale || self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale3D) // 缩放动画/3D缩放动画
        {
            self.layer.anchorPoint = [self obtainAnchorPoint];
            CGFloat scale = (self.realFrame.size.width - fabs(translatedPoint.x - self.panGestureOrigin.x)) / self.realFrame.size.width;
            self.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
}

- (void)handleTopBottomPan:(UIPanGestureRecognizer *)gesture
{
    CGPoint originTranslatedPoint = [gesture translationInView:self.attachedView];
    
    CGPoint translatedPoint = originTranslatedPoint;
    if (translatedPoint.y < 0) // 拖动方向：向上
    {
        self.panGestureDirection = FWPopupAlignmentTopCenter;
    }
    else // 拖动方向：向下
    {
        self.panGestureDirection = FWPopupAlignmentBottomCenter;
    }
    
    translatedPoint = CGPointMake(self.panGestureOrigin.x + translatedPoint.x, self.panGestureOrigin.y + translatedPoint.y);
    
    if (self.viewShowedDirection == FWPopupAlignmentTopCenter)  // 视图弹窗方向：向上的情况
    {
        if (self.panGestureDirection == FWPopupAlignmentTopCenter)
        {
            translatedPoint.y = MAX(translatedPoint.y, (self.panGestureOrigin.y-self.realFrame.size.height));
        }
        else
        {
            translatedPoint.y = MIN(translatedPoint.y, self.panGestureOrigin.y);
        }
    }
    else // 视图弹窗方向：向下的情况
    {
        if (self.panGestureDirection == FWPopupAlignmentTopCenter)
        {
            translatedPoint.y = MAX(translatedPoint.y, self.panGestureOrigin.y);
        }
        else
        {
            translatedPoint.y = MAX(translatedPoint.y, self.panGestureOrigin.y);
            translatedPoint.y = MIN(translatedPoint.y, CGRectGetMaxY(self.realFrame));
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (fabs(translatedPoint.y - self.panGestureOrigin.y) > self.realFrame.size.height/3)
        {
            [self hide];
        }
        else
        {
            [UIView animateWithDuration:self.vProperty.animationDuration/2 animations:^{
                
                if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition || self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame)
                {
                    self.frame = self.realFrame;
                }
                else
                {
                    self.transform = CGAffineTransformIdentity;
                }
                
            }];
        }
    }
    else
    {
        if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition)
        {
            CGRect tmpFrame = self.frame;
            tmpFrame.origin.y = translatedPoint.y;
            self.frame = tmpFrame;
        }
        else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame)
        {
            CGRect tmpFrame = self.frame;
            tmpFrame.size.height = self.realFrame.size.height - fabs(self.panGestureOrigin.y - translatedPoint.y);
            if (self.viewShowedDirection == FWPopupAlignmentBottomCenter)  // 视图弹窗方向：向下的情况
            {
                tmpFrame.origin.y =  self.realFrame.origin.y + (translatedPoint.y - self.panGestureOrigin.y);
            }
            self.frame = tmpFrame;
        }
        else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale || self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale3D) // 缩放动画/3D缩放动画
        {
            self.layer.anchorPoint = [self obtainAnchorPoint];
            CGFloat scale = (self.realFrame.size.height - fabs(translatedPoint.y - self.panGestureOrigin.y)) / self.realFrame.size.height;
            self.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
}


#pragma mark - ----------------------- SET/GET -----------------------

- (FWPopupAlignment)viewShowedDirection
{
    FWPopupAlignment alignment = self.vProperty.popupAlignment;
    FWPopupAlignment tmpAlignment;
    if (alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopRight || alignment == FWPopupAlignmentCenter)
    {
        tmpAlignment = FWPopupAlignmentTopCenter;
    }
    else if (alignment == FWPopupAlignmentLeftCenter)
    {
        tmpAlignment = FWPopupAlignmentLeftCenter;
    }
    else if (alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomRight)
    {
        tmpAlignment = FWPopupAlignmentBottomCenter;
    }
    else
    {
        tmpAlignment = FWPopupAlignmentRightCenter;
    }
    return tmpAlignment;
}

@end
