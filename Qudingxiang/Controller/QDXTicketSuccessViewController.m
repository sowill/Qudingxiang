//
//  QDXTicketSuccessViewController.m
//  趣定向
//
//  Created by Air on 2016/12/7.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXTicketSuccessViewController.h"
#import "BaseGameViewController.h"
#import "QDXProtocolViewController.h"

@interface QDXTicketSuccessViewController ()

@property (nonatomic,strong) QDXStateView *successView;

@end

@implementation QDXTicketSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"使用成功";
    
    _successView = [[QDXStateView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    _successView.delegate = self;
    _successView.stateImg.image = [UIImage imageNamed:@"order_success"];
    _successView.stateDetail.text = @"活动票使用成功";
    [_successView.stateButton setTitle:@"参加活动" forState:UIControlStateNormal];
    [self.view addSubview:_successView];
}


-(void)changeState
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
            if ([mylineid length] == 0) {
                QDXProtocolViewController *portocolVC = [[QDXProtocolViewController alloc] init];
                portocolVC.myline_id = responseObject[@"Msg"];
                [self.navigationController pushViewController:portocolVC animated:YES];
            }else{
                BaseGameViewController *game = [[BaseGameViewController alloc] init];
                game.myline_id = responseObject[@"Msg"];
                [self.navigationController pushViewController:game animated:YES];
            }
        }
    } failure:^(NSError *error) {
        
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
