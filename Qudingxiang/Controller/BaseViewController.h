//
//  BaseViewController.h
//  趣定向
//
//  Created by Prince on 16/3/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
- (void)hideProgess;
- (void)showProgessMsg:(NSString *)msg;
- (void)showProgessOK:(NSString *)msg;
- (void)showProgessError:(NSString *)msg;
- (void)showNotData:(NSString *)msg;

@end
