//
//  QDXTicketSuccessViewController.m
//  趣定向
//
//  Created by Air on 2016/12/7.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXTicketSuccessViewController.h"
#import "QDXNavigationController.h"
#import "QDXGameViewController.h"
#import "QDXProtocolViewController.h"

@interface QDXTicketSuccessViewController ()

@property (nonatomic,strong) QDXStateView *successView;

@end

@implementation QDXTicketSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"使用成功";
    
    self.view.backgroundColor = QDXBGColor;
    
//    [self creatButtonBack];
    
    _successView = [[QDXStateView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    _successView.delegate = self;
    _successView.stateImg.image = [UIImage imageNamed:@"order_success"];
    _successView.stateDetail.text = @"活动票使用成功";
    [_successView.stateButton setTitle:@"参加活动" forState:UIControlStateNormal];
    [self.view addSubview:_successView];
}

// 返回按钮
- (void)creatButtonBack
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 20, 18);
    [buttonBack addTarget:self action:@selector(buttonBackSetting) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)buttonBackSetting
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)changeState
{
    NSString *isHave = [NSKeyedUnarchiver unarchiveObjectWithFile:QDXMyLineFile];
    if (isHave) {
        QDXGameViewController *game = [[QDXGameViewController alloc] init];
        [self.navigationController pushViewController:game animated:YES];
        
//        QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:game];
//        [self presentViewController:nav animated:YES completion:^{
//            
//        }];
    }else{
        QDXProtocolViewController *viewController = [[QDXProtocolViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
//        QDXNavigationController *nav = [[QDXNavigationController alloc] initWithRootViewController:viewController];
//        [self presentViewController:nav animated:YES completion:^{
//            
//        }];
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
