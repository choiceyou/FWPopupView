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
#import "Masonry.h"

/**
 弹窗显示回调，内部回调，该回调不对外
 
 @param popupBaseView self
 */
typedef void(^FWPopupShowBlock)(FWPopupBaseView *popupBaseView);

/**
 弹窗隐藏回调，内部回调，该回调不对外
 
 @param popupBaseView self
 @param hideWithRemove 是否从父视图中移除当前视图
 */
typedef void(^FWPopupHideBlock)(FWPopupBaseView *popupBaseView, BOOL hideWithRemove);

/**
 当前约束的状态
 
 - FWConstraintsStatesBeforeAnimation: 动画之前的约束
 - FWConstraintsStatesShownAnimation: 显示动画的约束
 - FWConstraintsStatesHiddenAnimation: 隐藏动画的约束
 */
typedef NS_ENUM(NSInteger, FWConstraintsStates) {
    FWConstraintsStatesBeforeAnimation,
    FWConstraintsStatesShownAnimation,
    FWConstraintsStatesHiddenAnimation,
};


@interface FWPopupBaseView()

@property (nonatomic, copy) FWPopupDidAppearBlock popupDidAppearBlock;
@property (nonatomic, copy) FWPopupDidDisappearBlock popupDidDisappearBlock;
@property (nonatomic, copy) FWPopupStateBlock popupStateBlock;
@property (nonatomic, copy) FWPopupShowBlock showAnimation;
@property (nonatomic, copy) FWPopupHideBlock hideAnimation;

/**
 弹窗真正的Size
 */
@property (nonatomic, assign) CGRect finalFrame;
/**
 当前Constraints是否被设置过了
 */
@property (nonatomic, assign) BOOL haveSetConstraints;
/**
 是否重新设置了父视图
 */
@property (nonatomic, assign) BOOL isResetSuperView;

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

- (void)resetSize:(CGSize)size isImmediateEffect:(BOOL)isImmediateEffect
{
    self.finalFrame = CGRectMake(0, 0, size.width, size.height);
    
    if (isImmediateEffect && (self.currentPopupState == FWPopupStateDidAppear || self.currentPopupState == FWPopupStateDidAppearAgain)) {
        FWPWeakify(self)
        [self hideWithDidDisappearBlock:^(FWPopupBaseView *popupBaseView) {
            FWPStrongify(self)
            if (self.popupDidAppearBlock != nil) {
                [self showWithDidAppearBlock:self.popupDidAppearBlock];
            } else if (self.popupStateBlock != nil) {
                [self showWithStateBlock:self.popupStateBlock];
            } else {
                [self show];
            }
        }];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupParams];
}

- (instancetype)initWithConstraints
{
    self = [super init];
    if (self) {
        [self setupParams];
        [self.attachedView.dimMaskView addSubview:self];
        self.hidden = YES;
        [[FWPopupWindow sharedWindow].needConstraintsViews addObject:self];
    }
    return self;
}

- (void)setupParams
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.attachedView = [FWPopupWindow sharedWindow].attachView;
    
    _originMaskViewColor = self.attachedView.dimMaskViewColor;
    _originTouchWildToHide = [FWPopupWindow sharedWindow].touchWildToHide;
    self.hidden = YES;
    
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
    self.popupDidAppearBlock = didAppearBlock;
    [self showWithStateBlock:nil];
}

/**
 显示：弹窗状态回调，注意：该回调会走N次
 
 @param stateBlock 弹窗状态回调，注意：该回调会走N次
 */
- (void)showWithStateBlock:(FWPopupStateBlock)stateBlock
{
    if (self.attachedView == nil) {
        self.attachedView = FWPopupWindow.sharedWindow.attachView;
    }
    if (self.superview == nil) {
        [self.attachedView.dimMaskView addSubview:self];
        self.isResetSuperView = YES;
    }
    
    self.popupStateBlock = stateBlock;
    
    if (self.attachedView.dimMaskAnimating) {
        [[FWPopupWindow sharedWindow].willShowingViews addObject:self];
    } else {
        [self showNow];
    }
}

