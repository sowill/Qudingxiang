//
//  TabbarController.m
//  趣定向
//
//  Created by Prince on 16/4/29.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "TabbarController.h"

#import "TabbarView.h"

#import "QDXNavigationController.h"
#import "QDXGameViewController.h"
#import "LineController.h"
#import "QDXProtocolViewController.h"
#import "AppDelegate.h"

@interface TabbarController ()<TabbarViewDelegate>
{
    NSInteger _code;
    NSString *_ticket;
}
@end

@implementation TabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTabBar];

}


#pragma mark - 3、添加自定义tabBar------
- (void)setupTabBar
{
    // 1、创建自定义的CHTabBar;
    TabbarView *tabBar = [[TabbarView alloc] init];
    [self setValue:tabBar forKey:@"tabBar"];
}

#pragma mark - ------------------------------------------------------------------
#pragma mark - TabBarDelegate
//点击中间按钮的代理方法
- (void)tabBarDidClickedPlusButton:(TabbarView *)tabBar
{
    AppDelegate *_delegate = [[UIApplication sharedApplication] delegate];
    _code = [_delegate.code intValue];
    _ticket = _delegate.ticket;
    if(_delegate.loading){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载中请稍后" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
    }
    if(save == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请立即登录使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
        
    }else{
        if(_code == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请购买活动券" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
        }else if(_code == 2){
            LineController *lineVC = [[LineController alloc] init];
            lineVC.click = @"1";
            lineVC.ticketID = _ticket;
            QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:lineVC];
            [self presentViewController:nav animated:YES completion:^{
                
            }];
            
        }else if(_code == 1){
            NSString *isHave = [NSKeyedUnarchiver unarchiveObjectWithFile:QDXMyLineFile];
            if (isHave) {
                QDXGameViewController *game = [[QDXGameViewController alloc] init];
                QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:game];
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }else{
                QDXProtocolViewController *viewController = [[QDXProtocolViewController alloc] init];
                QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:viewController];
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }
        }
        
    }
    
}

@end
