//
//  BaseViewController.m
//  趣定向
//
//  Created by Prince on 16/3/14.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "BaseViewController.h"
#import "FeHourGlass.h"

@interface BaseViewController ()
//@property MBProgressHUD *HUD;
@property (nonatomic ,strong) UIView *BGView; //遮罩
@property (strong, nonatomic) FeHourGlass *hourGlass;
@property BOOL isLoad;
@property UIView *vi_notData;
@end

@implementation BaseViewController
//@synthesize HUD =HUD;
@synthesize isLoad = isLoad;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isLoad = NO;
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