- (void)showNow
{
    if (self.currentPopupState == FWPopupStateWillAppear || self.currentPopupState == FWPopupStateDidAppear || self.currentPopupState == FWPopupStateDidAppearButCovered || self.currentPopupState == FWPopupStateDidAppearAgain) {
        return;
    }
    
    self.currentPopupState = FWPopupStateWillAppear;
    
    self.originKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (self.vProperty.maskViewColor != nil) {
        self.attachedView.dimMaskViewColor = self.vProperty.maskViewColor;
    }
    if (self.vProperty.touchWildToHide != nil && ![self.vProperty.touchWildToHide isEqualToString:@""] && [self.vProperty.touchWildToHide integerValue] == 1) {
        [FWPopupWindow sharedWindow].touchWildToHide = YES;
    } else {
        [FWPopupWindow sharedWindow].touchWildToHide = NO;
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
    
    FWPopupShowBlock showBlock = self.showAnimation;
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
    self.popupDidDisappearBlock = didDisappearBlock;
    
    [self hideNow:YES];
}

- (void)hideNow:(BOOL)isRemove
{
    if (self.currentPopupState == FWPopupStateWillDisappear || self.currentPopupState == FWPopupStateDidDisappear) {
        return;
    }
    self.currentPopupState = FWPopupStateWillDisappear;
    
    self.attachedView.dimMaskAnimationDuration = self.vProperty.animationDuration;
    
    if ([FWPopupWindow sharedWindow].hiddenViews.count == 0 && [FWPopupWindow sharedWindow].willShowingViews.count == 0 && !self.attachedView.dimMaskAnimating) {
        [self.attachedView hideDimMask];
    }
    
    if (self.withKeyboard) {
        [self hideKeyboard];
    }
    
    FWPopupHideBlock hideBlock = self.hideAnimation;
    hideBlock(self, isRemove);
    
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

/**
 显示动画
 
 @return FWPopupShowBlock
 */
- (FWPopupShowBlock)showCustomAnimation
{
    FWPWeakify(self)
    FWPopupShowBlock popupBlock = ^(FWPopupBaseView *popupBaseView) {
        
        FWPStrongify(self)
        
        // 保证前一次弹窗销毁完毕
        NSMutableArray *tmpHiddenViews = [NSMutableArray array];
        for (UIView *view in self.attachedView.dimMaskView.subviews) {
            if ([view isKindOfClass:[FWPopupBaseView class]]) {
                FWPopupBaseView *tmpView = (FWPopupBaseView *)view;
                if (view == self) {
                    tmpView.hidden = NO;
                } else if (![[FWPopupWindow sharedWindow].needConstraintsViews containsObject:view] && tmpView.currentPopupState != FWPopupStateUnKnow) {
                    tmpView.hidden = YES;
                    tmpView.currentPopupState = FWPopupStateDidAppearButCovered;
                    [tmpHiddenViews addObject:view];
                }
            }
        }
        [[FWPopupWindow sharedWindow].hiddenViews removeAllObjects];
        [[FWPopupWindow sharedWindow].hiddenViews addObjectsFromArray:tmpHiddenViews];
        
        if (!self.haveSetConstraints || self.isResetSuperView) {
            [self setupConstraints:FWConstraintsStatesBeforeAnimation];
        }
        
        [self setupConstraints:FWConstraintsStatesShownAnimation];
        
        self.attachedView.dimMaskAnimating = YES;
        
        if (self.vProperty.usingSpringWithDamping >= 0 && self.vProperty.usingSpringWithDamping <= 1)
        {
            [UIView animateWithDuration:self.vProperty.animationDuration delay:0.0 usingSpringWithDamping:self.vProperty.usingSpringWithDamping initialSpringVelocity:self.vProperty.initialSpringVelocity options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                [self showAnimationDuration];
                
            } completion:^(BOOL finished) {
                
                [self showAnimationFinished];
                
            }];
        }
        else
        {
            [UIView animateWithDuration:self.vProperty.animationDuration delay:0.0 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                [self showAnimationDuration];
                
            } completion:^(BOOL finished) {
                
                [self showAnimationFinished];
                
            }];
        }
    };
    return popupBlock;
}

/**
 显示动画的操作
 */
- (void)showAnimationDuration
{
    switch (self.vProperty.popupAnimationStyle) {
        case FWPopupAnimationStylePosition:
            [self.superview layoutIfNeeded];
            break;
        case FWPopupAnimationStyleFrame:
            [self.superview layoutIfNeeded];
            [self layoutIfNeeded];
            break;
        case FWPopupAnimationStyleScale:
            self.transform = CGAffineTransformIdentity;
            break;
        case FWPopupAnimationStyleScale3D:
            self.layer.transform = CATransform3DIdentity;
            break;
        default:
            break;
    }
    
    self.finalFrame = self.frame;
    [self setupSpilthMask];
}

