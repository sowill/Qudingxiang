//
//  HelpViewController.m
//  趣定向
//
//  Created by Mac on 16/6/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
{
    UIWebView *protocol;
}
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"帮助";
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    protocol = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-15)];
    protocol.backgroundColor = [UIColor clearColor];
    protocol.scrollView.showsVerticalScrollIndicator = FALSE;
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/help/index.html"];
    [protocol loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.view addSubview:protocol];
}

-(void)setupProtocol
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/help/index.html"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        //[protocol loadHTMLString:infoDict[@"Msg"] baseURL:nil];
        [protocol loadRequest:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
