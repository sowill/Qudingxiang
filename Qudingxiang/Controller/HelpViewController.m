//
//  HelpViewController.m
//  趣定向
//
//  Created by Mac on 16/6/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "HelpViewController.h"
#import <WebKit/WebKit.h>

@interface HelpViewController ()<WKScriptMessageHandler>

@property (nonatomic, retain) WKWebView* protocol;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"帮助";
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.mediaPlaybackRequiresUserAction = NO;
    config.allowsInlineMediaPlayback = YES;
    _protocol = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-15) configuration:config];
    NSString *url = [newHostUrl stringByAppendingString:helpUrl];
    [_protocol loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    WKUserContentController *userCC = config.userContentController;
    //JS调用OC 添加处理脚本
    [userCC addScriptMessageHandler:self name:@"Success"];
    
    [self.view addSubview:_protocol];

}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //    NSLog(@"%@",NSStringFromSelector(_cmd));
    //    NSLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"Success"]) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
