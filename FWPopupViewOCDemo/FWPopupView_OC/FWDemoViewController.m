//
//  FWDemoViewController.m
//  FWPopupView
//
//  Created by xfg on 2018/3/27.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWDemoViewController.h"
#import <FWPopupView/FWPopupView-Swift.h>
#import "FWCustomDemoVC.h"
#import "FWMenuViewDemoVC.h"
#import "SVProgressHUD.h"
#import "FWCustomView.h"

@interface FWDemoViewController ()

@property (nonatomic, strong) NSArray       *titleArray;
@property (nonatomic, strong) FWAlertView   *alertWithImageView;
@property (nonatomic, strong) FWCustomSheetView *customSheetView;
@property (nonatomic, strong) FWCustomSheetView *customSheetView2;

@end

@implementation FWDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"FWPopupView";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    self.tableView.estimatedRowHeight = 44.0;
    
    self.titleArray = @[@"0、Alert - 单个按钮", @"1、Alert - 两个按钮", @"2、Alert - 两个按钮（修改参数）", @"3、Alert - 多个按钮", @"4、Alert - 带输入框", @"5、Alert - 带自定义视图", @"6、Sheet - 少量Item", @"7、Sheet - 大量Item", @"8、Date - 自定义日期选择", @"9、Menu - 自定义菜单", @"10、Custom - 自定义弹窗", @"11、CustomSheet - 类似Sheet效果", @"12、CustomSheet - 类似Sheet效果2", @"13、展示如何让SVProgressHUD显示在FWPopupView上面"];
}


#pragma mark -
#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    if (indexPath.row == 9 || indexPath.row == 10) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"描述描述描述描述" confirmBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                
            }];
            [alertView show];
        }
            break;
        case 1:
        {
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"描述描述描述描述描述描述描述描述描述描述" confirmBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                NSLog(@"点击了确定");
            } cancelBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                NSLog(@"点击了确定");
            }];
            
            [alertView showWithPopupStateBlock:^(FWPopupView * popupView, FWPopupViewState popupViewState) {
                
            }];
        }
            break;
        case 2:
        {
            id block = ^(FWPopupView *popupView, NSInteger index, NSString *title){
                NSLog(@"AlertView：点击了第 %ld 个按钮", (long)index);
            };
            
            // 注意：此时“确定”按钮是不让按钮自己隐藏的
            NSArray *items = @[[[FWPopupItem alloc] initWithTitle:@"取消" itemType:FWItemTypeNormal isCancel:YES canAutoHide:YES itemTitleColor:kRGB(141, 151, 163) itemBackgroundColor:nil itemClickedBlock:block],
                               [[FWPopupItem alloc] initWithTitle:@"确定" itemType:FWItemTypeNormal isCancel:NO canAutoHide:YES itemTitleColor:kRGB(29, 150, 227) itemBackgroundColor:nil itemClickedBlock:block]];
            
            FWAlertViewProperty *vProperty = [[FWAlertViewProperty alloc] init];
            vProperty.alertViewWidth = MAX([UIScreen mainScreen].bounds.size.width * 0.65, 275);
            vProperty.titleFontSize = 17.0;
            vProperty.detailFontSize = 14.0;
            vProperty.detailColor = kRGB(141, 151, 163);
            vProperty.buttonFontSize = 14.0;
            // 还有很多参数可设置...
            
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"描述描述描述描述描述描述描述描述描述描述" inputPlaceholder:nil keyboardType:UIKeyboardTypeDefault isSecureTextEntry:NO customView:nil items:items vProperty:vProperty];
            [alertView show];
        }
            break;
        case 3:
        {
            id block = ^(FWPopupView *popupView, NSInteger index, NSString *title){
                NSLog(@"AlertView：点击了第 %ld 个按钮", (long)index);
            };
            
            NSArray *items = @[[[FWPopupItem alloc] initWithTitle:@"取消" itemType:FWItemTypeNormal isCancel:YES canAutoHide:YES itemClickedBlock:block],
                               [[FWPopupItem alloc] initWithTitle:@"确定" itemType:FWItemTypeNormal isCancel:NO canAutoHide:YES itemClickedBlock:block],
                               [[FWPopupItem alloc] initWithTitle:@"其他" itemType:FWItemTypeNormal isCancel:NO canAutoHide:YES itemClickedBlock:block]];
            
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"描述描述描述描述描述描述描述描述描述描述" inputPlaceholder:nil keyboardType:UIKeyboardTypeDefault isSecureTextEntry:NO customView:nil items:items];
            [alertView show];
        }
            break;
        case 4:
        {
            id block = ^(FWPopupView *popupView, NSInteger index, NSString *title){
                NSLog(@"AlertView：点击了第 %ld 个按钮", (long)index);
            };
            NSArray *items = @[[[FWPopupItem alloc] initWithTitle:@"取消" itemType:FWItemTypeNormal isCancel:YES canAutoHide:YES itemClickedBlock:block],
                               [[FWPopupItem alloc] initWithTitle:@"确定" itemType:FWItemTypeNormal isCancel:NO canAutoHide:YES itemClickedBlock:block]];
            
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"带输入框" inputPlaceholder:@"请输入..." keyboardType:UIKeyboardTypeDefault isSecureTextEntry:YES customView:nil items:items];
            [alertView show];
        }
            break;
        case 5:
        {
            __weak typeof(self) weakSelf = self;
            id block = ^(FWPopupView *popupView, NSInteger index, NSString *title){
                if (index == 1)
                {
                    // 这边演示了如何手动去调用隐藏
                    [weakSelf.alertWithImageView hide];
                }
            };
            
            // 注意：此时“确定”按钮是不让按钮自己隐藏的
            NSArray *items = @[[[FWPopupItem alloc] initWithTitle:@"取消" itemType:FWItemTypeNormal isCancel:YES canAutoHide:YES itemClickedBlock:block],
                               [[FWPopupItem alloc] initWithTitle:@"确定" itemType:FWItemTypeNormal isCancel:NO canAutoHide:NO itemClickedBlock:block]];
            UIImageView *customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_bgm_4"]];
            
            self.alertWithImageView = [FWAlertView alertWithTitle:@"标题" detail:@"带输入框" inputPlaceholder:nil keyboardType:UIKeyboardTypeDefault isSecureTextEntry:NO customView:customImageView items:items];
            [self.alertWithImageView show];
        }
            break;
        case 6:
        {
            NSArray *items = @[@"Sheet0", @"Sheet1", @"Sheet2", @"Sheet3"];
            
            FWSheetView *sheetView = [FWSheetView sheetWithTitle:nil itemTitles:items itemBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                NSLog(@"Sheet：点击了第 %ld 个按钮", (long)index);
            } cancenlBlock:^{
                NSLog(@"点击了取消");
            }];
            sheetView.vProperty.touchWildToHide = @"1";
            [sheetView show];
        }
            break;
        case 7:
        {
            NSArray *items = @[@"Sheet0", @"Sheet1", @"Sheet2", @"Sheet4", @"Sheet5", @"Sheet6", @"Sheet7", @"Sheet8", @"Sheet9", @"Sheet10", @"Sheet11", @"Sheet12", @"Sheet13", @"Sheet14"];
            
            FWSheetView *sheetView = [FWSheetView sheetWithTitle:@"标题" itemTitles:items itemBlock:^(FWPopupView *popupView, NSInteger index, NSString *title) {
                NSLog(@"Sheet：点击了第 %ld 个按钮", (long)index);
            } cancenlBlock:^{
                NSLog(@"点击了取消");
            }];
            [sheetView show];
        }
            break;
        case 8:
        {
            FWDateView *dateView = [FWDateView dateWithConfirmBlock:^(UIDatePicker *datePicker) {
                NSLog(@"点击了 FWDateView 的确定");
            } cancelBlock:^{
                NSLog(@"点击了 FWDateView 的取消");
            }];
            [dateView show];
        }
            break;
        case 9:
        {
            [self.navigationController pushViewController:[[FWMenuViewDemoVC alloc] init] animated:YES];
        }
            break;
        case 10:
        {
            [self.navigationController pushViewController:[[FWCustomDemoVC alloc] init] animated:YES];
        }
            break;
        case 11:
        {
            [self.customSheetView show];
        }
            break;
        case 12:
        {
            [self.customSheetView2 show];
        }
            break;
        case 13:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.6, [UIScreen mainScreen].bounds.size.height * 0.3)];
            customView.backgroundColor = [UIColor yellowColor];
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleScale;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.3];
            property.touchWildToHide = @"1";
            property.animationDuration = 0.2;
            customView.vProperty = property;
            [customView show];
            
            // 重新设置SVProgressHUD的Window层级
            [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelStatusBar+2];
            [SVProgressHUD show];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark - GET

