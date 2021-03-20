//
//  UIColor+FWEx.h
//  FWPopupView_OC
//
//  Created by xfg on 2021/3/20.
//  Copyright © 2021 xfg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (FWEx)

/// 适配深色模式颜色
/// @param lightColor 浅色模式颜色
/// @param darkColor 深色模式颜色
+ (UIColor *)colorWithLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

@end

NS_ASSUME_NONNULL_END
