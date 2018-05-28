//
//  FWPopupBaseView.m
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWPopupBaseView.h"
#import "FWPopupWindow.h"
#import <QuartzCore/QuartzCore.h>

@interface FWPopupBaseView()

@property (nonatomic, copy) FWPopupCompletionBlock popupCompletionBlock;
@property (nonatomic, copy) FWPopupBlock showAnimation;
@property (nonatomic, copy) FWPopupBlock hideAnimation;
/**
 记录遮罩层设置前的颜色
 */
@property (nonatomic, strong) UIColor *originMaskViewColor;
/**
 记录遮罩层设置前的是否可点击
 */
@property (nonatomic, assign) BOOL originTouchWildToHide;
/**
 遮罩层为UIScrollView或其子类时，记录是否可以滚动
 */
@property (nonatomic, assign) BOOL originScrollEnabled;

/**
 当前frame值是否被设置过了
 */
@property (nonatomic, assign) BOOL haveSetFrame;
/**
 弹窗真正的frame
 */
@property (nonatomic, assign) CGRect finalFrame;

@end

@implementation FWPopupBaseView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([self.attachedView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *view = (UIScrollView *)self.attachedView;
        view.scrollEnabled = self.originScrollEnabled;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _attachedView = [FWPopupWindow sharedWindow].attachView;
        
        _originMaskViewColor = self.attachedView.dimMaskViewColor;
        _originTouchWildToHide = [FWPopupWindow sharedWindow].touchWildToHide;
        
        self.showAnimation = [self showCustomAnimation];
        self.hideAnimation = [self hideCustomAnimation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyHideAll:) name:FWHideAllPopupViewNotification object:nil];
    }
    return self;
}

#pragma mark - ----------------------- 显示、隐藏 -----------------------

/**
 显示
 */
- (void)show
{
    [self showWithBlock:nil];
}

/**
 显示
 
 @param completionBlock 显示、隐藏回调
 */
- (void)showWithBlock:(FWPopupCompletionBlock)completionBlock
{
    if (self.attachedView == nil) {
        self.attachedView = FWPopupWindow.sharedWindow.attachView;
    }
    
    if (self.vProperty.maskViewColor != nil) {
        self.attachedView.dimMaskViewColor = self.vProperty.maskViewColor;
    }
    if (self.vProperty.touchWildToHide != nil && ![self.vProperty.touchWildToHide isEqualToString:@""]) {
        [FWPopupWindow sharedWindow].touchWildToHide = ([self.vProperty.touchWildToHide integerValue] == 1) ? YES : NO;
    }
    self.attachedView.dimMaskAnimationDuration = self.vProperty.animationDuration;
    
    if (self.attachedView != [FWPopupWindow sharedWindow].attachView) {
        if (self.tapGest == nil) {
            self.tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
            [self.attachedView addGestureRecognizer:self.tapGest];
        } else {
            self.tapGest.enabled = YES;
        }
        if ([self.attachedView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *view = (UIScrollView *)self.attachedView;
            view.scrollEnabled = NO;
        }
    }
    
    if (completionBlock != nil) {
        self.popupCompletionBlock = completionBlock;
    }
    
    [self.attachedView showDimMask];
    
    FWPopupBlock showBlock = self.showAnimation;
    showBlock(self);
    
    if (self.withKeyboard) {
        [self showKeyboard];
    }
    
}

/**
 隐藏
 */
- (void)hide
{
    [self hideWithBlock:nil];
}

/**
 隐藏
 
 @param completionBlock 显示、隐藏回调
 */
- (void)hideWithBlock:(FWPopupCompletionBlock)completionBlock
{
    self.attachedView.dimMaskAnimationDuration = self.vProperty.animationDuration;
    
    if (completionBlock != nil) {
        self.popupCompletionBlock = completionBlock;
    }
    
    [self.attachedView hideDimMask];
    
    if (self.withKeyboard) {
        [self hideKeyboard];
    }
    
    FWPopupBlock hideBlock = self.hideAnimation;
    hideBlock(self);
    
    if (self.tapGest != nil) {
        self.tapGest.enabled = false;
    }
    
    self.attachedView.dimMaskViewColor = self.originMaskViewColor;
    [FWPopupWindow sharedWindow].touchWildToHide = self.originTouchWildToHide;
    if ([self.attachedView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *view = (UIScrollView *)self.attachedView;
        view.scrollEnabled = self.originScrollEnabled;
    }
}

+ (void)hideAll
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FWHideAllPopupViewNotification object:nil];
}

