//
//  APWebViewController.m
//  AliSDKDemo
//
//  Created by 亦澄 on 16-1-5.
//  Copyright (c) 2016年 Alipay. All rights reserved.
//

#import "APWebViewController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface APWebViewController ()

@property (nonatomic, strong)UIView* maskView;
@property (nonatomic, strong)UIView* urlInputView;
@property (nonatomic, strong)UITextField* urlInput;

@end


@implementation APWebViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.webView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;

    // 加载已经配置的url
    NSString* webUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"alipayweburl"];
    if (webUrl.length > 0) {
        [self loadWithUrlStr:webUrl];
    }
}


#pragma mark -
#pragma mark   ============== webview相关 回调及加载 ==============

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* orderInfo = [[AlipaySDK defaultService]fetchOrderInfoFromH5PayUrl:[request.URL absoluteString]];
    if (orderInfo.length > 0) {
        [self payWithUrlOrder:orderInfo];
        return NO;
    }
	return YES;
}

- (void)loadWithUrlStr:(NSString*)urlStr
{
    if (urlStr.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURLRequest *webRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                    timeoutInterval:30];
            [self.webView loadRequest:webRequest];
        });
    }
}


#pragma mark -
#pragma mark   ============== URL pay 开始支付 ==============

- (void)payWithUrlOrder:(NSString*)urlOrder
{
    if (urlOrder.length > 0) {
        __weak APWebViewController* wself = self;
        [[AlipaySDK defaultService]payUrlOrder:urlOrder fromScheme:@"alisdkdemo" callback:^(NSDictionary* result) {
            // 处理支付结果
//            NSLog(@"%@", result);
            // isProcessUrlPay 代表 支付宝已经处理该URL
            if ([result[@"isProcessUrlPay"] boolValue]) {
                // returnUrl 代表 第三方App需要跳转的成功页URL
                NSString* urlStr = result[@"returnUrl"];
                [wself loadWithUrlStr:urlStr];
            }
        }];
    }
}


#pragma mark -
#pragma mark   ============== url 输入界面及响应==============

- (IBAction)onOpenUrlInput:(id)sender
{
    if (self.maskView == nil) {
        self.maskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        self.maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    }
    
    if (self.urlInputView == nil) {
        self.urlInputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 105)];
        self.urlInputView.backgroundColor = [UIColor lightGrayColor];
        self.urlInputView.layer.cornerRadius = 8.0f;
        self.urlInputView.layer.masksToBounds = YES;
        
        self.urlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, 15, 280, 30)];
        self.urlInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.urlInput.autocorrectionType = UITextAutocorrectionTypeNo;
        self.urlInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.urlInput.backgroundColor = [UIColor whiteColor];
        self.urlInput.layer.cornerRadius = 4.0f;
        self.urlInput.layer.masksToBounds = YES;
        [self.urlInputView addSubview:self.urlInput];
        
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(230, 60, 60, 30)];
        btn.backgroundColor = [UIColor grayColor];
        btn.layer.cornerRadius = 4.0f;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor blueColor].CGColor;
        btn.layer.borderWidth = 2.0f;
        
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn setTitle:@"Go" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onOpenInputedUrl:) forControlEvents:UIControlEventTouchUpInside];
        [self.urlInputView addSubview:btn];
    }
    
    NSString* webUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"alipayweburl"];
    self.urlInput.text = webUrl;
    
    UIWindow* keyWnd = [UIApplication sharedApplication].keyWindow;
    if (keyWnd) {
        if (self.maskView.superview) {
            [self.maskView removeFromSuperview];
        }
        [keyWnd addSubview:self.maskView];
        
        if (self.urlInputView.superview) {
            [self.urlInputView removeFromSuperview];
        }
        [keyWnd addSubview:self.urlInputView];
        self.urlInputView.center = keyWnd.center;
        CGRect frame = self.urlInputView.frame;
        frame.origin.y = 84;
        self.urlInputView.frame = frame;
    }
}

- (IBAction)onOpenInputedUrl:(id)sender
{
    if (self.urlInputView.superview) {
        [self.urlInputView removeFromSuperview];
    }
    
    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
    }
    
    NSString* urlStr = self.urlInput.text;
    if (urlStr.length > 0) {
        if (![urlStr hasPrefix:@"http"]) {
            urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
        }
        [[NSUserDefaults standardUserDefaults] setObject:urlStr forKey:@"alipayweburl"];
        [self loadWithUrlStr:urlStr];
    }
}

@end