/**
 显示动画完成后的操作
 */
- (void)showAnimationFinished
{
    if (self.popupDidAppearBlock != nil) {
        self.popupDidAppearBlock(self);
    }
    self.currentPopupState = FWPopupStateDidAppear;
    
    if ([FWPopupWindow sharedWindow].willShowingViews.count > 0) {
        FWPopupBaseView *willShowingView = [FWPopupWindow sharedWindow].willShowingViews.firstObject;
        [willShowingView showNow];
        [[FWPopupWindow sharedWindow].willShowingViews removeObjectAtIndex:0];
    } else {
        self.attachedView.dimMaskAnimating = NO;
    }
}

/**
 隐藏动画
 
 @return FWPopupHideBlock
 */
- (FWPopupHideBlock)hideCustomAnimation
{
    FWPWeakify(self)
    FWPopupHideBlock popupBlock = ^(FWPopupBaseView *popupBaseView, BOOL hideWithRemove){
        
        FWPStrongify(self)
        
        [self setupConstraints:FWConstraintsStatesHiddenAnimation];
        
        self.attachedView.dimMaskAnimating = YES;
        
        [UIView animateWithDuration:self.vProperty.animationDuration delay:0.0 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            switch (self.vProperty.popupAnimationStyle) {
                case FWPopupAnimationStylePosition:
                    [self.superview layoutIfNeeded];
                    break;
                case FWPopupAnimationStyleFrame:
                    [self.superview layoutIfNeeded];
                    [self layoutIfNeeded];
                    break;
                case FWPopupAnimationStyleScale:
                    self.transform = self.vProperty.transform;
                    break;
                case FWPopupAnimationStyleScale3D:
                    self.transform = self.vProperty.transform;
                    break;
                default:
                    break;
            }
            
        } completion:^(BOOL finished) {
            
            self.hidden = YES;
            if (hideWithRemove) {
                [self removeFromSuperview];
                if ([[FWPopupWindow sharedWindow].hiddenViews containsObject:self]) {
                    [[FWPopupWindow sharedWindow].hiddenViews removeObject:self];
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                self.currentPopupState = FWPopupStateDidDisappear;
                if (self.popupDidDisappearBlock != nil) {
                    self.popupDidDisappearBlock(self);
                }
                
                FWPopupBaseView *nextShowView = nil;
                if ([FWPopupWindow sharedWindow].willShowingViews.count > 0) {
                    nextShowView = [FWPopupWindow sharedWindow].willShowingViews.lastObject;
                    [nextShowView showNow];
                    [[FWPopupWindow sharedWindow].willShowingViews removeLastObject];
                } else if ([FWPopupWindow sharedWindow].hiddenViews.count > 0) {
                    nextShowView = [FWPopupWindow sharedWindow].hiddenViews.lastObject;
                    nextShowView.hidden = NO;
                    nextShowView.currentPopupState = FWPopupStateDidAppearAgain;
                    [[FWPopupWindow sharedWindow].hiddenViews removeLastObject];
                    if (self.vProperty.touchWildToHide != nil && ![self.vProperty.touchWildToHide isEqualToString:@""] && [self.vProperty.touchWildToHide integerValue] == 1) {
                        [FWPopupWindow sharedWindow].touchWildToHide = YES;
                    } else {
                        [FWPopupWindow sharedWindow].touchWildToHide = NO;
                    }
                } else {
                    [[FWPopupWindow sharedWindow].needConstraintsViews removeAllObjects];
                }
                
                if (self.vProperty.shouldClearSpilthMask || [FWPopupWindow sharedWindow].shouldResetDimMaskView) {
                    if (nextShowView != nil) {
                        [FWPopupWindow sharedWindow].shouldResetDimMaskView = YES;
                        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.attachedView.bounds];
                        CAShapeLayer *maskLayer = [CAShapeLayer layer];
                        maskLayer.frame = self.attachedView.bounds;
                        maskLayer.path = path.CGPath;
                        self.attachedView.dimMaskView.layer.mask = maskLayer;
                    } else {
                        [self.attachedView resetDimMaskView];
                        [FWPopupWindow sharedWindow].shouldResetDimMaskView = NO;
                    }
                }
                
            });
            
            self.attachedView.dimMaskAnimating = NO;
        }];
    };
    return popupBlock;
}