- (void)notifyHideAll:(NSNotification *)notification
{
    if ([self isKindOfClass:[notification class]]) {
        [self hide];
    }
}


#pragma mark - ----------------------- 显示、隐藏动画 -----------------------

- (FWPopupBlock)showCustomAnimation
{
    __weak typeof(self) weakSelf = self;
    FWPopupBlock popupBlock = ^(FWPopupBaseView *popupBaseView) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.superview == nil) {
            [strongSelf.attachedView.dimMaskView addSubview:strongSelf];
            
            [strongSelf setupFrame];
            
            if (strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypePosition) // 位移动画
            {
                CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                
                FWPopupAlignment alignment = strongSelf.vProperty.popupAlignment;
                if (alignment == FWPopupAlignmentTop || alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopRight || alignment == FWPopupAlignmentCenter)
                {
                    baseAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(strongSelf.frame.origin.x + strongSelf.frame.size.width/2, strongSelf.frame.origin.y - strongSelf.frame.size.height/2)];
                }
                else if (alignment == FWPopupAlignmentLeft || alignment == FWPopupAlignmentLeftCenter)
                {
                    baseAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(strongSelf.frame.origin.x - strongSelf.frame.size.width/2, strongSelf.frame.origin.y + strongSelf.frame.size.height/2)];
                }
                else if (alignment == FWPopupAlignmentBottom || alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomRight)
                {
                    baseAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(strongSelf.frame.origin.x + strongSelf.frame.size.width/2, strongSelf.attachedView.frame.size.height + strongSelf.frame.size.height/2)];
                }
                else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
                {
                    baseAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(strongSelf.attachedView.frame.size.width + strongSelf.frame.size.width/2, strongSelf.frame.origin.y + strongSelf.frame.size.height/2)];
                }
                baseAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(strongSelf.frame.origin.x + strongSelf.frame.size.width/2, strongSelf.frame.origin.y + strongSelf.frame.size.height/2)];
                baseAnimation.duration = strongSelf.vProperty.animationDuration;
                [strongSelf.layer addAnimation:baseAnimation forKey:@"positionAnimation"];
                
            }
            else if (strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypeScale || strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypeScale3D) // 缩放动画/3D缩放动画
            {
                strongSelf.layer.anchorPoint = [strongSelf obtainAnchorPoint];
                strongSelf.frame = strongSelf.finalFrame;
                if (strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypeScale) {
                    strongSelf.transform = strongSelf.vProperty.transform;
                } else {
                    strongSelf.layer.transform = strongSelf.vProperty.transform3D;
                }
            }
            else if (strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypeFrame) // 修改frame值的动画
            {
                CGRect tmpFrame = strongSelf.frame;
                
                FWPopupAlignment alignment = strongSelf.vProperty.popupAlignment;
                if (alignment == FWPopupAlignmentTop || alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopRight || alignment == FWPopupAlignmentCenter)
                {
                    tmpFrame.size.height = 0;
                }
                else if (alignment == FWPopupAlignmentLeft || alignment == FWPopupAlignmentLeftCenter)
                {
                    tmpFrame.size.width = 0;
                }
                else if (alignment == FWPopupAlignmentBottom || alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomRight)
                {
                    tmpFrame.origin.y = CGRectGetMaxY(strongSelf.finalFrame);
                    tmpFrame.size.height = 0;
                }
                else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
                {
                    tmpFrame.origin.x = CGRectGetMaxX(strongSelf.finalFrame);
                    tmpFrame.size.width = 0;
                }
                strongSelf.frame = tmpFrame;
            }
            
            [strongSelf layoutIfNeeded];
            
            [UIView animateWithDuration:strongSelf.vProperty.animationDuration delay:0.0 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                switch (strongSelf.vProperty.popupAnimationType) {
                    case FWPopupAnimationTypePosition:
                        break;
                    case FWPopupAnimationTypeScale:
                        strongSelf.transform = CGAffineTransformIdentity;
                        break;
                    case FWPopupAnimationTypeScale3D:
                        strongSelf.layer.transform = CATransform3DIdentity;
                        break;
                    default:
                        strongSelf.frame = strongSelf.finalFrame;
                        break;
                }
                
                [strongSelf.superview layoutIfNeeded];
                
            } completion:^(BOOL finished) {
                
                if (strongSelf.popupCompletionBlock != nil) {
                    strongSelf.popupCompletionBlock(strongSelf, YES);
                }
                
            }];
        }
    };
    return popupBlock;
}

