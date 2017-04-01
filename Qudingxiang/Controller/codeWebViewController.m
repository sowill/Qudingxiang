//
//  codeWebViewController.m
//  趣定向
//
//  Created by Air on 2017/3/29.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "codeWebViewController.h"
#import <WebKit/WebKit.h>

@interface codeWebViewController ()

@property (nonatomic, strong) WKWebView *wkwebView;

@end

@implementation codeWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _wkwebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [_wkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    [self.view addSubview:_wkwebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