/**
 根据不同状态、动画设置视图的不同约束
 
 @param constraintsStates FWConstraintsStates
 */
- (void)setupConstraints:(FWConstraintsStates)constraintsStates
{
    FWPopupAlignment myAlignment = self.vProperty.popupAlignment;
    UIEdgeInsets edgeInsets = self.vProperty.popupEdgeInsets;
    UIView *tmpSuperview = self.superview;
    if (!tmpSuperview) {
        return;
    }
    
    if (constraintsStates == FWConstraintsStatesBeforeAnimation) {
        
        [self layoutIfNeeded];
        if (self.finalFrame.size.width == 0 && self.finalFrame.size.height == 0) {
            CGRect tmpFrame = self.finalFrame;
            tmpFrame.size.width = self.frame.size.width;
            tmpFrame.size.height = self.frame.size.height;
            self.finalFrame = tmpFrame;
        }
        
        self.haveSetConstraints = YES;
        
        if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition) {
            if (self.isResetSuperView) {
                self.isResetSuperView = NO;
                [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(self.finalFrame.size);
                    [self constraintsBeforeAnimationPosition:make myAlignment:myAlignment];
                }];
            } else {
                [self mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (!self.isNotMakeFrame) {
                        make.size.mas_equalTo(self.finalFrame.size);
                    }
                    [self constraintsBeforeAnimationPosition:make myAlignment:myAlignment];
                }];
            }
            [self.superview layoutIfNeeded];
        } else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame) {
            if (self.isResetSuperView) {
                self.isResetSuperView = NO;
                [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                    [self constraintsBeforeAnimationFrame:make myAlignment:myAlignment];
                }];
            } else {
                [self mas_makeConstraints:^(MASConstraintMaker *make) {
                    [self constraintsBeforeAnimationFrame:make myAlignment:myAlignment];
                }];
            }
            [self.superview layoutIfNeeded];
        } else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale || self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale3D) {
            if (self.isResetSuperView) {
                self.isResetSuperView = NO;
                [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(self.finalFrame.size);
                    [self constraintsBeforeAnimationScale:make myAlignment:myAlignment];
                }];
            } else {
                [self mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (!self.isNotMakeFrame) {
                        make.size.mas_equalTo(self.finalFrame.size);
                    }
                    [self constraintsBeforeAnimationScale:make myAlignment:myAlignment];
                }];
            }
            [self layoutIfNeeded];
            [self.superview layoutIfNeeded];
            if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleScale) {
                self.transform = self.vProperty.transform;
            } else {
                self.layer.transform = self.vProperty.transform3D;
            }
        }
    } else if (constraintsStates == FWConstraintsStatesShownAnimation) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition) {
                if (myAlignment == FWPopupAlignmentCenter) {
                    make.centerY.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
                } else if (myAlignment == FWPopupAlignmentTopCenter) {
                    make.top.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
                } else if (myAlignment == FWPopupAlignmentLeftCenter) {
                    make.left.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
                } else if (myAlignment == FWPopupAlignmentBottomCenter) {
                    make.bottom.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
                } else if (myAlignment == FWPopupAlignmentRightCenter) {
                    make.right.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
                } else if (myAlignment == FWPopupAlignmentTopLeft) {
                    make.top.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
                } else if (myAlignment == FWPopupAlignmentTopRight) {
                    make.top.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
                } else if (myAlignment == FWPopupAlignmentBottomLeft) {
                    make.bottom.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
                } else if (myAlignment == FWPopupAlignmentBottomRight) {
                    make.bottom.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
                }
            } else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame) {
                if (myAlignment == FWPopupAlignmentCenter) {
                    make.height.mas_equalTo(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentTopCenter) {
                    make.height.mas_equalTo(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentLeftCenter) {
                    make.width.mas_equalTo(self.finalFrame.size.width);
                } else if (myAlignment == FWPopupAlignmentBottomCenter) {
                    make.height.mas_equalTo(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentRightCenter) {
                    make.width.mas_equalTo(self.finalFrame.size.width);
                } else if (myAlignment == FWPopupAlignmentTopLeft) {
                    make.height.mas_equalTo(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentTopRight) {
                    make.height.mas_equalTo(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentBottomLeft) {
                    make.height.mas_equalTo(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentBottomRight) {
                    make.height.mas_equalTo(self.finalFrame.size.height);
                }
            }
        }];
    } else if (constraintsStates == FWConstraintsStatesHiddenAnimation) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.vProperty.popupAnimationStyle == FWPopupAnimationStylePosition) {
                if (myAlignment == FWPopupAlignmentCenter) {
                    make.centerY.equalTo(tmpSuperview).offset(-self.finalFrame.size.height/2 - tmpSuperview.frame.size.height/2);
                } else if (myAlignment == FWPopupAlignmentTopCenter) {
                    make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentLeftCenter) {
                    make.left.equalTo(tmpSuperview).offset(-self.finalFrame.size.width);
                } else if (myAlignment == FWPopupAlignmentBottomCenter) {
                    make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentRightCenter) {
                    make.right.equalTo(tmpSuperview).offset(self.finalFrame.size.width);
                } else if (myAlignment == FWPopupAlignmentTopLeft) {
                    make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentTopRight) {
                    make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentBottomLeft) {
                    make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height);
                } else if (myAlignment == FWPopupAlignmentBottomRight) {
                    make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height);
                }
            } else if (self.vProperty.popupAnimationStyle == FWPopupAnimationStyleFrame) {
                if (myAlignment == FWPopupAlignmentCenter) {
                    make.height.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentTopCenter) {
                    make.height.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentLeftCenter) {
                    make.width.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentBottomCenter) {
                    make.height.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentRightCenter) {
                    make.width.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentTopLeft) {
                    make.height.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentTopRight) {
                    make.height.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentBottomLeft) {
                    make.height.mas_equalTo(0);
                } else if (myAlignment == FWPopupAlignmentBottomRight) {
                    make.height.mas_equalTo(0);
                }
            }
        }];
    }
}

