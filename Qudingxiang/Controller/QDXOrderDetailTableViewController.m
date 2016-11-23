//
//  QDXOrderDetailTableViewController.m
//  趣定向
//
//  Created by Air on 16/1/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXOrderDetailTableViewController.h"
#import "QDXOrderInfoModel.h"
#import "QDXOrdermodel.h"
#import "QDXTicketInfoModel.h"
#import "QDXostatus.h"
#import "QDXpaytype.h"
#import "QDXTicketTableViewCell.h"
#import "QDXPayTableViewController.h"
#import "StartModel.h"
#import "HomeService.h"

@interface QDXOrderDetailTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *pay;
    UIButton *cost;
    UIButton *complete;
    UILabel *sum_cost;
    UIView *bottom;
//    int _code;
    int _line;
}
@property (nonatomic, strong) NSMutableArray *ticket;
@property (nonatomic, strong) NSMutableArray *orderInfo;
@property (nonatomic, strong) UITableView *tableview;
@end

@implementation QDXOrderDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    self.title = @"订单详情";
    [self createTableView];
}

- (void)state
{
    HomeService *http = [HomeService sharedInstance];
    [http statesucceed:^(id data) {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
        _line = [[NSString stringWithFormat:@"%@",dict[@"Code"]] intValue];
    } failure:^(NSError *error) {
        
    } WithToken:save];
//    [HomeService choiceLineStateBlock:^(NSMutableDictionary *dict) {
//        _line = [[NSString stringWithFormat:@"%@",dict[@"Code"]] intValue];
//    } andWithToken:save];
}

- (void) viewWillAppear:(BOOL)animated
{
    [pay removeFromSuperview];
    [cost removeFromSuperview];
    [bottom removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self state];
    [self getOrdersListAjax];
}

-(void)createButtom
{
    bottom = [[UIView alloc] initWithFrame:CGRectMake(0, QdxHeight- 50-1-64, QdxWidth, 1)];
    bottom.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [self.view addSubview:bottom];
    // 添加底部按钮
    pay = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth/2, QdxHeight- 50-64, QdxWidth/2, 50)];
    [pay setTitle:@"去支付" forState:UIControlStateNormal];
    [pay setBackgroundColor:[UIColor colorWithRed:0.157 green:0.518 blue:0.980 alpha:1.000]];
    pay.titleLabel.font = [UIFont systemFontOfSize:14.0];
    pay.titleLabel.textAlignment = NSTextAlignmentCenter;
    [pay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pay setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [pay addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pay];
    
    cost = [[UIButton alloc] initWithFrame:CGRectMake(0, QdxHeight- 50-64, QdxWidth/2, 50)];
    [cost setBackgroundColor:[UIColor whiteColor]];
    cost.userInteractionEnabled = NO;
    [self.view addSubview:cost];
    UILabel *sum = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth/4 - 90/2 - 25/2, 50/2-25/2, 25, 25)];
    sum.text = @"总计";
    sum.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    sum.font = [UIFont systemFontOfSize:12];
    [cost addSubview:sum];
    sum_cost = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth/4 - 90/2 + 20, 50/2-40/2, 90, 40)];
    sum_cost.textColor = [UIColor colorWithRed:1.000 green:0.318 blue:0.000 alpha:1.000];
    sum_cost.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    [cost addSubview:sum_cost];
    
}

-(void)createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,10, QdxWidth, QdxHeight-64-60) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.rowHeight = 117;
    self.tableview.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableview];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 45)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, QdxWidth *  0.7 , 20)];
    if (self.orderId) {
        header.text = [@"订单号: " stringByAppendingString:self.ordersName];
    }else{
        header.text = [@"订单号: " stringByAppendingString:self.Order.Orders_name];
    }
    header.textColor = [UIColor colorWithWhite:0.067 alpha:1.000];
    header.font = [UIFont fontWithName:@"Arial" size:14];
    [headerView addSubview:header];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, QdxWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.000];
    [headerView addSubview:lineView];
    UILabel *headerStatus = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth - 55, 15, 45, 20)];
    
    if (self.orderId) {
        headerStatus.text = self.ostatusName;
    }else{
        headerStatus.text = self.Order.ostatus.ostatus_name;
    }
    headerStatus.textColor = [UIColor colorWithRed:1.000 green:0.318 blue:0.000 alpha:1.000];
    headerStatus.font = [UIFont fontWithName:@"Arial" size:15];
    [headerView addSubview:headerStatus];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 00)];
    }
}