- (FWPopupBlock)hideCustomAnimation
{
    __weak typeof(self) weakSelf = self;
    FWPopupBlock popupBlock = ^(FWPopupBaseView *popupBaseView){
        
        __strong typeof(self) strongSelf = weakSelf;
        
        [UIView animateWithDuration:strongSelf.vProperty.animationDuration delay:0.0 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            if (strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypePosition) // 位移动画
            {
                CGRect tmpFrame = strongSelf.frame;
                FWPopupAlignment alignment = strongSelf.vProperty.popupAlignment;
                if (alignment == FWPopupAlignmentTop || alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopRight || alignment == FWPopupAlignmentCenter)
                {
                    tmpFrame.origin.y = -(strongSelf.frame.origin.y + strongSelf.frame.size.height);
                }
                else if (alignment == FWPopupAlignmentLeft || alignment == FWPopupAlignmentLeftCenter)
                {
                    tmpFrame.origin.x = -(strongSelf.frame.origin.x + strongSelf.frame.size.width);
                }
                else if (alignment == FWPopupAlignmentBottom || alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomRight)
                {
                    tmpFrame.origin.y = strongSelf.attachedView.frame.size.height;
                }
                else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
                {
                    tmpFrame.origin.x = strongSelf.attachedView.frame.size.width;
                }
                strongSelf.frame = tmpFrame;
            }
            else if (strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypeScale || strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypeScale3D) // 缩放动画/3D缩放动画
            {
                strongSelf.layer.anchorPoint = [strongSelf obtainAnchorPoint];
                strongSelf.frame = strongSelf.finalFrame;
                strongSelf.transform = strongSelf.vProperty.transform;
            }
            else if (strongSelf.vProperty.popupAnimationType == FWPopupAnimationTypeFrame) // 修改frame值的动画
            {
                CGRect tmpFrame = strongSelf.frame;
                FWPopupAlignment alignment = strongSelf.vProperty.popupAlignment;
                if (alignment == FWPopupAlignmentTop || alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopRight || alignment == FWPopupAlignmentCenter)
                {
                    tmpFrame.size.height = 0;
                }
                else if (alignment == FWPopupAlignmentLeft || alignment == FWPopupAlignmentLeftCenter)
                {
                    tmpFrame.size.width = 0;
                }
                else if (alignment == FWPopupAlignmentBottom || alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomRight)
                {
                    tmpFrame.origin.y = CGRectGetMaxY(strongSelf.finalFrame);
                    tmpFrame.size.height = 0;
                }
                else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
                {
                    tmpFrame.origin.x = CGRectGetMaxX(strongSelf.finalFrame);
                    tmpFrame.size.width = 0;
                }
                strongSelf.frame = tmpFrame;
            }
            
            [strongSelf.superview layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                [strongSelf removeFromSuperview];
            }
            if (strongSelf.popupCompletionBlock != nil) {
                strongSelf.popupCompletionBlock(strongSelf, NO);
            }
            
            // 还原视图，防止下次动画时出错
            switch (strongSelf.vProperty.popupAnimationType) {
                case FWPopupAnimationTypeFrame:
                {
                    strongSelf.frame = strongSelf.finalFrame;
                }
                    break;
                case FWPopupAnimationTypePosition:
                {
                    strongSelf.frame = strongSelf.finalFrame;
                }
                    break;
                default:
                {
                    strongSelf.transform = CGAffineTransformIdentity;
                }
                    break;
            }
        }];
    };
    return popupBlock;
}

