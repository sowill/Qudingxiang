//
//  UIControl+UIControl_buttonCon.h
//  趣定向
//
//  Created by Air on 16/6/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

#define defaultInterval .5//默认时间间隔

@interface UIControl (UIControl_buttonCon)

@property(nonatomic,assign) NSTimeInterval timeInterval;//用这个给重复点击加间隔

@property(nonatomic,assign) BOOL isIgnoreEvent;//YES不允许点击NO允许点击

@end
