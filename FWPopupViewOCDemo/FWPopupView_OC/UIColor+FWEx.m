//
//  UIColor+FWEx.m
//  FWPopupView_OC
//
//  Created by xfg on 2021/3/20.
//  Copyright © 2021 xfg. All rights reserved.
//

#import "UIColor+FWEx.h"

@implementation UIColor (FWEx)

#pragma mark 适配深色模式颜色
+ (UIColor *)colorWithLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor
{
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return lightColor;
            } else {
                return darkColor;
            }
        }];
    } else {
        return lightColor ? lightColor : (darkColor ? darkColor : [UIColor clearColor]);
    }
}

@end
