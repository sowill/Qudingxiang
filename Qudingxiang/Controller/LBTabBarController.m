//
//  LBTabBarController.m
//  XianYu
//
//  Created by li  bo on 16/5/28.
//  Copyright © 2016年 li  bo. All rights reserved.
//

#import "LBTabBarController.h"

#import "HomeController.h"
#import "ActivityController.h"
#import "OrderController.h"
#import "MoreViewController.h"
#import "MineViewController.h"

#import "QDXNavigationController.h"
#import "QDXGameViewController.h"
#import "LineController.h"
#import "QDXProtocolViewController.h"
#import "AppDelegate.h"

#import "QDXLoginViewController.h"

#import "LBTabBar.h"
#import "UIImage+Image.h"
#import "UIView+LBExtension.h"
#define LBMagin 10
@interface LBTabBarController ()<LBTabBarDelegate>
{
    NSInteger _line;
    NSInteger _code;
    NSString *_line_id;
    NSString *_ticket;
}
@property (nonatomic, strong) UIButton *publishButton;
@property (nonatomic, assign) long indexFlag;
@end

@implementation LBTabBarController

#pragma mark - 第一次使用当前类的时候对设置UITabBarItem的主题
+ (void)initialize
{

    NSMutableDictionary *dictNormal = [NSMutableDictionary dictionary];
    dictNormal[NSForegroundColorAttributeName] = QDXGray;
    dictNormal[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    
    NSMutableDictionary *dictSelected = [NSMutableDictionary dictionary];
    dictSelected[NSForegroundColorAttributeName] = QDXBlue;
    dictSelected[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    if ([phoneVersion intValue] > 9.0) {
        UITabBarItem *tabBarItem = [UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[self]];
        [tabBarItem setTitleTextAttributes:dictNormal forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:dictSelected forState:UIControlStateSelected];
    }else{
        UITabBarItem *tabBarItem = [UITabBarItem appearanceWhenContainedIn:self, nil];
        [tabBarItem setTitleTextAttributes:dictNormal forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:dictSelected forState:UIControlStateSelected];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //新建自定义TabBar
    LBTabBar *tabbar = [[LBTabBar alloc] init];
    //设置代理，响应发布按钮点击事件
    tabbar.myDelegate = self;
    
    //kvc实质是修改了系统的_tabBar
    [self setValue:tabbar forKeyPath:@"tabBar"];
    
    [self setUpAllChildVc];
}

#pragma mark - ------------------------------------------------------------------
#pragma mark - 初始化tabBar上除了中间按钮之外所有的按钮

- (void)setUpAllChildVc
{
    HomeController *homeVC = [[HomeController alloc] init];
    [self setUpOneChildVcWithVc:homeVC Image:@"index_home_nomal" selectedImage:@"index_home_click" title:@"首页"];
    ActivityController *activityVC = [[ActivityController alloc] init];
    [self setUpOneChildVcWithVc:activityVC Image:@"index_location_nomal" selectedImage:@"index_location_click" title:@"活动"];
    OrderController *orderVC = [[OrderController alloc] init];
    [self setUpOneChildVcWithVc:orderVC Image:@"index_order_nomal" selectedImage:@"index_order_click" title:@"订单"];
    MineViewController *mineVC = [[MineViewController alloc] init];
    [self setUpOneChildVcWithVc:mineVC Image:@"index_more_nomal" selectedImage:@"index_more_click" title:@"我的"];
}

#pragma mark - 初始化设置tabBar上面单个按钮的方法

/**
 *  @author li bo, 16/05/10
 *
 *  设置单个tabBarButton
 *
 *  @param Vc            每一个按钮对应的控制器
 *  @param image         每一个按钮对应的普通状态下图片
 *  @param selectedImage 每一个按钮对应的选中状态下的图片
 *  @param title         每一个按钮对应的标题
 */
- (void)setUpOneChildVcWithVc:(UIViewController *)Vc Image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title
{
    QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:Vc];
    
    UIImage *myImage = [UIImage imageNamed:image];
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //tabBarItem，是系统提供模型，专门负责tabbar上按钮的文字以及图片展示
    Vc.tabBarItem.image = myImage;
    
    UIImage *mySelectedImage = [UIImage imageNamed:selectedImage];
    mySelectedImage = [mySelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    Vc.tabBarItem.selectedImage = mySelectedImage;
    
    Vc.tabBarItem.title = title;
    
    Vc.navigationItem.title = title;
    
    [self addChildViewController:nav];
}



#pragma mark - ------------------------------------------------------------------
#pragma mark - LBTabBarDelegate
//点击中间按钮的代理方法
- (void)tabBarPlusBtnClick:(LBTabBar *)tabBar
{
    AppDelegate *_delegate = [[UIApplication sharedApplication] delegate];
    _code = [_delegate.code intValue];
    _ticket = _delegate.ticket;
    if(_delegate.loading){
        UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:@"加载中请稍后" preferredStyle:UIAlertControllerStyleAlert];
        [aalert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            
        }]];
        [self presentViewController:aalert animated:YES completion:nil];
        
        return;
    }
    if(save == nil){
        
        UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请立即登录使用此功能" preferredStyle:UIAlertControllerStyleAlert];
        [aalert addAction:[UIAlertAction actionWithTitle:@"暂不登录" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
            
        }]];
        [aalert addAction:[UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
            QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
            QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
            [self presentViewController:navController animated:YES completion:^{
                
            }];
        }]];
        [self presentViewController:aalert animated:YES completion:nil];
        
    }else{
        if(_code == 0){
            
            UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请购买活动券" preferredStyle:UIAlertControllerStyleAlert];
            [aalert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
                
            }]];
            [self presentViewController:aalert animated:YES completion:nil];
            
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
