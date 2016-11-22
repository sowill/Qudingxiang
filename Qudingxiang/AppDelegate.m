//
//  AppDelegate.m
//  Qudingxiang
//
//  Created by Air on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "AppDelegate.h"
//#import "QDXLoginViewController.h"
//#import "QDXIsConnect.h"
#import "QDXNavigationController.h"
#import "MineViewController.h"
#import "GuideViewController.h"
#import "LBTabBarController.h"
//#import "HomeService.h"

#import "HomeController.h"
#import "ActivityController.h"
#import "OrderController.h"
#import "MoreViewController.h"
//#import "TabbarController.h"

#import "MCLeftSlideViewController.h"
#import "MCLeftSliderManager.h"

@interface AppDelegate ()<UIScrollViewDelegate>
{
    UIBackgroundTaskIdentifier backgroundTask;
    NSUInteger counter;
    UIScrollView *_sv;
    UIPageControl *_pc;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];   //设置通用背景颜色
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [WXApi registerApp:kWeChat_KEY withDescription:@"weChat"];
    
    [AMapServices sharedServices].apiKey = @"deebe04a4a659c7c40eeeaad2e4b97cf";
    //判断当前版本是否是新版本
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    
    //取出当前应用的版本号
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    //取出沙盒存储的应用版本号
    NSString *saveVersion = Version;
    if(![currentVersion isEqualToString:saveVersion]){
        [NSKeyedArchiver archiveRootObject:currentVersion toFile:QDXVersion];
        [self gotoScrollView];
    }else{
        [self gotoHomeController];
    }
    
    return YES;
}

- (void)gotoScrollView
{
    GuideViewController *guide = [[GuideViewController alloc] init];
    self.window.rootViewController = guide;
}

- (void)gotoHomeController
{
    
//    HomeController *homeVC = [[HomeController alloc] init];
//    
//    UINavigationController *firstNav = [[QDXNavigationController alloc] initWithRootViewController:homeVC];
//    firstNav.tabBarItem.image = [UIImage imageNamed:@"index_home_nomal"];
//    homeVC.title = @"首页";
////    homeVC.navigationController.navigationBar.barTintColor = [UIColor redColor];
//    
//    ActivityController *activityVC = [[ActivityController alloc] init];
//    
//    UINavigationController *secondNav = [[QDXNavigationController alloc] initWithRootViewController:activityVC];
//    secondNav.tabBarItem.image = [UIImage imageNamed:@"index_location_click"];
//    activityVC.title = @"活动";
//    
//    OrderController *orderVC = [[OrderController alloc] init];
//    
//    UINavigationController *thridNav = [[QDXNavigationController alloc] initWithRootViewController:orderVC];
//    thridNav.tabBarItem.image = [UIImage imageNamed:@"index_order_nomal"];
//    orderVC.title = @"订单";
//    
//    MoreViewController *moreVC = [[MoreViewController alloc] init];
//    
//    UINavigationController *fourNav = [[QDXNavigationController alloc] initWithRootViewController:moreVC];
//    fourNav.tabBarItem.image = [UIImage imageNamed:@"index_more_nomal"];
//    moreVC.title = @"更多";
//    
//    TabbarController *tabVC = [[TabbarController alloc] init];
//    [tabVC setViewControllers:@[firstNav,secondNav,thridNav,fourNav]];
//    tabVC.tabBar.tintColor = QDXBlue;
    
    LBTabBarController *tabVC = [[LBTabBarController alloc] init];
    
    MineViewController *leftVC = [[MineViewController alloc] init];
    MCLeftSlideViewController *rootVC = [[MCLeftSlideViewController alloc] initWithLeftView:leftVC andMainView:tabVC];
    self.window.rootViewController = rootVC;
    
    // 启动图片
//    [[MCAdvertManager sharedInstance] setAdvertViewController];
}

//- (void)gotoLogin
//{
//    QDXLoginViewController *loginVC = [[QDXLoginViewController alloc] init];
//    QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:loginVC];
//    self.window.rootViewController = nav;
////    QDXLoginViewController *loginVC = [[QDXLoginViewController alloc] init];
////    self.window.rootViewController = loginVC;
//}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            NSString *message = @"";
            switch([[resultDic objectForKey:@"resultStatus"] integerValue])
            {
                case 9000:message = @"订单支付成功";break;
                case 8000:message = @"正在处理中";break;
                case 4000:message = @"订单支付失败";break;
                case 6001:message = @"用户中途取消";break;
                case 6002:message = @"网络连接错误";break;
                default:message = @"未知错误";
            }
            
            UIAlertController *aalert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [aalert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
            UIViewController *root = self.window.rootViewController;
            [root presentViewController:aalert animated:YES completion:nil];
            

        }];
    }

    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:self];
}

-(void) onReq:(BaseReq*)req
{

}

//授权后回调
-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]){
        
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode == 0) {
            NSString *code = aresp.code;
            NSDictionary *dic = @{@"code":code};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WECHAT" object:nil userInfo:dic];
        }else if (aresp.errCode == -2) {
            NSLog(@"用户取消登录");
        } else if (aresp.errCode == -4) {
            NSLog(@"用户拒绝登录");
        } else {
            
        }
    }else if ([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                break;
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败!"];
                break;
        }
        UIAlertController *aalert = [UIAlertController alertControllerWithTitle:strTitle message:strMsg preferredStyle:UIAlertControllerStyleAlert];
        [aalert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            if ([strMsg isEqualToString:@"支付结果：成功！"]) {
                [self gotoHomeController];
            }
        }]];
        UIViewController *root = self.window.rootViewController;
        [root presentViewController:aalert animated:YES completion:nil];
    }
}

@end
