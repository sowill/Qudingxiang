//
//  AppDelegate.h
//  Qudingxiang
//
//  Created by Air on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong)void (^WXPayBlock)();
@property NSString *code;
@property NSString *ticket;
@property bool loading;
@end

