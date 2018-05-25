//
//  FWPopupWindow.m
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWPopupWindow.h"

@implementation FWPopupWindow

+ (FWPopupWindow *)sharedWindow
{
    static FWPopupWindow *window;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        window = [[FWPopupWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = [UIViewController new];
    });
    
    return window;
}

@end