-(void)createComplete
{
    complete = [[UIButton alloc] initWithFrame:CGRectMake(6, QdxHeight- 50*2 - 5, QdxWidth, 50)];
    [complete setTitle:@"温馨提示：二维码点击可放大" forState:UIControlStateNormal];
    complete.titleLabel.font = [UIFont systemFontOfSize:12];
    [complete setBackgroundColor:[UIColor colorWithWhite:0.949 alpha:1.000]];
    [complete setTitleColor:[UIColor colorWithWhite:0.400 alpha:1.000] forState:UIControlStateNormal];
    [self.view addSubview:complete];
}

- (void)createSadView
{
    UIImageView *sad = [[UIImageView alloc] init];
    CGFloat sadCenterX = QdxWidth * 0.5;
    CGFloat sadCenterY = QdxHeight * 0.22;
    sad.center = CGPointMake(sadCenterX, sadCenterY);
    sad.bounds = CGRectMake(0, 0,40,43);
    sad.image = [UIImage imageNamed:@"order_nothing"];
    [self.view addSubview:sad];
    
    UILabel *sadButton = [[UILabel alloc] init];
    sadButton.center = CGPointMake(sadCenterX, sadCenterY + 43/2 + 20);
    sadButton.bounds = CGRectMake(0, 0, 120, 100);
    sadButton.text = @"您当前没有订单";
    sadButton.font = [UIFont systemFontOfSize:12];
    sadButton.textAlignment = NSTextAlignmentCenter;
    sadButton.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    [self.view addSubview:sadButton];
}

