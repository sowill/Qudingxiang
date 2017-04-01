//
//  AppDelegate.m
//  Qudingxiang
//
//  Created by Air on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "AppDelegate.h"
#import "QDXNavigationController.h"
#import "GuideViewController.h"
#import "LBTabBarController.h"
#import "Customer.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = QDXBGColor;   //设置通用背景颜色
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [WXApi registerApp:kWeChat_KEY withDescription:@"weChat"];
    
    [AMapServices sharedServices].apiKey = AMap_KEY;
    
    [self authLogin];

    NSString *currentVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if(![currentVersion isEqualToString:Version]){
        [NSKeyedArchiver archiveRootObject:currentVersion toFile:QDXVersion];
        [self gotoScrollView];
    }else{
        [self gotoHomeController];
    }
    
    return YES;
}

-(void)authLogin
{
    NSString *url = [newHostUrl stringByAppendingString:authLoginUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        if ([responseObject[@"Code"] intValue] == 0) {
            NSFileManager *fileManager = [[NSFileManager alloc]init];
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
            [fileManager removeItemAtPath:documentDir error:nil];
        }else{
            Customer *customer = [[Customer alloc] initWithDic:responseObject[@"Msg"]];
            if ([save length] == 0 ) {
                NSFileManager * fileManager = [[NSFileManager alloc]init];
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
                [fileManager removeItemAtPath:documentDir error:nil];
            }else{
                NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
                [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];

                [NSKeyedArchiver archiveRootObject:customer.customer_token toFile:XWLAccountFile];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)gotoScrollView
{
    GuideViewController *guide = [[GuideViewController alloc] init];
    self.window.rootViewController = guide;
}

- (void)gotoHomeController
{
    LBTabBarController *tabVC = [[LBTabBarController alloc] init];
    self.window.rootViewController = tabVC;
}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
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
//            NSLog(@"用户取消登录");
        } else if (aresp.errCode == -4) {
//            NSLog(@"用户拒绝登录");
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
                if (self.WXPayBlock) {
                    self.WXPayBlock();
                }
            }
        }]];
        UIViewController *root = self.window.rootViewController;
        [root presentViewController:aalert animated:YES completion:nil];
    }
}

@end
