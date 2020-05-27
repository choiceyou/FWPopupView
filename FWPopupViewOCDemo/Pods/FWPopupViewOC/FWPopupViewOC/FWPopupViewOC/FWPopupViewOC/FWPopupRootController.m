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
    return [UIApplication sharedApplication].statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return [UIApplication sharedApplication].statusBarHidden;
}

@end
