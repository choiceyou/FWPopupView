//
//  FWGuideMaskView.m
//  FWPopupViewOC
//
//  Created by xfg on 2018/6/5.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWGuideMaskView.h"
#import "Masonry.h"

@interface FWGuideMaskView()

/**
 当前正在进行引导的item的下标
 */
@property (nonatomic, assign) NSInteger currentIndex;

/**
 遮罩层的mask
 */
@property (nonatomic, strong) CAShapeLayer *maskLayer;

/**
 需要引导的总项数
 */
@property (nonatomic, assign) NSInteger totalCount;

/**
 描述
 */
@property (nonatomic, strong) UILabel *describeLabel;

/**
 箭头
 */
@property (nonatomic, strong) UIImageView *arrowImgView;

@end


@implementation FWGuideMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.describeLabel];
        [self addSubview:self.arrowImgView];
        self.describeLabel.textColor = [UIColor whiteColor];
        self.describeLabel.font = [UIFont systemFontOfSize:14];
        self.userInteractionEnabled = NO;
        
        self.frame = self.attachedView.frame;
    }
    return self;
}

/**
 重写父类：显示：弹窗状态回调，注意：该回调会走N次
 
 @param stateBlock 弹窗状态回调，注意：该回调会走N次
 */
- (void)showWithStateBlock:(FWPopupStateBlock)stateBlock
{
    if (!self.vProperty || ![self.vProperty isMemberOfClass:[FWGuideMaskViewProperty class]]) {
        self.vProperty = [[FWGuideMaskViewProperty alloc] init];
    }
    self.vProperty.shouldClearSpilthMask = YES;
    self.vProperty.popupAlignment = FWPopupAlignmentCenter;
    self.vProperty.popupAnimationStyle = FWPopupAnimationStyleScale;
    
    [super showWithStateBlock:stateBlock];
    
    self.currentIndex = 0;
}

/**
 重写父类：遮罩层被单击
 */
- (void)clickedMaskView
{
    [super clickedMaskView];
    
    if (self.currentIndex < self.totalCount-1)
    {
        self.currentIndex ++;
    }
    else
    {
        [self hide];
    }
}


#pragma mark - ----------------------- 显示引导 -----------------------

/**
 根据当前下标，修改遮罩层
 */
- (void)changeMask
{
    if (!self.dataSource) {
        return;
    }
    
    CGRect visibleFrame = [self obtainVisibleFrame];
    [self setupItemWith:visibleFrame];
    
    CGPathRef fromPath = self.maskLayer.path;
    
    /// 更新 maskLayer 的 尺寸
    self.maskLayer.frame = self.attachedView.bounds;
    self.maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGFloat maskCornerRadius = 0;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(guideMaskView:cornerRadiusForItemAtIndex:)])
    {
        maskCornerRadius = [self.dataSource guideMaskView:self cornerRadiusForItemAtIndex:self.currentIndex];
    } else {
        maskCornerRadius = self.vProperty.cornerRadius;
    }
    
    /// 获取可见区域的路径(开始路径)
    UIBezierPath *visualPath = [UIBezierPath bezierPathWithRoundedRect:visibleFrame cornerRadius:maskCornerRadius];
    
    /// 获取终点路径
    UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:self.attachedView.bounds];
    
    [toPath appendPath:visualPath];
    
    /// 遮罩的路径
    self.maskLayer.path = toPath.CGPath;
    self.maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.attachedView.dimMaskView.layer.mask = self.maskLayer;
    
    /// 开始移动动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.duration  = self.vProperty.animationDuration;
    anim.fromValue = (__bridge id _Nullable)(fromPath);
    anim.toValue   = (__bridge id _Nullable)(toPath.CGPath);
    [self.maskLayer addAnimation:anim forKey:NULL];
}

/**
 获取可视视图参照遮罩层时的frame
 
 @return frame
 */
- (CGRect)obtainVisibleFrame
{
    if (self.currentIndex >= self.totalCount) {
        return CGRectZero;
    }
    
    UIView *view = [self.dataSource guideMaskView:self viewForItemAtIndex:self.currentIndex];
    
    CGRect visualRect = [self.attachedView convertRect:view.frame fromView:view.superview];
    
    FWGuideMaskViewProperty *property = (FWGuideMaskViewProperty *)self.vProperty;
    
    visualRect.origin.x -= property.visibleViewInsets.left;
    visualRect.origin.y -= property.visibleViewInsets.top;
    visualRect.size.width  += (property.visibleViewInsets.left + property.visibleViewInsets.right);
    visualRect.size.height += (property.visibleViewInsets.top + property.visibleViewInsets.bottom);
    
    return visualRect;
}

