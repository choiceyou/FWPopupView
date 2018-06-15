//
//  FWNavigationController.m
//  FanweApp
//
//  Created by xfg on 2017/6/26.
//  Copyright © 2017年 xfg. All rights reserved.
//

#import "FWNavigationController.h"

@interface FWNavigationController ()

@end

@implementation FWNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavigationBarAppearance];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        // 设置图片
        [btn setImage:[UIImage imageNamed:@"com_arrow_vc_back"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"com_arrow_vc_back"] forState:UIControlStateHighlighted];
        // 设置尺寸
        btn.frame = CGRectMake(0, 0, btn.currentImage.size.width+20, btn.currentImage.size.height+16);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)backAction
{
    [self popViewControllerAnimated:YES];
    
    if (self.vcBackActionBlock)
    {
        self.vcBackActionBlock();
    }
}

- (void)setNavigationBarAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[FWNavigationController resizableImage:@"header_bg_message" edgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)]  forBarMetrics:UIBarMetricsDefault];
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];     // 设置item颜色
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];  // 统一设置item字体大小
    [UINavigationBar appearance].titleTextAttributes=textAttrs;
}

+ (UIImage *)resizableImage:(NSString *)imageName edgeInsets:(UIEdgeInsets)edgeInsets
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageH * edgeInsets.top, imageW * edgeInsets.left, imageH * edgeInsets.bottom, imageW * edgeInsets.right) resizingMode:UIImageResizingModeStretch];
}

@end
