//
//  QDXProtocolViewController.m
//  Qudingxiang
//
//  Created by Air on 15/10/14.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "QDXProtocolViewController.h"
#import "HomeController.h"
#import "QDXGameViewController.h"
#import "QDXNavigationController.h"

@interface QDXProtocolViewController ()
{
    UIWebView *protocol;
}
@end

@implementation QDXProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupFrame];
    [self setupCurrentLine];
    [self setupProtocol];
    
//    [self createButtonBack];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti3) name:@"noti3" object:nil];
}

-(void)reloadData
{
    [self setupCurrentLine];
}

-(void)noti3
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)setupFrame
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    self.navigationItem.title = @"协议";
    
    protocol = [[UIWebView alloc] initWithFrame:CGRectMake(0, 10, QdxWidth, QdxHeight - 200)];
//    protocol.editable = NO;
//    protocol.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    protocol.font = [UIFont fontWithName:@"Arial" size:15.0f];
//    protocol.textColor = [UIColor blackColor];
    protocol.backgroundColor = [UIColor clearColor];
    protocol.scrollView.showsVerticalScrollIndicator = FALSE;
    [self.view addSubview:protocol];
    
    CGFloat MaxProtocolY = QdxHeight - 40 - 10 - 64;
    
    UIButton *accept = [[UIButton alloc] initWithFrame:CGRectMake(10 + (QdxWidth - 20)/2 - 5 + 5, MaxProtocolY, (QdxWidth - 20)/2 - 5, 40)];
    [accept setBackgroundColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000]];
    [accept setTitle:@"同意" forState:UIControlStateNormal];
    [accept addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accept];
    
    UIButton *decline = [[UIButton alloc] initWithFrame:CGRectMake(10, MaxProtocolY, (QdxWidth - 20)/2 - 5, 40)];
    [decline setBackgroundColor:[UIColor clearColor]];
    decline.layer.borderWidth = 1;
    decline.layer.borderColor = [[UIColor colorWithWhite:0.400 alpha:1.000]CGColor];
    [decline setTitleColor:[UIColor colorWithWhite:0.400 alpha:1.000] forState:UIControlStateNormal];
    [decline setTitle:@"拒绝" forState:UIControlStateNormal];
    [decline addTarget:self action:@selector(decline) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:decline];
}

-(void)decline
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti2" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)accept
{
    QDXGameViewController *game = [[QDXGameViewController alloc] init];
    [self.navigationController pushViewController:game animated:YES];
    [NSKeyedArchiver archiveRootObject:@"Yes" toFile:QDXMyLineFile];
}

//获取myline_id
-(void)setupCurrentLine
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"Home/Myline/getCurrentLine"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            [NSKeyedArchiver archiveRootObject:infoDict[@"Msg"][@"myline_id"] toFile:QDXCurrentMyLineFile];
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setupProtocol
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Util/portocol"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        [protocol loadHTMLString:infoDict[@"Msg"] baseURL:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

// 返回按钮
-(void)createButtonBack
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBack.frame = CGRectMake(0, 0, 18, 14);
    [buttonBack addTarget:self action:@selector(backto) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setTitle:nil forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"sign_return"] forState:UIControlStateNormal];
    buttonBack.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)backto
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti2" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)dealloc

{
    
    //移除观察者，Observer不能为nil
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
