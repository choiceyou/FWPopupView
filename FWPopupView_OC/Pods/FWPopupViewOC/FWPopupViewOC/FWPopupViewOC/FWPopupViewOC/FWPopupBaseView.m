//
//  FWPopupBaseView.m
//  FWPopupViewOC
//
//  Created by xfg on 2017/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWPopupBaseView.h"
#import "FWPopupWindow.h"
#import <QuartzCore/QuartzCore.h>

/**
 弹窗显示、隐藏回调，内部回调，该回调不对外
 
 @param popupBaseView self
 */
typedef void(^FWPopupBlock)(FWPopupBaseView *popupBaseView);


@interface FWPopupBaseView()

@property (nonatomic, copy) FWPopupDidAppearBlock popupDidAppearBlock;
@property (nonatomic, copy) FWPopupDidDisappearBlock popupDidDisappearBlock;
@property (nonatomic, copy) FWPopupStateBlock popupStateBlock;
@property (nonatomic, copy) FWPopupBlock showAnimation;
@property (nonatomic, copy) FWPopupBlock hideAnimation;
/**
 弹窗真正的frame
 */
@property (nonatomic, assign) CGRect finalFrame;
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
 记录弹窗弹起前keywindow
 */
@property (nonatomic, strong) UIWindow *originKeyWindow;

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
        [self setupParams];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupParams];
}

- (void)setupParams
{
    self.backgroundColor = [UIColor whiteColor];
    
    _attachedView = [FWPopupWindow sharedWindow].attachView;
    
    _originMaskViewColor = self.attachedView.dimMaskViewColor;
    _originTouchWildToHide = [FWPopupWindow sharedWindow].touchWildToHide;
    
    self.showAnimation = [self showCustomAnimation];
    self.hideAnimation = [self hideCustomAnimation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyHideAll:) name:FWHideAllPopupViewNotification object:nil];
}


#pragma mark - ----------------------- 显示、隐藏 -----------------------

/**
 显示
 */
- (void)show
{
    [self showWithDidAppearBlock:nil];
}

/**
 弹窗已经显示
 
 @param didAppearBlock 弹窗已经显示回调
 */
- (void)showWithDidAppearBlock:(FWPopupDidAppearBlock)didAppearBlock
{
    if (didAppearBlock != nil) {
        self.popupDidAppearBlock = didAppearBlock;
    }
    [self showWithStateBlock:nil];
}

/**
 显示：弹窗状态回调，注意：该回调会走N次
 
 @param stateBlock 弹窗状态回调，注意：该回调会走N次
 */
- (void)showWithStateBlock:(FWPopupStateBlock)stateBlock
{
    if (stateBlock != nil) {
        self.popupStateBlock = stateBlock;
        self.popupStateBlock(self, FWPopupStateWillAppear);
    }
    
    if (self.attachedView == nil) {
        self.attachedView = FWPopupWindow.sharedWindow.attachView;
    }
    
    self.originKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
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
            self.tapGest.delegate = self;
            [self.attachedView addGestureRecognizer:self.tapGest];
        } else {
            self.tapGest.enabled = YES;
        }
        if ([self.attachedView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *view = (UIScrollView *)self.attachedView;
            view.scrollEnabled = NO;
        }
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
    [self hideWithDidDisappearBlock:nil];
}

/**
 弹窗已经隐藏
 
 @param didDisappearBlock 弹窗已经隐藏回调
 */
