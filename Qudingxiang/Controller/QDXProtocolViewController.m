//
//  QDXProtocolViewController.m
//  Qudingxiang
//
//  Created by Air on 15/10/14.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "QDXProtocolViewController.h"

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
    [self setupProtocol];
}

-(void)reloadData
{
    [self setupProtocol];
}

-(void)setupFrame
{
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
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.declineBlock) {
            self.declineBlock();
        }
    }];
}

-(void)accept
{
    [self getMyline];
}

-(void)getMyline
{
    NSString *url = [newHostUrl stringByAppendingString:getMylineUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        if ([responseObject[@"Code"] intValue] == 0) {
            UIAlertController *aalert = [UIAlertController alertControllerWithTitle:@"提示" message:responseObject[@"Msg"]preferredStyle:UIAlertControllerStyleAlert];
            [aalert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction*action) {
                
            }]];
            [self presentViewController:aalert animated:YES completion:nil];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    } failure:^(NSError *error) {
        
    }];
}


-(void)setupProtocol{
    NSString *url = [newHostUrl stringByAppendingString:protocolUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        
        if ([responseObject[@"Code"] intValue] == 0) {
            
        }else{
            [protocol loadHTMLString:responseObject[@"Msg"] baseURL:nil];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
