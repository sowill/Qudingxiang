//
//  OrderController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "OrderController.h"
#import "XBTestTableViewController.h"

#import "MCLeftSliderManager.h"

@interface OrderController ()

@end

@implementation OrderController

//重载init方法
- (instancetype)init
{
    if (self = [super initWithTagViewHeight:FitRealValue(80)])
    {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"订单";
    
    self.view.backgroundColor = QDXBGColor;

    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置自定义属性
    self.tagItemSize = CGSizeMake(QdxWidth/4, FitRealValue(80));
    self.selectedTitleColor = QDXBlue;
    self.selectedTitleFont = [UIFont systemFontOfSize:14];
    self.selectedIndicatorColor = QDXBlue;
    self.selectedIndicatorSize = CGSizeMake(QdxWidth/4, FitRealValue(4));
    self.normalTitleColor = QDXBlack;
    self.normalTitleFont = [UIFont systemFontOfSize:14];
//    self.graceTime = 15;
//    self.gapAnimated = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    NSArray *titleArray = @[
                            @"全部订单",
                            @"待支付",
                            @"已支付",
                            @"已完成"
                            ];
    NSArray *classNames = @[
                            [XBTestTableViewController class],
                            [XBTestTableViewController class],
                            [XBTestTableViewController class],
                            [XBTestTableViewController class]
                            ];
    NSArray *params = @[
                        @"0",
                        @"1",
                        @"2",
                        @"3"
                        ];
     [self reloadDataWith:titleArray andSubViewdisplayClasses:classNames withParams:params];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectTagByIndex:0 animated:YES];
}

- (void) openOrCloseLeftList
{
    if ([MCLeftSliderManager sharedInstance].LeftSlideVC.closed)
    {
        [[MCLeftSliderManager sharedInstance].LeftSlideVC openLeftView];
    }
    else
    {
        [[MCLeftSliderManager sharedInstance].LeftSlideVC closeLeftView];
    }
}

@end
