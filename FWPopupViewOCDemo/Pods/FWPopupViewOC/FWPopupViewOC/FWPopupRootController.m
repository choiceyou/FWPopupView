//
//  FWPopupRootController.m
//  FWPopupViewOC
//
//  Created by xfg on 2018/12/21.
//  Copyright © 2018 xfg. All rights reserved.
//

#import "FWPopupRootController.h"

@interface FWPopupRootController ()

@end

@implementation FWPopupRootController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (@available(iOS 13.0, *)) {
        if ([UIApplication sharedApplication].windows.firstObject) {
            return [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarStyle;
        }
    }
    return [UIApplication sharedApplication].statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    if (@available(iOS 13.0, *)) {
        if ([UIApplication sharedApplication].windows.firstObject) {
            return [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarHidden;
        }
    }
    return [UIApplication sharedApplication].statusBarHidden;
}

@end
