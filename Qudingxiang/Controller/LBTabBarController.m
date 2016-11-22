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
    UITabBarItem *tabBarItem = [UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[self]];
    
    NSMutableDictionary *dictNormal = [NSMutableDictionary dictionary];
    dictNormal[NSForegroundColorAttributeName] = [UIColor colorWithRed:11/255.0 green:11/255.0 blue:11/255.0 alpha:1];
    dictNormal[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    
    NSMutableDictionary *dictSelected = [NSMutableDictionary dictionary];
    dictSelected[NSForegroundColorAttributeName] = [UIColor colorWithRed:0/255.0 green:153/255.0 blue:253/255.0 alpha:1];
    dictSelected[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    
    [tabBarItem setTitleTextAttributes:dictNormal forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:dictSelected forState:UIControlStateSelected];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 删除系统自动生成的UITabBarButton
    
    //    for (UIView *child in self.tabBar.subviews) {
    //
    //        if ([child isKindOfClass:[UIControl class]]) {
    //            [child removeFromSuperview];
    //        }
    //    }
    
    //新建自定义TabBar
    LBTabBar *tabbar = [[LBTabBar alloc] init];
    //设置代理，响应发布按钮点击事件
    tabbar.myDelegate = self;
    //kvc实质是修改了系统的_tabBar
    [self setValue:tabbar forKeyPath:@"tabBar"];
    
    //    tabbar.backgroundColor = [UIColor whiteColor];
    
    self.publishButton = [[UIButton alloc] init];
    [self.publishButton setBackgroundImage:[UIImage imageNamed:@"post_normal"] forState:UIControlStateNormal];
    [self.publishButton setBackgroundImage:[UIImage imageNamed:@"post_normal"] forState:UIControlStateHighlighted];
    
//    [self.publishButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.publishButton.size = CGSizeMake(self.publishButton.currentBackgroundImage.size.width, self.publishButton.currentBackgroundImage.size.height);
    self.publishButton.centerX = self.view.centerX;
    self.publishButton.centerY = tabbar.height * 0.5 - 2 * LBMagin + CGRectGetMinY(tabbar.frame);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpAllChildVc];
    
//    //创建自己的tabbar，然后用kvc将自己的tabbar和系统的tabBar替换下
//    LBTabBar *tabbar = [[LBTabBar alloc] init];
//    tabbar.myDelegate = self;
//    //kvc实质是修改了系统的_tabBar
//    [self setValue:tabbar forKeyPath:@"tabBar"];
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
    MoreViewController *mineVC = [[MoreViewController alloc] init];
    [self setUpOneChildVcWithVc:mineVC Image:@"index_more_nomal" selectedImage:@"index_more_click" title:@"玩法"];
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
    
    
    //Vc.view.backgroundColor = [self randomColor];
    
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

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    NSInteger index = [self.tabBar.items indexOfObject:item];
    
    if (self.indexFlag != index) {
        [self animationWithIndex:index];
    }

}
// 动画
- (void)animationWithIndex:(NSInteger) index {
    NSMutableArray * tabbarbuttonArray = [NSMutableArray array];
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabbarbuttonArray addObject:tabBarButton];
        }
    }
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.08;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:0.7];
    pulse.toValue= [NSNumber numberWithFloat:1.3];
    [[tabbarbuttonArray[index] layer]
     addAnimation:pulse forKey:nil];
    
    self.indexFlag = index;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
    }
}


- (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(256);
    CGFloat g = arc4random_uniform(256);
    CGFloat b = arc4random_uniform(256);
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
    
}

@end