- (FWCustomSheetView *)customSheetView
{
    if (!_customSheetView) {
        FWCustomSheetViewProperty *property = [[FWCustomSheetViewProperty alloc] init];
        property.popupViewItemHeight = 40;
        property.selectedIndex = 1;
        
        NSArray *itemTitles = @[@"Objective-C", @"Swift", @"Java", @"python"];
        
        _customSheetView = [FWCustomSheetView sheetWithHeaderTitle:@"选择开发语言" itemTitles:itemTitles itemSecondaryTitles:nil itemImages:nil itemBlock:^(FWPopupView * popupView, NSInteger index, NSString *title) {
            NSLog(@"当前选中了：%@", title);
        } property:property];
    }
    return _customSheetView;
}

- (FWCustomSheetView *)customSheetView2
{
    if (!_customSheetView2) {
        FWCustomSheetViewProperty *property2 = [[FWCustomSheetViewProperty alloc] init];
        property2.lastNeedAccessoryView = YES;

        NSArray *itemTitles2 = @[@"Objective-C", @"Swift", @"其他开发语言"];
        NSArray *itemSecondaryTitles2 = @[@"Objective-C，通常写作ObjC或OC和较少用的Objective C或Obj-C", @"Swift 是苹果推出的编程语言，专门针对 OS X 和 iOS 的应用开发", @""];

        _customSheetView2 = [FWCustomSheetView sheetWithHeaderTitle:@"选择一种开发语言" itemTitles:itemTitles2 itemSecondaryTitles:itemSecondaryTitles2 itemImages:nil itemBlock:^(FWPopupView * popupView, NSInteger index, NSString *title) {
            NSLog(@"当前选中了：%@", title);
        } property:property2];
    }
    return _customSheetView2;
}

@end
