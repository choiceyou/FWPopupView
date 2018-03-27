//
//  FWDemoViewController.m
//  FWPopupView
//
//  Created by xfg on 2018/3/27.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWDemoViewController.h"
#import "FWPopupView_OC-Swift.h"

@interface FWDemoViewController ()

@property (nonatomic, strong) NSArray   *titleArray;

@end

@implementation FWDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"FWPopupView";
    
    self.titleArray = @[@"Alert - 单个按钮", @"Alert - 两个按钮", @"Alert - 多个按钮", @"Alert - 带输入框", @"Alert - 带自定义视图", @"Sheet - 少量Item", @"Sheet - 大量Item", @"Custom - 自定义弹窗"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    self.tableView.estimatedRowHeight = 44.0;
}

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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"描述描述描述描述" confirmBlock:^(NSInteger index) {
                NSLog(@"点击了确定");
            }];
            [alertView show];
        }
            break;
        case 1:
        {
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"描述描述描述描述描述描述描述描述描述描述" confirmBlock:^(NSInteger index) {
                NSLog(@"点击了确定");
            } cancelBlock:^(NSInteger index) {
                NSLog(@"点击了确定");
            }];
            [alertView showWithCompletionBlock:^(FWPopupView * popupView, BOOL isCompletion) {
                
            }];
        }
            break;
        case 2:
        {
            id block = ^(NSInteger index){
                NSLog(@"AlertView：点击了第 %ld 个按钮", (long)index);
            };
            NSArray *items = @[[[FWPopupItem alloc] initWithTitle:@"取消" itemType:FWItemTypeNormal isCancel:YES handler:block],
                               [[FWPopupItem alloc] initWithTitle:@"确定" itemType:FWItemTypeNormal isCancel:NO handler:block],
                               [[FWPopupItem alloc] initWithTitle:@"其他" itemType:FWItemTypeNormal isCancel:NO handler:block]];
            FWAlertViewProperty *property = [[FWAlertViewProperty alloc] init];
            property.detailColor = UIColor.redColor;
            
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"描述描述描述描述描述描述描述描述描述描述" inputPlaceholder:nil customView:nil items:items vProperty:property];
            [alertView show];
        }
            break;
        case 3:
        {
            id block = ^(NSInteger index){
                NSLog(@"AlertView：点击了第 %ld 个按钮", (long)index);
            };
            NSArray *items = @[[[FWPopupItem alloc] initWithTitle:@"取消" itemType:FWItemTypeNormal isCancel:YES handler:block],
                               [[FWPopupItem alloc] initWithTitle:@"确定" itemType:FWItemTypeNormal isCancel:NO handler:block]];
            
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"带输入框" inputPlaceholder:@"请输入..." customView:nil items:items];
            [alertView show];
        }
            break;
        case 4:
        {
            id block = ^(NSInteger index){
                NSLog(@"AlertView：点击了第 %ld 个按钮", (long)index);
            };
            NSArray *items = @[[[FWPopupItem alloc] initWithTitle:@"取消" itemType:FWItemTypeNormal isCancel:YES handler:block],
                               [[FWPopupItem alloc] initWithTitle:@"确定" itemType:FWItemTypeNormal isCancel:NO handler:block]];
            UIImageView *customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_bgm_4"]];
            
            FWAlertView *alertView = [FWAlertView alertWithTitle:@"标题" detail:@"带输入框" inputPlaceholder:nil customView:customImageView items:items];
            [alertView show];
        }
            break;
        case 5:
        {
            NSArray *items = @[@"Sheet0", @"Sheet1", @"Sheet2", @"Sheet3"];
            
            FWSheetView *sheetView = [FWSheetView sheetWithTitle:@"标题" itemTitles:items itemBlock:^(NSInteger index) {
                NSLog(@"Sheet：点击了第 %ld 个按钮", (long)index);
            } cancenlBlock:^{
                NSLog(@"点击了取消");
            }];
            [sheetView show];
        }
            break;
        case 6:
        {
            NSArray *items = @[@"Sheet0", @"Sheet1", @"Sheet2", @"Sheet4", @"Sheet5", @"Sheet6", @"Sheet7", @"Sheet8", @"Sheet9", @"Sheet10", @"Sheet11", @"Sheet12", @"Sheet13", @"Sheet14"];
            
            FWSheetView *sheetView = [FWSheetView sheetWithTitle:@"标题" itemTitles:items itemBlock:^(NSInteger index) {
                NSLog(@"Sheet：点击了第 %ld 个按钮", (long)index);
            } cancenlBlock:^{
                NSLog(@"点击了取消");
            }];
            [sheetView show];
        }
            break;
        case 7:
        {
            FWDateView *dateView = [FWDateView dateWithConfirmBlock:^(UIDatePicker *datePicker) {
                NSLog(@"点击了 FWDateView 的确定");
            } cancelBlock:^{
                NSLog(@"点击了 FWDateView 的取消");
            }];
            [dateView show];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
