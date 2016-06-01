//
//  QDXTaskViewController.m
//  趣定向
//
//  Created by Air on 16/5/4.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXTaskViewController.h"
#import "QDXGameModel.h"
#import "LineModel.h"

#define TASKWEIGHT          QdxWidth * 0.875
#define TASKHEIGHT          QdxHeight * 0.73
#define SHOWTASKHEIGHT      TASKHEIGHT * 0.1

@interface QDXTaskViewController ()
{
    UIButton *showMsg_button;
    UIImageView *successView;
    UIButton *showOK_button;
    UIButton *showTitle_button;
    UIButton *cancel_button;
    UIWebView *webView;
}
@property (nonatomic ,strong) UIView *BGView; //遮罩
@property (nonatomic ,strong) UIView *deliverView; //底部View
@end

@implementation QDXTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.BGView                 = [[UIView alloc] init];
    self.BGView.frame           = [[UIScreen mainScreen] bounds];
    self.BGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:self.BGView];
    self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    
    self.deliverView                 = [[UIView alloc] init];
    self.deliverView.frame           = CGRectMake(QdxWidth/2 - TASKWEIGHT/2,(QdxHeight-64 - TASKHEIGHT)/2,TASKWEIGHT,TASKHEIGHT);
    self.deliverView.backgroundColor = [UIColor whiteColor];
    self.deliverView.layer.borderWidth = 1;
    self.deliverView.layer.cornerRadius = 12;
    self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
    [self.view addSubview:self.deliverView];
    
    successView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TASKWEIGHT, TASKHEIGHT - SHOWTASKHEIGHT)];
    successView.image = [UIImage imageNamed:@"任务卡－闯关成功"];
    [self.deliverView addSubview:successView];
    
    showMsg_button = [[UIButton alloc] initWithFrame:CGRectMake(0, TASKHEIGHT - SHOWTASKHEIGHT,TASKWEIGHT, SHOWTASKHEIGHT)];
    [showMsg_button addTarget:self action:@selector(showMsg_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [showMsg_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－查看提示"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [showMsg_button setTitle:@"查看提示" forState:UIControlStateNormal];
    [self.deliverView addSubview:showMsg_button];
}

-(void)showMsg_buttonClick
{
    [showMsg_button removeFromSuperview];
    [successView removeFromSuperview];
    
    showOK_button = [[UIButton alloc] initWithFrame:CGRectMake(0, TASKHEIGHT - SHOWTASKHEIGHT,TASKWEIGHT, SHOWTASKHEIGHT)];
    [showOK_button addTarget:self action:@selector(showOK_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25; // 底端盖高度
    CGFloat left = 5; // 左端盖宽度
    CGFloat right = 5; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    [showOK_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [showOK_button setTitle:@"好的" forState:UIControlStateNormal];
    [showOK_button setTitleColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000] forState:UIControlStateNormal];
    [self.deliverView addSubview:showOK_button];
    
    showTitle_button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,TASKWEIGHT, SHOWTASKHEIGHT)];
    showTitle_button.userInteractionEnabled = NO;
    [showTitle_button setBackgroundImage:[[UIImage imageNamed:@"任务卡－按钮上面"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [showTitle_button setTitle:self.GameInfo.line.line_sub forState:UIControlStateNormal];
    [showTitle_button setTitleColor:[UIColor colorWithWhite:0.067 alpha:1.000] forState:UIControlStateNormal];
    showTitle_button.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.deliverView addSubview:showTitle_button];
    
    cancel_button = [[UIButton alloc] initWithFrame:CGRectMake(TASKWEIGHT - 30, 15,15, 15)];
    [cancel_button addTarget:self action:@selector(cancel_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [cancel_button setBackgroundImage:[UIImage imageNamed:@"任务卡－取消"]  forState:UIControlStateNormal];
    [self.deliverView addSubview:cancel_button];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,SHOWTASKHEIGHT, TASKWEIGHT, TASKHEIGHT - 2 * SHOWTASKHEIGHT)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.qudingxiang.cn/home/myline/mylineweb/myline_id/%@/tmp/%@",self.GameInfo.myline_id,save]]]];
    [self.deliverView addSubview:webView];
}

-(void)showOK_buttonClick
{
//    [webView reload];
    [self removeFromSuperViewController];
}

-(void)cancel_buttonClick
{
    [self removeFromSuperViewController];
}

-(void)removeFromSuperViewController
{
    [self didMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
