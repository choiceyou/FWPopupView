//
//  FWPopupWindow.h
//  FWPopupViewOC
//
//  Created by xfg on 2018/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWPopupWindow : UIWindow

+ (FWPopupWindow *)sharedWindow;

@property (nonatomic, readonly) UIView *attachView;

@end
