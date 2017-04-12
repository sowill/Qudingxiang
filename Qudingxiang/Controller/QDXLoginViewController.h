//
//  QDXLoadViewController.h
//  Qudingxiang
//
//  Created by Air on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PassTrendValueDelegate
-(void)passTrendValues:(NSString *)values andWXValue:(NSString *)WXValues;//1.1定义协议与方法
@end

@interface QDXLoginViewController : BaseViewController
@property (retain,nonatomic) id <PassTrendValueDelegate> trendDelegate;
@end