- (CGPoint)obtainAnchorPoint
{
    CGFloat tmpX = 0.0;
    CGFloat tmpY = 0.0;
    
    FWPopupAlignment alignment = self.vProperty.popupAlignment;
    if (alignment == FWPopupAlignmentCenter)
    {
        tmpX = 0.5;
        tmpY = 0.5;
    }
    else if (alignment == FWPopupAlignmentTop || alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopRight)
    {
        if (self.vProperty.popupArrowStyle == FWPopupArrowStyleNone) {
            tmpX = self.vProperty.popupArrowVertexScaleX;
        } else {
            CGFloat arrowVertexX = (self.frame.size.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2;
            tmpX = arrowVertexX / self.frame.size.width;
        }
        tmpY = 0;
    }
    else if (alignment == FWPopupAlignmentLeft || alignment == FWPopupAlignmentLeftCenter)
    {
        tmpX = 0;
        tmpY = 0.5;
    }
    else if (alignment == FWPopupAlignmentBottom || alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomRight)
    {
        if (self.vProperty.popupArrowStyle == FWPopupArrowStyleNone) {
            tmpX = self.vProperty.popupArrowVertexScaleX;
        } else {
            CGFloat arrowVertexX = (self.frame.size.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2;
            tmpX = arrowVertexX / self.frame.size.width;
        }
        tmpY = 1;
    }
    else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
    {
        tmpX = 1;
        tmpY = 0.5;
    }
    return CGPointMake(tmpX, tmpY);
}

- (void)setupFrame
{
    if (!self.haveSetFrame) {
        
        CGRect tmpFrame = self.frame;
        switch (self.vProperty.popupAlignment) {
            case FWPopupAlignmentCenter:
                tmpFrame.origin.x += (CGRectGetWidth(self.attachedView.frame) - CGRectGetWidth(self.frame)) / 2 + self.vProperty.popupEdgeInsets.left - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y += (CGRectGetHeight(self.attachedView.frame) - CGRectGetHeight(self.frame)) / 2 +self.vProperty.popupEdgeInsets.top - self.vProperty.popupEdgeInsets.bottom;
                break;
                
            case FWPopupAlignmentTop:
                tmpFrame.origin.x += self.vProperty.popupEdgeInsets.left - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y = self.vProperty.popupEdgeInsets.top;
                break;
            case FWPopupAlignmentLeft:
                tmpFrame.origin.x = self.vProperty.popupEdgeInsets.left;
                tmpFrame.origin.y += self.vProperty.popupEdgeInsets.top - self.vProperty.popupEdgeInsets.bottom;
                break;
            case FWPopupAlignmentBottom:
                tmpFrame.origin.x += self.vProperty.popupEdgeInsets.left - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y = self.attachedView.frame.size.height - self.frame.size.height - self.vProperty.popupEdgeInsets.bottom;
                break;
            case FWPopupAlignmentRight:
                tmpFrame.origin.x = self.attachedView.frame.size.width - self.frame.size.width - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y += self.vProperty.popupEdgeInsets.top - self.vProperty.popupEdgeInsets.bottom;
                break;
                
            case FWPopupAlignmentTopCenter:
                tmpFrame.origin.x = (self.attachedView.frame.size.width - self.frame.size.width)/2 + self.vProperty.popupEdgeInsets.left - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y = self.vProperty.popupEdgeInsets.top;
                break;
            case FWPopupAlignmentLeftCenter:
                tmpFrame.origin.x = self.vProperty.popupEdgeInsets.left;
                tmpFrame.origin.y = (self.attachedView.frame.size.height - self.frame.size.height)/2 + self.vProperty.popupEdgeInsets.top - self.vProperty.popupEdgeInsets.bottom;
                break;
            case FWPopupAlignmentBottomCenter:
                tmpFrame.origin.x = (self.attachedView.frame.size.width - self.frame.size.width)/2 + self.vProperty.popupEdgeInsets.left - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y = self.attachedView.frame.size.height - self.frame.size.height - self.vProperty.popupEdgeInsets.bottom;
                break;
            case FWPopupAlignmentRightCenter:
                tmpFrame.origin.x = self.attachedView.frame.size.width - self.frame.size.width - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y = (self.attachedView.frame.size.height - self.frame.size.height)/2 + self.vProperty.popupEdgeInsets.top - self.vProperty.popupEdgeInsets.bottom;
                break;
                
            case FWPopupAlignmentTopLeft:
                tmpFrame.origin.x = self.vProperty.popupEdgeInsets.left;
                tmpFrame.origin.y = self.vProperty.popupEdgeInsets.top;
                break;
            case FWPopupAlignmentTopRight:
                tmpFrame.origin.x = self.attachedView.frame.size.width - self.frame.size.width - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y = self.vProperty.popupEdgeInsets.top;
                break;
            case FWPopupAlignmentBottomLeft:
                tmpFrame.origin.x = self.vProperty.popupEdgeInsets.left;
                tmpFrame.origin.y = self.attachedView.frame.size.height - self.frame.size.height - self.vProperty.popupEdgeInsets.bottom;
                break;
            case FWPopupAlignmentBottomRight:
                tmpFrame.origin.x = self.attachedView.frame.size.width - self.frame.size.width - self.vProperty.popupEdgeInsets.right;
                tmpFrame.origin.y = self.attachedView.frame.size.height - self.frame.size.height - self.vProperty.popupEdgeInsets.bottom;
                break;
                
            default:
                break;
        }
        self.frame = tmpFrame;
        self.finalFrame = tmpFrame;
    }
}


#pragma mark - ----------------------- 其他 -----------------------

- (void)tapGestureAction:(UIGestureRecognizer *)gesture
{
    
}

- (void)showKeyboard
{
    // 供子类重写
}

- (void)hideKeyboard
{
    // 供子类重写
}


#pragma mark - ----------------------- GET、SET -----------------------

- (void)setVProperty:(FWPopupBaseViewProperty *)vProperty
{
    _vProperty = vProperty;
    self.attachedView.dimMaskAnimationDuration = vProperty.animationDuration;
    if (vProperty.backgroundColor != nil) {
        self.backgroundColor = vProperty.backgroundColor;
    }
}

- (void)setAttachedView:(UIView *)attachedView
{
    _attachedView = attachedView;
    if ([attachedView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *view = (UIScrollView *)attachedView;
        view.scrollEnabled = NO;
    }
}

- (BOOL)visible
{
    return !(self.attachedView.dimMaskView.alpha == 0);
}

@end


#pragma mark - ======================= 可配置属性 =======================

@implementation FWPopupBaseViewProperty

+ (instancetype)manager
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupParams];
    }
    return self;
}

