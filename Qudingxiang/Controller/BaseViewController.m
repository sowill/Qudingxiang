//
//  BaseViewController.m
//  趣定向
//
//  Created by Prince on 16/3/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "BaseViewController.h"
#import "FeHourGlass.h"
#import "SGNetObserver.h"

@interface BaseViewController ()

@property (nonatomic ,strong) UIView *BGView; //遮罩
@property (strong, nonatomic) FeHourGlass *hourGlass;
@property BOOL isLoad;
@property UIView *vi_notData;

@property (nonatomic,strong) SGNetObserver *observer;
@end

@implementation BaseViewController

@synthesize isLoad = isLoad;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isLoad = NO;
    
    self.observer = [SGNetObserver defultObsever];
    [self.observer startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:SGReachabilityChangedNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SGReachabilityChangedNotification object:nil];
}

- (void)networkStatusChanged:(NSNotification *)notify{
//    NSLog(@"notify-------%@",notify.userInfo[@"status"]);

    if ([notify.userInfo[@"status"] intValue] == 0) {
        [self showNoNetworkView];
    }else{
        // 有网移除所有无网展位图
        for (QDXNoNetWorkView *view in self.view.subviews) {
            if ([view isMemberOfClass:[QDXNoNetWorkView class]]) {
                [view removeFromSuperview];
            }
        }
    }
}

-(void)reloadData
{
    
}

/** 显示无网络view */
- (void)showNoNetworkView{
    // 将导航栏和tabbar留出来
    QDXNoNetWorkView *noNetworkView = [[QDXNoNetWorkView alloc]initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    noNetworkView.delegate = self;
    [self.view addSubview:noNetworkView];
}

- (void)showProgessMsg:(NSString *)msg
{
    if (isLoad) {
        return;
    }
    isLoad =YES;

    self.BGView                 = [[UIView alloc] init];
    self.BGView.frame           = [[UIScreen mainScreen] bounds];
    [self.view addSubview:self.BGView];
    _hourGlass = [[FeHourGlass alloc] initWithView:self.BGView];
    [self.BGView addSubview:_hourGlass];
    [_hourGlass show];
}

- (void)hideProgess
{
    [self.BGView removeFromSuperview];
    [_hourGlass dismiss];
    isLoad = NO;
}

- (void)showProgessOK:(NSString *)msg
{
    [self.BGView removeFromSuperview];
    [_hourGlass dismiss];
    isLoad = NO;
}

- (void)showProgessError:(NSString *)msg
{
    [self.BGView removeFromSuperview];
    [_hourGlass dismiss];
    isLoad = NO;
}

- (void)hideNotData
{
    _vi_notData.hidden =YES;
}

- (void)showNotData:(NSString *)msg
{
    isLoad = NO;
    
    _vi_notData =[[UIView alloc] init];
    _vi_notData.frame =CGRectMake(0,74,QdxWidth,QdxWidth*2);
    
    NSString *sg =@"无相关数据";
    if ( msg!= nil){
        sg = msg;
    }
    UILabel *lb = [[UILabel alloc] init];
    [lb setTextAlignment:NSTextAlignmentCenter];
    lb.text = sg;
    [lb setFont:[UIFont systemFontOfSize:14]];
    [lb setTextColor:QDXGray];
    [lb setFrame:CGRectMake(0,QdxHeight/2-140,QdxWidth, 44)];
    [_vi_notData addSubview:lb];
    UIImageView *vi = [[UIImageView alloc] init];
    vi.image = [UIImage imageNamed:@"notdata.png"];
    [vi setFrame:CGRectMake((QdxWidth-44)/2,QdxHeight/2-200,44, 60)];
    [_vi_notData addSubview:vi];
    [self.view addSubview:_vi_notData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
