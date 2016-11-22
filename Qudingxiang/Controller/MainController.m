//
//  MainController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/16.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "MainController.h"
#import "HomeController.h"
#import "OrderController.h"
#import "myViewController.h"
#import "ActivityController.h"
#import "QDXProtocolViewController.h"
#import "QDXGameViewController.h"
#import "MoreViewController.h"
#import "MineViewController.h"

@interface MainController ()<UITabBarControllerDelegate>
{
    UIImageView *_imageView;
}
@end

@implementation MainController




- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
}

- (void)createView
{
    HomeController *homeVC = [[HomeController alloc] init];
    ActivityController *activityVC = [[ActivityController alloc] init];
    OrderController *orderVC = [[OrderController alloc] init];
    myViewController *mineVC = [[myViewController alloc] init];
    QDXGameViewController *gameVC = [[QDXGameViewController alloc] init];

    
    QDXNavigationController * homeNav = [[QDXNavigationController alloc] initWithRootViewController:homeVC];
    homeNav.title = @"首页";
    homeNav.tabBarItem.image = [UIImage imageNamed:@"index_home_nomal"];
    homeNav.tabBarItem.selectedImage = [UIImage imageNamed:@"index_home_click"];
    homeVC.tabBarController.tabBar.tag = 0;
    
    QDXNavigationController * activityNav = [[QDXNavigationController alloc] initWithRootViewController:activityVC];
    activityNav.title = @"活动";
    activityNav.tabBarItem.image = [UIImage imageNamed:@"index_location_nomal"];
    activityNav.tabBarItem.selectedImage = [UIImage imageNamed:@"index_location_click"];
    activityVC.tabBarController.tabBar.tag = 1;
    
    QDXNavigationController *gameNav = [[QDXNavigationController alloc] initWithRootViewController:gameVC];
    gameNav.title = @"";
    gameNav.tabBarItem.image = [UIImage imageNamed:@"index_go"];
    gameVC.tabBarController.tabBar.tag = 2;
    
    QDXNavigationController * orderNav = [[QDXNavigationController alloc] initWithRootViewController:orderVC];
    orderNav.title = @"订单";
    orderNav.tabBarItem.image = [UIImage imageNamed:@"index_order_nomal"];
    orderNav.tabBarItem.selectedImage = [UIImage imageNamed:@"index_order_click"];
    orderVC.tabBarController.tabBar.tag = 3;
    
    QDXNavigationController * mineNav = [[QDXNavigationController alloc] initWithRootViewController:mineVC];
    mineNav.title = @"我的";
    mineNav.tabBarItem.image = [UIImage imageNamed:@"index_more_nomal"];
    mineNav.tabBarItem.selectedImage = [UIImage imageNamed:@"index_more_click"];
    mineVC.tabBarController.tabBar.tag = 4;
    
    self.viewControllers = @[homeNav,activityNav,gameNav,orderNav,mineNav];
   
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:11/255.0 green:11/255.0 blue:11/255.0 alpha:1]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:253/255.0 alpha:1]} forState:UIControlStateSelected];
    self.tabBar.backgroundImage = [[UIImage imageNamed:@"index_tab_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    self.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@""] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //去掉tabbar黑线
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self.tabBar setShadowImage:img];
    //
    for (UITabBarItem *item in self.tabBar.items) {
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