- (void)setupParams
{
    self.titleFontSize = 18.0;
    self.titleColor = kPvRGB(51, 51, 51);
    
    self.buttonFontSize = 17.0;
    self.buttonHeight = 48.0;
    self.itemNormalColor = kPvRGB(51, 51, 51);
    self.itemHighlightColor = kPvRGB(254, 226, 4);
    self.itemPressedColor = kPvRGB(231, 231, 231);
    
    self.topBottomMargin = 10;
    self.letfRigthMargin = 10;
    self.commponentMargin = 10;
    
    self.splitColor = kPvRGB(231, 231, 231);
    self.splitWidth = (1/[UIScreen mainScreen].scale);
    self.cornerRadius = 5.0;
    
    self.popupViewMaxHeight = [UIScreen mainScreen].bounds.size.height * 0.6;
    
    self.popupArrowStyle = FWPopupArrowStyleNone;
    self.popupArrowSize = CGSizeMake(28, 12);
    self.popupArrowVertexScaleX = 0.5;
    self.popupArrowCornerRadius = 2.5;
    self.popupArrowBottomCornerRadius = 4.0;
    
    self.popupAlignment = FWPopupAlignmentCenter;
    self.popupAnimationType = FWPopupAnimationTypePosition;
    
    self.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.animationDuration = 0.2;
    
    self.transform3D = CATransform3DMakeScale(1.2, 1.2, 1.0);
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
}

- (void)setPopupArrowVertexScaleX:(CGFloat)popupArrowVertexScaleX
{
    CGFloat tmp = popupArrowVertexScaleX;
    if (popupArrowVertexScaleX > 1) {
        tmp = 1;
    } else if (popupArrowVertexScaleX < 0) {
        tmp = 0;
    }
    _popupArrowVertexScaleX = tmp;
}

@end
