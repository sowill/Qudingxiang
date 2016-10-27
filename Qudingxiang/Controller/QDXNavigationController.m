//
//  QDXNavigationController.m
//  Qudingxiang
//
//  Created by Air on 15/9/23.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXNavigationController.h"

@interface QDXNavigationController ()

@end

@implementation QDXNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+(void)initialize
{
    // 1.设置导航栏主题
    UINavigationBar *navBar = [UINavigationBar appearance];
    

    [navBar setBackgroundImage:[UIImage imageNamed:@"navigation"] forBarMetrics:UIBarMetricsDefault];
    
    // 设置标题文字颜色
//    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
//    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
//    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
//    [navBar setTitleTextAttributes:attrs];
    
    navBar.tintColor = [UIColor whiteColor];
    
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
    if (viewController.navigationItem.leftBarButtonItem ==nil && self.viewControllers.count >1) {
        
        UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
        buttonBack.frame = CGRectMake(0, 0, 18, 14);
        [buttonBack addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
        [buttonBack setTitle:nil forState:UIControlStateNormal];
        [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
        buttonBack.backgroundColor = [UIColor clearColor];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        viewController.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
    }
}

-(void)buttonBackSetting
{
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
