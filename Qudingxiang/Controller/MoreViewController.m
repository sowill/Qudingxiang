//
//  MoreViewController.m
//  趣定向
//
//  Created by Prince on 16/4/1.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MoreViewController.h"
#import "QDXNavigationController.h"
#import "QDXLoginViewController.h"
@interface MoreViewController ()<UIAlertViewDelegate>
{
    UIButton *_button;
}
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"社区";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
    
    
}

- (void)createUI
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth/2-28, QdxHeight/5, 57, 68)];
    image.image = [UIImage imageNamed:@"程序员哥哥"];
    [self.view addSubview:image];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, QdxHeight/5+78, QdxWidth, 20)];
    label.text = @"程序员哥哥正在搭建社区模块";
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    [self.view addSubview:label];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, QdxHeight/5+108, QdxWidth, 20)];
    label1.text = @"敬请期待~~";
    label1.font = [UIFont systemFontOfSize:12];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    [self.view addSubview:label1];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_button setImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)setClick
{
    if(save == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
    }else{
        [self.sideMenuViewController presentLeftMenuViewController];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if(buttonIndex == 1){
        self.hidesBottomBarWhenPushed = YES;
        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end