- (void)setupItemWith:(CGRect)visibleFrame
{
    /// 设置 描述文字的属性
    // 文字颜色
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(guideMaskView:colorForDescriptionAtIndex:)])
    {
        self.describeLabel.textColor = [self.dataSource guideMaskView:self colorForDescriptionAtIndex:self.currentIndex];
    }
    // 文字字体
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(guideMaskView:fontForDescriptionAtIndex:)])
    {
        self.describeLabel.font = [self.dataSource guideMaskView:self fontForDescriptionAtIndex:self.currentIndex];
    }
    
    // 描述文字
    NSString *desc = [self.dataSource guideMaskView:self descriptionForItemAtIndex:self.currentIndex];
    
    self.describeLabel.text = desc;
    
    FWGuideMaskViewProperty *property = (FWGuideMaskViewProperty *)self.vProperty;
    
    if (!property.arrowImage) {
        NSBundle *bundle = [NSBundle bundleForClass:[FWGuideMaskView class]];
        NSURL *url = [bundle URLForResource:@"FWPopupViewOC" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        NSString *path = [imageBundle pathForResource:@"guide_arrow@3x" ofType:@"png"];
        
        self.arrowImgView.image = [UIImage imageWithContentsOfFile:path];
    } else {
        self.arrowImgView.image = property.arrowImage;
    }
    
    // 设置 文字 与 箭头的位置
    CGRect textRect, arrowRect;
    CGSize imgSize   = self.arrowImgView.image.size;
    CGFloat maxWidth = self.attachedView.frame.size.width - property.letfRigthMargin * 2;
    CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName : self.describeLabel.font}
                                          context:NULL].size;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch ([self obtainVisibleAligement:visibleFrame]) {
        case FWPopupAlignmentTopLeft:
        {
            transform = CGAffineTransformMakeScale(-1, 1);
            arrowRect = CGRectMake(CGRectGetMidX(visibleFrame) - imgSize.width * 0.5,
                                   CGRectGetMaxY(visibleFrame) + self.vProperty.commponentMargin,
                                   imgSize.width,
                                   imgSize.height);
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth(visibleFrame))
            {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = self.vProperty.letfRigthMargin;
            }
            
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + self.vProperty.commponentMargin, textSize.width, textSize.height);
        }
            break;
        case FWPopupAlignmentTopRight:
        {
            arrowRect = CGRectMake(CGRectGetMidX(visibleFrame) - imgSize.width * 0.5,
                                   CGRectGetMaxY(visibleFrame) + self.vProperty.commponentMargin,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth(visibleFrame))
            {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = self.vProperty.letfRigthMargin + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + self.vProperty.commponentMargin, textSize.width, textSize.height);
        }
            break;
        case FWPopupAlignmentBottomLeft:
        {
            transform = CGAffineTransformMakeScale(-1, -1);
            arrowRect = CGRectMake(CGRectGetMidX(visibleFrame) - imgSize.width * 0.5,
                                   CGRectGetMinY(visibleFrame) - self.vProperty.commponentMargin - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth(visibleFrame))
            {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = self.vProperty.letfRigthMargin;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - self.vProperty.commponentMargin - textSize.height, textSize.width, textSize.height);
        }
            break;
        case FWPopupAlignmentBottomRight:
        {
            transform = CGAffineTransformMakeScale(1, -1);
            arrowRect = CGRectMake(CGRectGetMidX(visibleFrame) - imgSize.width * 0.5,
                                   CGRectGetMinY(visibleFrame) - self.vProperty.commponentMargin - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth(visibleFrame))
            {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = self.vProperty.letfRigthMargin + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - self.vProperty.commponentMargin - textSize.height, textSize.width, textSize.height);
        }
            break;
            
        default:
        {
            arrowRect = CGRectZero;
            textRect = CGRectZero;
        }
            break;
    }
    
    /// 图片 和 文字的动画
    [UIView animateWithDuration:self.vProperty.animationDuration animations:^{
        
        self.arrowImgView.transform = transform;
        self.arrowImgView.frame = arrowRect;
        self.describeLabel.frame = textRect;
    }];
}

/**
 获取可视视图的相对位置
 
 @param visibleFrame 可视视图frame
 @return 相对位置
 */
- (FWPopupAlignment)obtainVisibleAligement:(CGRect)visibleFrame
{
    /// 可见区域的中心坐标
    CGPoint visualCenter = CGPointMake(CGRectGetMidX(visibleFrame),
                                       CGRectGetMidY(visibleFrame));
    /// 遮罩层的中心坐标
    CGPoint viewCenter   = CGPointMake(CGRectGetMidX(self.attachedView.bounds),
                                       CGRectGetMidY(self.attachedView.bounds));
    
    if ((visualCenter.x <= viewCenter.x) && (visualCenter.y <= viewCenter.y))
    {
        return FWPopupAlignmentTopLeft;
    }
    else if ((visualCenter.x > viewCenter.x) && (visualCenter.y <= viewCenter.y))
    {
        return FWPopupAlignmentTopRight;
    }
    else if ((visualCenter.x <= viewCenter.x) && (visualCenter.y > viewCenter.y))
    {
        return FWPopupAlignmentBottomLeft;
    }
    else
    {
        return FWPopupAlignmentBottomRight;
    }
}


#pragma mark - ----------------------- GET、SET -----------------------

- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer)
    {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (NSInteger)totalCount
{
    return [self.dataSource numberOfItemsInGuideMaskView:self];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    [self changeMask];
}

- (UILabel *)describeLabel
{
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.numberOfLines = 0;
    }
    return _describeLabel;
}

- (UIImageView *)arrowImgView
{
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
    }
    return _arrowImgView;
}

@end


#pragma mark - ======================= 可配置属性 =======================

@implementation FWGuideMaskViewProperty

- (void)setupParams
{
    [super setupParams];
    
    self.visibleViewInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    
    self.letfRigthMargin = 50;
    self.animationDuration = 0.3;
}

@end
