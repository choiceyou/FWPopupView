//
//  FWGuideMaskView.h
//  FWPopupViewOC
//
//  Created by xfg on 2018/6/5.
//  Copyright © 2018年 xfg. All rights reserved.
//  新功能引导弹窗

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupViewOC
 bug反馈、交流群：670698309
 
 ***************************************************
 */


#import "FWPopupBaseView.h"
@class FWGuideMaskViewProperty;
@protocol FWGuideMaskViewDataSource;


#pragma mark - ======================= FWGuideMaskView =======================

@interface FWGuideMaskView : FWPopupBaseView

@property (nonatomic, weak) id<FWGuideMaskViewDataSource> dataSource;

@end


#pragma mark - ======================= FWGuideMaskViewDataSource =======================

@protocol FWGuideMaskViewDataSource<NSObject>

@required

/**
 item的个数
 
 @param guideMaskView FWGuideMaskView
 @return 个数
 */
- (NSInteger)numberOfItemsInGuideMaskView:(FWGuideMaskView *)guideMaskView;

/**
 每个item对应的view
 
 @param guideMaskView FWGuideMaskView
 @param index 下标
 @return 传入的view
 */
- (UIView *)guideMaskView:(FWGuideMaskView *)guideMaskView viewForItemAtIndex:(NSInteger)index;

/**
 每个item对应的文字
 
 @param guideMaskView FWGuideMaskView
 @param index 下标
 @return 文字描述
 */
- (NSString *)guideMaskView:(FWGuideMaskView *)guideMaskView descriptionForItemAtIndex:(NSInteger)index;

@optional

/**
 每个item的文字颜色：默认白色
 
 @param guideMaskView FWGuideMaskView
 @param index 下标
 @return 颜色
 */
- (UIColor *)guideMaskView:(FWGuideMaskView *)guideMaskView colorForDescriptionAtIndex:(NSInteger)index;

/**
 每个item对应的文字字体：默认[UIFont systemFontOfSize:14]
 
 @param guideMaskView FWGuideMaskView
 @param index 下标
 @return 文字字体
 */
- (UIFont *)guideMaskView:(FWGuideMaskView *)guideMaskView fontForDescriptionAtIndex:(NSInteger)index;

/**
 每个item可视区域的圆角值

 @param guideMaskView FWGuideMaskView
 @param index 下标
 @return 圆角值
 */
- (CGFloat)guideMaskView:(FWGuideMaskView *)guideMaskView cornerRadiusForItemAtIndex:(NSInteger)index;

@end


#pragma mark - ======================= FWGuideMaskViewProperty =======================

@interface FWGuideMaskViewProperty: FWPopupBaseViewProperty

/**
 item的view与遮罩层的外边距
 */
@property (nonatomic, assign) UIEdgeInsets visibleViewInsets;

/**
 可传入箭头图标
 */
@property (nonatomic, strong) UIImage *arrowImage;

@end
