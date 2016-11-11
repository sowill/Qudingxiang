//
//  TabbarController.m
//  趣定向
//
//  Created by Prince on 16/4/29.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "TabbarController.h"
#import "HomeController.h"
#import "ActivityController.h"
#import "QDXGameViewController.h"
#import "OrderController.h"
#import "MoreViewController.h"
#import "QDXNavigationController.h"
#import "RESideMenu.h"
#import "TabbarView.h"
#import "QDXLoginViewController.h"
#import "QDXProtocolViewController.h"
#import "HomeService.h"
#import "LineController.h"
#import "AppDelegate.h"
@interface TabbarController ()<TabbarViewDelegate>
{
    NSInteger _line;
    NSInteger _code;
    NSString *_line_id;
    NSString *_ticket;
}
@property (nonatomic, strong) QDXNavigationController *nav;
@property (nonatomic, weak) TabbarView *customTabBar;
@end

@implementation TabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化tabbar
    [self setupTabbar];
    // 初始化所有的子控制器
    [self setupAllChildViewControllers];
}

- (void)getSubViews:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if (subView.subviews.count) {
            [self getSubViews:subView];
        } else {
            if (subView.frame.size.height <= 1) {
                NSLog(@"----%@", subView);
                //  <UIImageView: 0x7fa5b3500000; frame = (0 64; 375 0.5); userInteractionEnabled = NO; layer = <CALayer: 0x60000002be80>>
                [subView removeFromSuperview];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 删除系统自动生成的UITabBarButton

    for (UIView *child in self.tabBar.subviews) {
        
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getSubViews:self.tabBar];
}

- (void)setupTabbar
{
    TabbarView *customTabBar = [[TabbarView alloc] init];
    customTabBar.frame = self.tabBar.bounds;
    customTabBar.delegate = self;
    [self.tabBar addSubview:customTabBar];
    self.customTabBar = customTabBar;
}

- (void)tabBar:(TabbarView *)tabBar didSelectedButtonFrom:(int)from to:(int)to
{
    self.selectedIndex = to;
}


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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        [self presentViewController:navController animated:YES completion:^{
            
        }];

    }
}

- (void)setupAllChildViewControllers
{
    HomeController *homeVC = [[HomeController alloc] init];
    [self setupChildViewController:homeVC title:@"首页" imageName:@"index_home_nomal" selectedImageName:@"index_home_click"];
    ActivityController *activityVC = [[ActivityController alloc] init];
    [self setupChildViewController:activityVC title:@"活动" imageName:@"index_location_nomal" selectedImageName:@"index_location_click"];
    OrderController *orderVC = [[OrderController alloc] init];
    [self setupChildViewController:orderVC title:@"订单" imageName:@"index_order_nomal" selectedImageName:@"index_order_click"];
    MoreViewController *mineVC = [[MoreViewController alloc] init];
    [self setupChildViewController:mineVC title:@"社区" imageName:@"社区－常态" selectedImageName:@"社区－点击"];
    
//    UIImage *image = [UIImage imageNamed:@"index_tab_bg"];
//    
//    CGFloat top = 10; // 顶端盖高度
//    CGFloat bottom =  10; // 底端盖高度
//    CGFloat left = 20; // 左端盖宽度
//    CGFloat right = 20; // 右端盖宽度
//    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
//    // 指定为拉伸模式，伸缩后重新赋值
//    UIImage *TabBgImage = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
//    self.tabBar.backgroundImage = TabBgImage;

    self.tabBar.backgroundImage = [[UIImage imageNamed:@"index_tab_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (void)setupChildViewController:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    // 1.设置控制器的属性
    childVc.title = title;
    // 设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:imageName];
    // 设置选中的图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    
    childVc.tabBarItem.selectedImage = selectedImage;
    
    
    // 2.包装一个导航控制器
    QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
    
    // 3.添加tabbar内部的按钮
    [self.customTabBar addTabBarButtonWithItem:childVc.tabBarItem];
            
    //去掉tabbar黑线
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 1);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self.tabBar setShadowImage:img];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