/**
 位移动画展示前的约束
 
 @param make MASConstraintMaker
 @param myAlignment 自定义弹窗校准位置
 */
- (void)constraintsBeforeAnimationPosition:(MASConstraintMaker *)make myAlignment:(FWPopupAlignment)myAlignment
{
    UIEdgeInsets edgeInsets = self.vProperty.popupEdgeInsets;
    
    UIView *tmpSuperview = self.superview;
    if (tmpSuperview) {
        if (myAlignment == FWPopupAlignmentCenter) {
            make.centerX.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.centerY.equalTo(tmpSuperview).offset(-self.finalFrame.size.height/2 - tmpSuperview.frame.size.height/2);
        } else if (myAlignment == FWPopupAlignmentTopCenter) {
            make.centerX.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height);
        } else if (myAlignment == FWPopupAlignmentLeftCenter) {
            make.centerY.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.left.equalTo(tmpSuperview).offset(-self.finalFrame.size.width);
        } else if (myAlignment == FWPopupAlignmentBottomCenter) {
            make.centerX.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height);
        } else if (myAlignment == FWPopupAlignmentRightCenter) {
            make.centerY.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.right.equalTo(tmpSuperview).offset(self.finalFrame.size.width);
        } else if (myAlignment == FWPopupAlignmentTopLeft) {
            make.left.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height);
        } else if (myAlignment == FWPopupAlignmentTopRight) {
            make.right.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height);
        } else if (myAlignment == FWPopupAlignmentBottomLeft) {
            make.left.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height);
        } else if (myAlignment == FWPopupAlignmentBottomRight) {
            make.right.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height);
        }
    }
}

/**
 修改frame值动画展示前的约束
 
 @param make MASConstraintMaker
 @param myAlignment 自定义弹窗校准位置
 */
