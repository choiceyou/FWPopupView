//
//  FWCustomDemoVC.m
//  FWPopupView_OC
//
//  Created by xfg on 2018/5/29.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWCustomDemoVC.h"

@interface FWCustomDemoVC ()

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation FWCustomDemoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"信手拈来的弹窗";
    
    self.titleArray = @[@"center - scale", @"topCenter - position", @"topCenter - frame", @"topCenter - scale", @"leftCenter - position", @"leftCenter - frame", @"leftCenter - scale", @"bottomCenter - position", @"bottomCenter - frame", @"bottomCenter - scale", @"rightCenter - position", @"rightCenter - frame", @"rightCenter - scale"];
    
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
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.6, [UIScreen mainScreen].bounds.size.height * 0.3)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleScale;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.3];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.2;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 1:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.4)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentTopCenter;
            property.popupAnimationStyle = FWPopupAnimationStylePosition;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.2;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 2:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.4)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentTopCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleFrame;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(64, 0, 0, 0);
            property.animationDuration = 0.5;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 3:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.4)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentTopCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleScale;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(64, 0, 0, 0);
            property.animationDuration = 0.5;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
            
        case 4:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.6, [UIScreen mainScreen].bounds.size.height)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentLeftCenter;
            property.popupAnimationStyle = FWPopupAnimationStylePosition;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.3;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 5:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.4, [UIScreen mainScreen].bounds.size.height * 0.5)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentLeftCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleFrame;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.3;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 6:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.4, [UIScreen mainScreen].bounds.size.height * 0.5)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentLeftCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleScale;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
            property.animationDuration = 0.3;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
            
        case 7:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.4)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentBottomCenter;
            property.popupAnimationStyle = FWPopupAnimationStylePosition;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.2;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 8:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.4)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentBottomCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleFrame;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 64, 0);
            property.animationDuration = 0.5;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 9:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.4)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentBottomCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleScale;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.5;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
            
        case 10:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.6, [UIScreen mainScreen].bounds.size.height)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentRightCenter;
            property.popupAnimationStyle = FWPopupAnimationStylePosition;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.3;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 11:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.4, [UIScreen mainScreen].bounds.size.height * 0.5)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentRightCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleFrame;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
            property.animationDuration = 0.3;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
        case 12:
        {
            FWCustomView *customView = [[FWCustomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.4, [UIScreen mainScreen].bounds.size.height * 0.5)];
            
            FWPopupBaseViewProperty *property = [FWPopupBaseViewProperty manager];
            property.popupAlignment = FWPopupAlignmentRightCenter;
            property.popupAnimationStyle = FWPopupAnimationStyleScale;
            property.maskViewColor = [UIColor colorWithWhite:0 alpha:0.5];
            property.touchWildToHide = @"1";
            property.popupEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            property.animationDuration = 0.3;
            customView.vProperty = property;
            
            [customView show];
        }
            break;
            
        default:
            break;
    }
}

@end