-(void)getOrdersListAjax
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    if (self.orderId) {
        params[@"Orders_id"] = self.orderId;
    }else{
        params[@"Orders_id"] = [NSString stringWithFormat:@"%d",self.Order.Orders_id];
    }
    NSString *url = [hostUrl stringByAppendingString:@"Home/Orders/getInfoAjax"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (dict) {
            NSMutableArray *orderInfoArray = [NSMutableArray array];
            NSDictionary *dataInfoDict = dict;
            [orderInfoArray addObject:[QDXOrdermodel OrderWithDict:dataInfoDict]];
            self.orderInfo = orderInfoArray;
            QDXOrdermodel *OrderInfo = self.orderInfo[0];
            if (OrderInfo.Orders_st == 1) {
                [self createButtom];
                sum_cost.text = [@"￥" stringByAppendingString: OrderInfo.Orders_am];
            }else if (OrderInfo.Orders_st == 2){
                [self createComplete];
            }
            NSMutableArray *ticketArray = [NSMutableArray array];
            NSArray *dataDict = dict[@"ticketinfo"];
            if (![dataDict isEqual:[NSNull null]]) {
                for(NSDictionary *dict in dataDict){
                    [ticketArray addObject:[QDXTicketInfoModel TicketInfoWithDict:dict]];
                }
                self.ticket = ticketArray;
            }
        }else
        {
            [self createSadView];
        }
        [self.tableview reloadData];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ticket.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    QDXTicketTableViewCell *cell = [QDXTicketTableViewCell cellWithTableView:tableView];
    
    // 2.给cell传递模型数据
    cell.TicketInfo = self.ticket[indexPath.row];
//    if(_code == 1){
//        cell.deleteButton.userInteractionEnabled = NO;
//        [cell.deleteButton setBackgroundImage:[UIImage imageNamed:@"按钮2"] forState:UIControlStateNormal];
//        cell.deleteButton.titleLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
//        [cell.deleteButton setTitleColor:[UIColor colorWithWhite:0.400 alpha:1.000] forState:UIControlStateNormal];
//        [cell.deleteButton setTitle:@"已使用" forState:UIControlStateNormal];
//    }else{
//        
//    }
    cell.btnBlock = ^(){
        NSLog(@"%ld",(long)indexPath.row);
        QDXTicketInfoModel *ticketInfo = self.ticket[indexPath.row];
        QDXOrdermodel *OrderInfo = self.orderInfo[0];
        if (OrderInfo.Orders_st == 2 && ![ticketInfo.tstatus_name isEqualToString:@"已使用"]) {
            NSString *message = @"是否使用当前活动券";
            if(_line == 1){
                message = @"您已在活动中";
            }
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"使用" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                [self bindSelf:ticketInfo.ticketinfo_name];
                [self.ticket removeObjectAtIndex:indexPath.row];
                [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                [self.tableview reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stateRefresh" object:nil];
                [self state];
            }];
            [alertController addAction:cancelAction];
            if(_line != 1){
                [alertController addAction:okAction];
            }
            [self presentViewController:alertController animated:YES completion:nil];

        }else if (OrderInfo.Orders_st == 1){
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除" message:@"是否删除当前活动券" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                [self deleteTicket:ticketInfo.ticket_id];
                [self.ticket removeObjectAtIndex:indexPath.row];
                [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                [self.tableview reloadData];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else{
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加" message:@"是否添加当前活动券" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                [self addTicket:ticketInfo.ticket_id];
                [self.ticket removeObjectAtIndex:indexPath.row];
                [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                [self.tableview reloadData];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
    };
    return cell;
}

-(void)dealloc

{
    //移除观察者，Observer不能为nil
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getOrders
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    if (self.orderId) {
        params[@"Orders_id"] = self.orderId;
    }else{
        params[@"Orders_id"] = [NSString stringWithFormat:@"%d",self.Order.Orders_id];
    }
    NSString *url = [hostUrl stringByAppendingString:@"Home/Orders/getInfoAjax"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (dict) {
            NSMutableArray *orderInfoArray = [NSMutableArray array];
            NSDictionary *dataInfoDict = dict;
            [orderInfoArray addObject:[QDXOrdermodel OrderWithDict:dataInfoDict]];
            self.orderInfo = orderInfoArray;
            NSMutableArray *ticketArray = [NSMutableArray array];
            NSArray *dataDict = dict[@"ticketinfo"];
            if (![dataDict isEqual:[NSNull null]]) {
                for(NSDictionary *dict in dataDict){
                    [ticketArray addObject:[QDXTicketInfoModel TicketInfoWithDict:dict]];
                }
                self.ticket = ticketArray;
            }
            [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
        }else
        {
            [self showProgessOK:@"加载失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)pay
{
    [self showProgessMsg:@"正在加载"];
    [self performSelectorInBackground:@selector(getOrders) withObject:nil];
}

-(void)sussRes
{
    QDXPayTableViewController *payVC=[[QDXPayTableViewController alloc]init];
    payVC.Order = self.orderInfo[0];
    payVC.ticketInfo = self.ticket[0];
    [self.navigationController pushViewController:payVC animated:YES];
    [self showProgessOK:@"加载成功"];
}

- (void)bindSelf:(NSString *)withTID
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"ticketinfo_name"] = withTID;
    NSString *url = [NSString stringWithFormat:@"%@%@",hostUrl,actUrl];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        StartModel *model = [[StartModel alloc] init];
        [model setCode:dict[@"Code"] ];
        [model setMsg:dict[@"Msg"]];
        int temp = [model.Code intValue];
        if (temp == 1) {
            [MBProgressHUD showSuccess:@"成功绑定!"];
        }else{
            [MBProgressHUD showError:dict[@"Msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)addTicket:(NSString *)withTID
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"goods_id"] =withTID;
    params[@"add"] = @"1";
    NSString *url = [hostUrl stringByAppendingString:@"Home/Orders/addOrders"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dict[@"Code"] intValue] == 1) {
            [MBProgressHUD showSuccess:@"请返回上一页面进行支付"];
        }else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)deleteTicket:(NSString *)withTID
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"goods_id"] =withTID;
    params[@"add"] = @"2";
    NSString *url = [hostUrl stringByAppendingString:@"Home/Orders/addOrders"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dict[@"Code"] intValue] == 1) {
            sum_cost.text = [@"￥" stringByAppendingString:dict[@"Msg"][@"Orders_am"]];
        }else{
            sum_cost.text = [@"￥" stringByAppendingString:@"0"];
            [pay setTitle:@"不能付" forState:UIControlStateNormal];
            [pay setBackgroundColor:[UIColor grayColor]];
            [pay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            pay.userInteractionEnabled = NO;
            self.orderId = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

@end