- (void)constraintsBeforeAnimationFrame:(MASConstraintMaker *)make myAlignment:(FWPopupAlignment)myAlignment
{
    UIEdgeInsets edgeInsets = self.vProperty.popupEdgeInsets;
    
    UIView *tmpSuperview = self.superview;
    if (tmpSuperview) {
        if (myAlignment == FWPopupAlignmentCenter) {
            make.top.equalTo(tmpSuperview).offset((tmpSuperview.frame.size.height-self.finalFrame.size.height)/2 + edgeInsets.top - edgeInsets.bottom);
            make.centerX.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.width.mas_equalTo(self.finalFrame.size.width);
            make.height.mas_equalTo(0);
        } else if (myAlignment == FWPopupAlignmentTopCenter) {
            make.centerX.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.width.mas_equalTo(self.finalFrame.size.width);
            make.height.mas_equalTo(0);
        } else if (myAlignment == FWPopupAlignmentLeftCenter) {
            make.centerY.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.left.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(self.finalFrame.size.height);
        } else if (myAlignment == FWPopupAlignmentBottomCenter) {
            make.centerX.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.width.mas_equalTo(self.finalFrame.size.width);
            make.height.mas_equalTo(0);
        } else if (myAlignment == FWPopupAlignmentRightCenter) {
            make.centerY.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.right.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(self.finalFrame.size.height);
        } else if (myAlignment == FWPopupAlignmentTopLeft) {
            make.left.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.width.mas_equalTo(self.finalFrame.size.width);
            make.height.mas_equalTo(0);
        } else if (myAlignment == FWPopupAlignmentTopRight) {
            make.right.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.width.mas_equalTo(self.finalFrame.size.width);
            make.height.mas_equalTo(0);
        } else if (myAlignment == FWPopupAlignmentBottomLeft) {
            make.left.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.width.mas_equalTo(self.finalFrame.size.width);
            make.height.mas_equalTo(0);
        } else if (myAlignment == FWPopupAlignmentBottomRight) {
            make.right.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(edgeInsets.top - edgeInsets.bottom);
            make.width.mas_equalTo(self.finalFrame.size.width);
            make.height.mas_equalTo(0);
        }
    }
}

/**
 缩放动画展示前的约束
 
 @param make MASConstraintMaker
 @param myAlignment 自定义弹窗校准位置
 */
- (void)constraintsBeforeAnimationScale:(MASConstraintMaker *)make myAlignment:(FWPopupAlignment)myAlignment
{
    UIEdgeInsets edgeInsets = self.vProperty.popupEdgeInsets;
    CGPoint anchorPoint = [self obtainAnchorPoint];
    self.layer.anchorPoint = anchorPoint;
    
    UIView *tmpSuperview = self.superview;
    if (tmpSuperview) {
        if (myAlignment == FWPopupAlignmentCenter) {
            make.center.equalTo(tmpSuperview).insets(edgeInsets);
        } else if (myAlignment == FWPopupAlignmentTopCenter) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerX.equalTo(tmpSuperview).offset(-self.finalFrame.size.width*(0.5-anchorPoint.x) + edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height*(1-anchorPoint.y)/2 + edgeInsets.top - edgeInsets.bottom);
        } else if (myAlignment == FWPopupAlignmentLeftCenter) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerY.equalTo(tmpSuperview).offset(-self.finalFrame.size.height*(0.5-anchorPoint.y) + edgeInsets.top - edgeInsets.bottom);
            make.left.equalTo(tmpSuperview).offset(-self.finalFrame.size.width/2 + self.finalFrame.size.width*anchorPoint.x + edgeInsets.left - edgeInsets.right);
        } else if (myAlignment == FWPopupAlignmentBottomCenter) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerX.equalTo(tmpSuperview).offset(edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height*(anchorPoint.y-0.5) + edgeInsets.top - edgeInsets.bottom);
        } else if (myAlignment == FWPopupAlignmentRightCenter) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.centerY.equalTo(tmpSuperview).offset(-self.finalFrame.size.height*(0.5-anchorPoint.y) + edgeInsets.top - edgeInsets.bottom);
            make.right.equalTo(tmpSuperview).offset(self.finalFrame.size.width/2 - self.finalFrame.size.width*(1-anchorPoint.x) + edgeInsets.left - edgeInsets.right);
        } else if (myAlignment == FWPopupAlignmentTopLeft) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.left.equalTo(tmpSuperview).offset(-self.finalFrame.size.width/2 + self.finalFrame.size.width*anchorPoint.x + edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height*(1-anchorPoint.y)/2 + edgeInsets.top - edgeInsets.bottom);
        } else if (myAlignment == FWPopupAlignmentTopRight) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.right.equalTo(tmpSuperview).offset(self.finalFrame.size.width/2 - self.finalFrame.size.width*(1-anchorPoint.x) + edgeInsets.left - edgeInsets.right);
            make.top.equalTo(tmpSuperview).offset(-self.finalFrame.size.height*(1-anchorPoint.y)/2 + edgeInsets.top - edgeInsets.bottom);
        } else if (myAlignment == FWPopupAlignmentBottomLeft) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.left.equalTo(tmpSuperview).offset(-self.finalFrame.size.width/2 + self.finalFrame.size.width*anchorPoint.x + edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height*(anchorPoint.y-0.5) + edgeInsets.top - edgeInsets.bottom);
        } else if (myAlignment == FWPopupAlignmentBottomRight) {
            // 设置锚点后会导致约束偏移，因此这边特意做了一个反向偏移
            make.right.equalTo(tmpSuperview).offset(self.finalFrame.size.width/2 - self.finalFrame.size.width*(1-anchorPoint.x) + edgeInsets.left - edgeInsets.right);
            make.bottom.equalTo(tmpSuperview).offset(self.finalFrame.size.height*(anchorPoint.y-0.5) + edgeInsets.top - edgeInsets.bottom);
        }
    }
}

