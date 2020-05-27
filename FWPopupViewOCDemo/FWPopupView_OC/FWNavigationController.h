//
//  FWNavigationController.h
//  FanweApp
//
//  Created by xfg on 2017/6/26.
//  Copyright © 2017年 xfg. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 通用的没有返回参数回调
 */
typedef void (^FWVoidBlock)(void);

@interface FWNavigationController : UINavigationController

@property (nonatomic, copy) FWVoidBlock vcBackActionBlock;

@end
