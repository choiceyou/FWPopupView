//
//  FWMenuViewDemoVC.m
//  FWPopupView_OC
//
//  Created by xfg on 2018/6/14.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWMenuViewDemoVC.h"
#import <FWPopupView/FWPopupView-Swift.h>

// 状态栏、导航栏
#define kStatusBarHeight        ([UIApplication sharedApplication].statusBarFrame.size.height)
#define kNavBarHeight           44.0
#define kStatusAndNavBarHeight  (kStatusBarHeight + kNavBarHeight)
// 标签栏高度
#define kTabBarHeight           (kStatusBarHeight > 20.0 ? 83.0: 49.0)

#define kScreenW                [[UIScreen mainScreen] bounds].size.width
#define kScreenH                [[UIScreen mainScreen] bounds].size.height

#define kRGB(r,g,b)          [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:1.f]

@interface FWMenuViewDemoVC ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *imageArray2;

@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton *leftBottomBtn;
@property (nonatomic, strong) UIButton *rightBottomBtn;

@end

@implementation FWMenuViewDemoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleArray = @[@"创建群聊", @"加好友/群", @"扫一扫", @"面对面快传", @"付款", @"拍摄"];
    self.imageArray = @[[UIImage imageNamed:@"right_menu_multichat"],
                        [UIImage imageNamed:@"right_menu_addFri"],
                        [UIImage imageNamed:@"right_menu_QR"],
                        [UIImage imageNamed:@"right_menu_facetoface"],
                        [UIImage imageNamed:@"right_menu_payMoney"],
                        [UIImage imageNamed:@"right_menu_sendvideo"]];
    
    self.imageArray2 = @[[UIImage imageNamed:@"right_menu_multichat_white"],
                         [UIImage imageNamed:@"right_menu_addFri_white"],
                         [UIImage imageNamed:@"right_menu_QR_white"],
                         [UIImage imageNamed:@"right_menu_facetoface_white"],
                         [UIImage imageNamed:@"right_menu_payMoney_white"],
                         [UIImage imageNamed:@"right_menu_sendvideo_white"]];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mqz_nav_add"] style:UIBarButtonItemStylePlain target:self action:@selector(barBtnAction)];
    barButtonItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -6);
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 100, 44);
    [btn setTitle:@"下拉▼" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 0;
    btn.frame = CGRectMake(0, 0, btn.currentImage.size.width+20, btn.currentImage.size.height+16);
    self.navigationItem.titleView = btn;
    
    self.centerBtn = [self setupBtn:@"中间按钮" frame:CGRectMake((kScreenW - 100)/2, kScreenH * 0.25, 100, 50) tag:1];
    
    self.leftBottomBtn = [self setupBtn:@"左下角按钮" frame:CGRectMake(10, kScreenH * 0.8, 100, 50) tag:2];
    
    self.rightBottomBtn = [self setupBtn:@"右下角按钮" frame:CGRectMake(kScreenW -110, kScreenH * 0.8, 100, 50) tag:3];
    
}

- (void)barBtnAction
{
    FWMenuViewProperty *property = [[FWMenuViewProperty alloc] init];
    property.popupCustomAlignment = FWPopupCustomAlignmentTopRight;
    property.popupAnimationType = FWPopupAnimationTypeScale;
    property.popupArrowStyle = FWMenuArrowStyleRound;
    property.touchWildToHide = @"1";
    property.topBottomMargin = 0;
    property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.2];
    property.popupViewEdgeInsets = UIEdgeInsetsMake(kStatusAndNavBarHeight, 0, 0, 8);
    property.popupArrowVertexScaleX = 1;
    property.backgroundColor = kRGB(64, 63, 66);
    property.splitColor = kRGB(64, 63, 66);
    property.separatorColor = kRGB(91, 91, 93);
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];     // 设置item颜色
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];  // 统一设置item字体大小
    property.titleTextAttributes = textAttrs;
    property.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    FWMenuView *menuView = [FWMenuView menuWithItemTitles:self.titleArray itemImageNames:self.imageArray2 itemBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
        
    } property:property];
    
    [menuView show];
}

- (void)btnAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case 0:
        {
            FWMenuViewProperty *property = [[FWMenuViewProperty alloc] init];
            property.popupCustomAlignment = FWPopupCustomAlignmentTopCenter;
            property.popupAnimationType = FWPopupAnimationTypeScale;
            property.popupArrowStyle = FWMenuArrowStyleRound;
            property.touchWildToHide = @"1";
            property.topBottomMargin = 0;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.3];
            property.popupViewEdgeInsets = UIEdgeInsetsMake(kStatusAndNavBarHeight, 0, 0, 0);
            property.animationDuration = 0.2;
            
            FWMenuView *menuView = [FWMenuView menuWithItemTitles:self.titleArray itemImageNames:self.imageArray itemBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                
            } property:property];
            
            [menuView show];
        }
            break;
        case 1:
        {
            FWMenuViewProperty *property = [[FWMenuViewProperty alloc] init];
            property.popupCustomAlignment = FWPopupCustomAlignmentTopCenter;
            property.popupAnimationType = FWPopupAnimationTypeScale;
            property.popupArrowStyle = FWMenuArrowStyleRound;
            property.touchWildToHide = @"1";
            property.topBottomMargin = 0;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.3];
            property.popupViewEdgeInsets = UIEdgeInsetsMake(kStatusAndNavBarHeight + CGRectGetMaxY(self.centerBtn.frame), 0, 0, 0);
            property.animationDuration = 0.2;
            
            FWMenuView *menuView = [FWMenuView menuWithItemTitles:self.titleArray itemImageNames:self.imageArray itemBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                
            } property:property];
            
            [menuView show];
        }
            break;
        case 2:
        {
            FWMenuViewProperty *property = [[FWMenuViewProperty alloc] init];
            property.popupCustomAlignment = FWPopupCustomAlignmentBottomLeft;
            property.popupAnimationType = FWPopupAnimationTypeFrame;
            property.popupArrowStyle = FWMenuArrowStyleNone;
            property.touchWildToHide = @"1";
            property.topBottomMargin = 10;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.3];
            property.popupViewEdgeInsets = UIEdgeInsetsMake(0, 10, kScreenH-CGRectGetMinY(self.leftBottomBtn.frame)-kStatusAndNavBarHeight, 0);
            property.animationDuration = 0.3;
            property.cornerRadius = 0;
            
            FWMenuView *menuView = [FWMenuView menuWithItemTitles:self.titleArray itemImageNames:nil itemBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                
            } property:property];
            
            [menuView show];
        }
            break;
        case 3:
        {
            FWMenuViewProperty *property = [[FWMenuViewProperty alloc] init];
            property.popupCustomAlignment = FWPopupCustomAlignmentBottomRight;
            property.popupAnimationType = FWPopupAnimationTypeScale;
            property.popupArrowStyle = FWMenuArrowStyleRound;
            property.touchWildToHide = @"1";
            property.topBottomMargin = 0;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.3];
            property.popupViewEdgeInsets = UIEdgeInsetsMake(0, 0, kScreenH - CGRectGetMinY(self.rightBottomBtn.frame) - kStatusAndNavBarHeight, 10);
            property.animationDuration = 0.2;
            property.popupArrowVertexScaleX = 0.8;
            
            FWMenuView *menuView = [FWMenuView menuWithItemTitles:self.titleArray itemImageNames:self.imageArray itemBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                
            } property:property];
            
            [menuView show];
        }
            break;
            
        default:
            break;
    }
}

- (UIButton *)setupBtn:(NSString *)title frame:(CGRect)frame tag:(int)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    btn.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:btn];
    return btn;
}

@end