- (void)hideWithDidDisappearBlock:(FWPopupDidDisappearBlock)didDisappearBlock
{
    if (didDisappearBlock != nil) {
        self.popupDidDisappearBlock = didDisappearBlock;
    }
    if (self.popupStateBlock != nil) {
        self.popupStateBlock(self, FWPopupStateWillDisappear);
    }
    
    self.attachedView.dimMaskAnimationDuration = self.vProperty.animationDuration;
    
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
    [self.originKeyWindow makeKeyWindow];
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
    FWPWeakify(self)
    FWPopupBlock popupBlock = ^(FWPopupBaseView *popupBaseView) {
        
        FWPStrongify(self)
        
        if (self.superview == nil)
        {
            // 保证前一次弹窗销毁完毕
            for (UIView *view in self.attachedView.dimMaskView.subviews)
            {
                [view removeFromSuperview];
            }
            [self.attachedView.dimMaskView addSubview:self];
            
            [self setupFrame];
            
            if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition) // 位移动画
            {
                [self positionAnimationChangeFrame];
            }
            else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale || self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale3D) // 缩放动画/3D缩放动画
            {
                self.layer.anchorPoint = [self obtainAnchorPoint];
                self.frame = self.finalFrame;
                if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale && [[UIDevice currentDevice].systemVersion doubleValue] >= 11.0)
                {
                    self.transform = self.vProperty.transform;
                }
                else
                {
                    self.layer.transform = self.vProperty.transform3D;
                }
            }
            else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame) // 修改frame值的动画
            {
                CGRect tmpFrame = self.frame;
                
                FWPopupAlignment alignment = self.vProperty.popupAlignment;
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
                    tmpFrame.origin.y = CGRectGetMaxY(self.finalFrame);
                    tmpFrame.size.height = 0;
                }
                else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
                {
                    tmpFrame.origin.x = CGRectGetMaxX(self.finalFrame);
                    tmpFrame.size.width = 0;
                }
                self.frame = tmpFrame;
            }
            
            [self layoutIfNeeded];
            
            if (self.vProperty.usingSpringWithDamping >= 0 && self.vProperty.usingSpringWithDamping <= 1)
            {
                [UIView animateWithDuration:self.vProperty.animationDuration delay:0.0 usingSpringWithDamping:self.vProperty.usingSpringWithDamping initialSpringVelocity:self.vProperty.initialSpringVelocity options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    [self showAnimationDuration];
                    
                } completion:^(BOOL finished) {
                    
                    if (self.popupDidAppearBlock != nil) {
                        self.popupDidAppearBlock(self);
                    }
                    if (self.popupStateBlock != nil) {
                        self.popupStateBlock(self, FWPopupStateDidAppear);
                    }
                    
                }];
            }
            else
            {
                [UIView animateWithDuration:self.vProperty.animationDuration delay:0.0 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    [self showAnimationDuration];
                    
                } completion:^(BOOL finished) {
                    
                    if (self.popupDidAppearBlock != nil) {
                        self.popupDidAppearBlock(self);
                    }
                    if (self.popupStateBlock != nil) {
                        self.popupStateBlock(self, FWPopupStateDidAppear);
                    }
                    
                }];
            }
        }
    };
    return popupBlock;
}

- (void)showAnimationDuration
{
    switch (self.vProperty.popupAnimationStyle) {
        case FWPopupAnimationStylePosition:
            self.frame = self.finalFrame;
            break;
        case FWPopupAnimationStyleScale:
            self.transform = CGAffineTransformIdentity;
            break;
        case FWPopupAnimationStyleScale3D:
            self.layer.transform = CATransform3DIdentity;
            break;
        default:
            self.frame = self.finalFrame;
            break;
    }
    
    [self.superview layoutIfNeeded];
}

- (FWPopupBlock)hideCustomAnimation
{
    FWPWeakify(self)
    FWPopupBlock popupBlock = ^(FWPopupBaseView *popupBaseView){
        
        FWPStrongify(self)
        [UIView animateWithDuration:self.vProperty.animationDuration delay:0.0 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition) // 位移动画
            {
                [self positionAnimationChangeFrame];
            }
            else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale || self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale3D) // 缩放动画/3D缩放动画
            {
                self.layer.anchorPoint = [self obtainAnchorPoint];
                self.frame = self.finalFrame;
                self.transform = self.vProperty.transform;
            }
            else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame) // 修改frame值的动画
            {
                CGRect tmpFrame = self.frame;
                FWPopupAlignment alignment = self.vProperty.popupAlignment;
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
                    tmpFrame.origin.y = CGRectGetMaxY(self.finalFrame);
                    tmpFrame.size.height = 0;
                }
                else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
                {
                    tmpFrame.origin.x = CGRectGetMaxX(self.finalFrame);
                    tmpFrame.size.width = 0;
                }
                self.frame = tmpFrame;
            }
            
            [self.superview layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                [self removeFromSuperview];
            }
            
            // 还原视图，防止下次动画时出错
            switch (self.vProperty.popupAnimationStyle) {
                case FWPopupAnimationStyleFrame:
                {
                    self.frame = self.finalFrame;
                }
                    break;
                case FWPopupAnimationStylePosition:
                {
                    self.frame = self.finalFrame;
                }
                    break;
                default:
                {
                    self.transform = CGAffineTransformIdentity;
                }
                    break;
            }
            if (self.vProperty.shouldClearSpilthMask) {
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.attachedView.bounds];
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                maskLayer.frame = self.attachedView.bounds;
                maskLayer.path = path.CGPath;
                self.attachedView.layer.mask = maskLayer;
            }
            
            // 确保销毁完成后再回调
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.popupDidDisappearBlock != nil) {
                    self.popupDidDisappearBlock(self);
                }
                if (self.popupStateBlock != nil) {
                    self.popupStateBlock(self, FWPopupStateDidDisappear);
                }
            });
            
        }];
    };
    return popupBlock;
}

