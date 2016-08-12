//
//  AppDelegate.h
//  Qudingxiang
//
//  Created by Air on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,RESideMenuDelegate>
@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) MainController *mianVC;
@property NSString *code;
@property NSString *ticket;
@property bool loading;
@end

