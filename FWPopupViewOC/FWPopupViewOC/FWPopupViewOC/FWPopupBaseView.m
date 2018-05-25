//
//  FWPopupBaseView.m
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWPopupBaseView.h"
#import "FWPopupWindow.h"

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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        _attachedView = [FWPopupWindow sharedWindow].attachView;
        
        _originMaskViewColor = self.attachedView.dimMaskViewColor;
        _originTouchWildToHide = [FWPopupWindow sharedWindow].touchWildToHide;
        
//        self.showAnimation = <#^(FWPopupBaseView *popupBaseView)#>
    }
    return self;
}

#pragma mark - ----------------------- 显示、隐藏 -----------------------

- (void)show
{
    
}

- (void)showWithBlock:(FWPopupCompletionBlock)completionBlock
{
    
}

- (void)hide
{
    
}

- (void)hideWithBlock:(FWPopupCompletionBlock)completionBlock
{
    
}


#pragma mark - ----------------------- GET、SET -----------------------

- (void)setVProperty:(FWPopupBaseViewProperty *)vProperty
{
    _vProperty = vProperty;
}

- (void)setAttachedView:(UIView *)attachedView
{
    if ([attachedView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *view = (UIScrollView *)attachedView;
        view.scrollEnabled = NO;
    }
    _attachedView = attachedView;
}

- (BOOL)visible
{
    return !(self.attachedView.dimMaskView.alpha == 0);
}

@end


#pragma mark - ======================= 可配置属性 =======================

@implementation FWPopupBaseViewProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