/**
 获取当前视图的锚点
 
 @return CGPoint
 */
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
    else if (alignment == FWPopupAlignmentTopLeft || alignment == FWPopupAlignmentTopCenter || alignment == FWPopupAlignmentTopRight)
    {
        if (self.vProperty.popupArrowStyle == FWPopupArrowStyleNone) {
            tmpX = self.vProperty.popupArrowVertexScaleX;
        } else {
            CGFloat arrowVertexX = (self.finalFrame.size.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2;
            tmpX = arrowVertexX / self.finalFrame.size.width;
        }
        tmpY = 0;
    }
    else if (alignment == FWPopupAlignmentLeftCenter)
    {
        tmpX = 0;
        tmpY = 0.5;
    }
    else if (alignment == FWPopupAlignmentBottomLeft || alignment == FWPopupAlignmentBottomCenter || alignment == FWPopupAlignmentBottomRight)
    {
        if (self.vProperty.popupArrowStyle == FWPopupArrowStyleNone) {
            tmpX = self.vProperty.popupArrowVertexScaleX;
        } else {
            CGFloat arrowVertexX = (self.finalFrame.size.width - self.vProperty.popupArrowSize.width) *  self.vProperty.popupArrowVertexScaleX + self.vProperty.popupArrowSize.width / 2;
            tmpX = arrowVertexX / self.finalFrame.size.width;
        }
        tmpY = 1;
    }
    else if (alignment == FWPopupAlignmentRightCenter)
    {
        tmpX = 1;
        tmpY = 0.5;
    }
    return CGPointMake(tmpX, tmpY);
}

/**
 处理多余部分的遮罩层
 */
- (void)setupSpilthMask
{
    if (!self.vProperty.shouldClearSpilthMask) {
        return;
    }
    
    CGRect spilthMaskFrame = CGRectZero;
    
    if (self.vProperty.popupAlignment == FWPopupAlignmentTopCenter || self.vProperty.popupAlignment == FWPopupAlignmentTopLeft || self.vProperty.popupAlignment == FWPopupAlignmentTopRight)
    {
        spilthMaskFrame = CGRectMake(0, 0, self.attachedView.frame.size.width, self.finalFrame.origin.y);
    }
    else if (self.vProperty.popupAlignment == FWPopupAlignmentLeftCenter)
    {
        spilthMaskFrame = CGRectMake(0, 0, self.finalFrame.origin.x, self.attachedView.frame.size.height);
    }
    else if (self.vProperty.popupAlignment == FWPopupAlignmentBottomCenter || self.vProperty.popupAlignment == FWPopupAlignmentBottomLeft || self.vProperty.popupAlignment == FWPopupAlignmentBottomRight)
    {
        spilthMaskFrame = CGRectMake(0, CGRectGetMaxY(self.finalFrame), self.attachedView.frame.size.width, self.attachedView.frame.size.height - CGRectGetMaxY(self.finalFrame));
    }
    else if (self.vProperty.popupAlignment == FWPopupAlignmentRightCenter)
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
        
        self.attachedView.dimMaskView.layer.mask = maskLayer;
    }
}


#pragma mark - ----------------------- 其他 -----------------------

- (void)tapGestureAction:(UIGestureRecognizer *)gesture
{
    [self clickedMaskView];
    
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

- (void)clickedMaskView
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
    
    if (attachedView != [FWPopupWindow sharedWindow].attachView) {
        [_attachedView.dimMaskView addSubview:self];
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

- (void)setCurrentPopupState:(FWPopupState)currentPopupState
{
    _currentPopupState = currentPopupState;
    
    if (self.popupStateBlock != nil) {
        self.popupStateBlock(self, currentPopupState);
    }
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

