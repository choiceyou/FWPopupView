//
//  UIView+PopupView.h
//  FWPopupViewOC
//
//  Created by xfg on 2017/5/25.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 github地址：https://github.com/choiceyou/FWPopupViewOC
 bug反馈、交流群：670698309
 
 ***************************************************
 */


#import <UIKit/UIKit.h>


// weakself strongself
#define FWPWeakify(o)           __weak   typeof(self) fwwo = o;
#define FWPStrongify(o)         __strong typeof(self) o = fwwo;


@interface UIView (PopupView)

@property (nonatomic, strong, readonly) UIView      *dimMaskView;
@property (nonatomic, strong) UIColor               *dimMaskViewColor;
@property (nonatomic, assign) BOOL                  dimMaskAnimating;
@property (nonatomic, assign) NSTimeInterval        dimMaskAnimationDuration;
@property (nonatomic, assign, readwrite) NSInteger  dimReferenceCount;

- (void)showDimMask;
- (void)hideDimMask;

- (void)resetDimMaskView;

@end