- (void)positionAnimationChangeFrame
{
    CGRect tmpFrame = self.frame;
    FWPopupAlignment alignment = self.vProperty.popupAlignment;
    if (alignment == FWPopupAlignmentTop || alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopRight || alignment == FWPopupAlignmentCenter)
    {
        tmpFrame.origin.y = -(self.frame.origin.y + self.frame.size.height);
    }
    else if (alignment == FWPopupAlignmentLeft || alignment == FWPopupAlignmentLeftCenter)
    {
        tmpFrame.origin.x = -(self.frame.origin.x + self.frame.size.width);
    }
    else if (alignment == FWPopupAlignmentBottom || alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomRight)
    {
        tmpFrame.origin.y = self.attachedView.frame.size.height;
    }
    else if (alignment == FWPopupAlignmentRight || alignment == FWPopupAlignmentRightCenter)
    {
        tmpFrame.origin.x = self.attachedView.frame.size.width;
    }
    self.frame = tmpFrame;
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
            CGFloat arrowVertexX = (self.finalFrame.size.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2;
            tmpX = arrowVertexX / self.finalFrame.size.width;
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
            CGFloat arrowVertexX = (self.finalFrame.size.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2;
            tmpX = arrowVertexX / self.finalFrame.size.width;
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

/**
 设置弹窗最终需要展示的frame
 */
- (void)setupFrame
{
    if (!self.haveSetFrame)
    {
        self.haveSetFrame = YES;
        
        CGRect tmpFrame = self.frame;
        switch (self.vProperty.popupAlignment)
        {
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
    
    [self setupSpilthMask];
}

/**
 处理多余部分的遮罩层
 */
- (void)setupSpilthMask
{
    CGRect spilthMaskFrame = CGRectMake(0, 0, 0, 0);
    
    if (!self.vProperty.shouldClearSpilthMask) {
        return;
    }
    
    if (self.vProperty.popupAlignment == FWPopupAlignmentTop || self.vProperty.popupAlignment == FWPopupAlignmentTopCenter || self.vProperty.popupAlignment == FWPopupAlignmentTopLeft || self.vProperty.popupAlignment == FWPopupAlignmentTopRight)
    {
        spilthMaskFrame = CGRectMake(0, 0, self.attachedView.frame.size.width, self.finalFrame.origin.y);
    }
    else if (self.vProperty.popupAlignment == FWPopupAlignmentLeft || self.vProperty.popupAlignment == FWPopupAlignmentLeftCenter)
    {
        spilthMaskFrame = CGRectMake(0, 0, self.finalFrame.origin.x, self.attachedView.frame.size.height);
    }
    else if (self.vProperty.popupAlignment == FWPopupAlignmentBottom || self.vProperty.popupAlignment == FWPopupAlignmentBottomCenter || self.vProperty.popupAlignment == FWPopupAlignmentBottomLeft || self.vProperty.popupAlignment == FWPopupAlignmentBottomRight)
    {
        spilthMaskFrame = CGRectMake(0, CGRectGetMaxY(self.finalFrame), self.attachedView.frame.size.width, self.attachedView.frame.size.height - CGRectGetMaxY(self.finalFrame));
    }
    else if (self.vProperty.popupAlignment == FWPopupAlignmentRight || self.vProperty.popupAlignment == FWPopupAlignmentRightCenter)
    {
        spilthMaskFrame = CGRectMake(self.attachedView.frame.size.width - CGRectGetMaxX(self.finalFrame), 0, self.attachedView.frame.size.width - CGRectGetMaxX(self.finalFrame), self.attachedView.frame.size.height);
    }
    
    if (spilthMaskFrame.size.width > 0 && spilthMaskFrame.size.height > 0)
    {
        // 获取可见区域的路径(开始路径)
        UIBezierPath *visualPath = [UIBezierPath bezierPathWithRoundedRect:spilthMaskFrame cornerRadius:0];
        // 获取终点路径
        UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:self.attachedView.bounds];
        [toPath appendPath:visualPath];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.attachedView.bounds;
        maskLayer.path = toPath.CGPath;
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        
        self.attachedView.layer.mask = maskLayer;
    }
}


#pragma mark - ----------------------- 其他 -----------------------

- (void)tapGestureAction:(UIGestureRecognizer *)gesture
{
    [self clicedMaskView];
    
    if ([FWPopupWindow sharedWindow].touchWildToHide && !self.dimMaskAnimating)
    {
        for (UIView *v in self.attachedView.dimMaskView.subviews)
        {
            if ([v isKindOfClass:[FWPopupBaseView class]])
            {
                FWPopupBaseView *popupView = (FWPopupBaseView *)v;
                [popupView hide];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == self.attachedView.dimMaskView;
}

- (void)clicedMaskView
{
    // 供子类重写
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
        self.originScrollEnabled = view.scrollEnabled;
    }
}

- (BOOL)visible
{
    return !(self.attachedView.dimMaskView.alpha == 0);
}

- (CGRect)realFrame
{
    return self.finalFrame;
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
    self.popupAnimationStyle = FWPopupAnimationStylePosition;
    
    self.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.animationDuration = 0.2;
    self.usingSpringWithDamping = -1;
    self.initialSpringVelocity = 5;
    
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
