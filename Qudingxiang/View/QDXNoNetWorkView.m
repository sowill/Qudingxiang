//
//  QDXNoNetWorkView.m
//  趣定向
//
//  Created by Air on 2016/12/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXNoNetWorkView.h"
#import "Reachability.h"

@implementation QDXNoNetWorkView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // UI搭建
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
    self.backgroundColor = QDXBGColor;
    
    UIImageView *noNetWork = [[UIImageView alloc] init];
    CGFloat noNetWorkCenterX = QdxWidth * 0.5;
    CGFloat noNetWorkCenterY = QdxHeight * 0.22;
    noNetWork.center = CGPointMake(noNetWorkCenterX, noNetWorkCenterY);
    noNetWork.bounds = CGRectMake(0, 0, FitRealValue(276), FitRealValue(198));
    noNetWork.image = [UIImage imageNamed:@"wifi"];
    [self addSubview:noNetWork];
    
    UILabel *noNetWorkDetail = [[UILabel alloc] init];
    noNetWorkDetail.center = CGPointMake(noNetWorkCenterX, noNetWorkCenterY + FitRealValue(198/2 + 30/2 + 60));
    noNetWorkDetail.bounds = CGRectMake(0, 0, QdxWidth, FitRealValue(30));
    noNetWorkDetail.textColor = QDXGray;
    noNetWorkDetail.font = [UIFont systemFontOfSize:14];
    noNetWorkDetail.textAlignment = NSTextAlignmentCenter;
    noNetWorkDetail.text = @"您的网络好像不太给力，请稍后再试";
    [self addSubview:noNetWorkDetail];
    
    UIButton *noNetWorkButton = [[UIButton alloc] init];
    noNetWorkButton.center = CGPointMake(noNetWorkCenterX, noNetWorkCenterY + FitRealValue(198/2 + 30 + 60 + 60 + 60/2));
    noNetWorkButton.bounds = CGRectMake(0, 0, FitRealValue(200), FitRealValue(60));
    [noNetWorkButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [noNetWorkButton addTarget:self action:@selector(checkNetworkButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [noNetWorkButton setBackgroundImage:[ToolView createImageWithColor:QDXBlue] forState:UIControlStateNormal];
    [noNetWorkButton setBackgroundImage:[ToolView createImageWithColor:QDXDarkBlue] forState:UIControlStateHighlighted];
    noNetWorkButton.layer.borderWidth = 0.5;
    noNetWorkButton.layer.cornerRadius = 2;
    noNetWorkButton.layer.borderColor = [QDXBlue CGColor];
    [noNetWorkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    noNetWorkButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:noNetWorkButton];
}

/** 重新查看按钮点击 */
- (void)checkNetworkButtonClicked{
    if ([self isNetWorkRunning]) {
        // 如果有网，view消失，并且让代理方执行代理方法
        for (QDXNoNetWorkView *view in [self getCurrentViewController].view.subviews) {
            if ([view isMemberOfClass:[QDXNoNetWorkView class]]) {
                [view removeFromSuperview];
            }
        }
        
        // 重新加载数据
        if ([self.delegate respondsToSelector:@selector(reloadData)]) {
            [self.delegate reloadData];
        }
    }else{
        // 如果没网，toast提示
        [MBProgressHUD showError:@"请检查你的网络连接"];
    }
}

- (BOOL)isNetWorkRunning{
    BOOL isExistenceNetwork=YES;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.qudingxiang.cn"];//auto-view.cn/iphone
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=NO;
            break;
        case ReachableViaWWAN:
            //使用3G/GPRS网络
            isExistenceNetwork=YES;
            break;
        case ReachableViaWiFi:
            //使用WiFi网络
            isExistenceNetwork=YES;
            break;
    }
    return isExistenceNetwork;
}

/** 获取当前View的控制器对象 */
-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

@end
