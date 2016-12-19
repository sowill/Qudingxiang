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
#import "QDXTicketSuccessViewController.h"
#import "QDXNavigationController.h"

@interface QDXOrderDetailTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *pay;
    UIButton *cost;
    UIButton *complete;
    UILabel *sum_cost;
    UIView *bottom;
//    int _code;
    int _line;
    
    UIView *headerView;
}
@property (nonatomic, strong) NSMutableArray *ticket;
@property (nonatomic, strong) NSMutableArray *orderInfo;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic,strong) QDXStateView *noThingView;
@end

@implementation QDXOrderDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = QDXBGColor;
    self.title = @"订单详情";
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
    [super viewWillAppear:animated];
    [pay removeFromSuperview];
    [cost removeFromSuperview];
    [bottom removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self state];
    [self getOrdersListAjax];
}

-(void)createButtom
{
    bottom = [[UIView alloc] initWithFrame:CGRectMake(0, QdxHeight-64 - FitRealValue(110), QdxWidth, 0.5)];
    bottom.backgroundColor = QDXLineColor;
    [self.view addSubview:bottom];
    // 添加底部按钮
    pay = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth/2, QdxHeight- FitRealValue(110)-64, QdxWidth/2, FitRealValue(110))];
    [pay setTitle:@"去支付" forState:UIControlStateNormal];
    [pay setBackgroundImage:[ToolView createImageWithColor:QDXBlue] forState:UIControlStateNormal];
    [pay setBackgroundImage:[ToolView createImageWithColor:QDXDarkBlue] forState:UIControlStateHighlighted];
    pay.titleLabel.font = [UIFont systemFontOfSize:16.0];
    pay.titleLabel.textAlignment = NSTextAlignmentCenter;
    [pay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pay setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [pay addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pay];
    
    cost = [[UIButton alloc] initWithFrame:CGRectMake(0, QdxHeight- FitRealValue(110)-64, QdxWidth/2, FitRealValue(110))];
    [cost setBackgroundColor:[UIColor whiteColor]];
    cost.userInteractionEnabled = NO;
    [self.view addSubview:cost];
    UILabel *sum = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth/4 - 90/2 - 30/2, FitRealValue(110)/2-25/2, 30, 25)];
    sum.text = @"总计";
    sum.textColor = QDXGray;
    sum.font = [UIFont systemFontOfSize:14];
    [cost addSubview:sum];
    sum_cost = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth/4 - 90/2 + 20, FitRealValue(110)/2-40/2, 90, 40)];
    sum_cost.textColor = QDXOrange;
    sum_cost.font = [UIFont systemFontOfSize:20];
    [cost addSubview:sum_cost];
    
}

-(void)createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight - 64 - 50) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.rowHeight = 117;
    self.tableview.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableview];
}

-(void)setHeaderView
{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(220))];
    headerView.backgroundColor = QDXBGColor;
    
    UIView *headerContantView = [[UIView alloc] initWithFrame:CGRectMake(0, FitRealValue(20), QdxWidth, FitRealValue(200))];
    headerContantView.backgroundColor =[UIColor whiteColor];
    [headerView addSubview:headerContantView];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(30), FitRealValue(500) , FitRealValue(40))];
    if (self.orderId) {
        header.text = [@"订单号：" stringByAppendingString:self.ordersName];
    }else{
        header.text = [@"订单号：" stringByAppendingString:self.Order.Orders_name];
    }
    header.textColor = QDXBlack;
    header.textAlignment = NSTextAlignmentLeft;
    header.font = [UIFont fontWithName:@"Arial" size:17];
    [headerContantView addSubview:header];
    
    UILabel *headerStatus = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(24 + 200), FitRealValue(30), FitRealValue(200), FitRealValue(40))];
    if (self.orderId) {
        headerStatus.text = self.ostatusName;
    }else{
        headerStatus.text = self.Order.ostatus.ostatus_name;
    }
    headerStatus.textColor = QDXBlue;
    headerStatus.textAlignment = NSTextAlignmentRight;
    headerStatus.font = [UIFont fontWithName:@"Arial" size:17];
    [headerContantView addSubview:headerStatus];
    
    UILabel *headerTime = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(30 + 40 + 20), FitRealValue(500), FitRealValue(30))];
    if (self.orderId) {
        headerTime.text = [@"活动时间：" stringByAppendingString:@"2016.11.5"];
    }else{
        headerTime.text = [@"活动时间：" stringByAppendingString:@"2016.11.5"];
    }
    headerTime.textColor = QDXGray;
    headerTime.textAlignment = NSTextAlignmentLeft;
    headerTime.font = [UIFont fontWithName:@"Arial" size:14];
    [headerContantView addSubview:headerTime];
    
    UILabel *headerPlaceName = [[UILabel alloc] init];
    if (QdxWidth < 375) {
        headerPlaceName.frame = CGRectMake(FitRealValue(24), FitRealValue(30 + 40 + 20 + 30 + 20),FitRealValue(165),FitRealValue(30));
    }else{
        headerPlaceName.frame = CGRectMake(FitRealValue(24), FitRealValue(30 + 40 + 20 + 30 + 20),FitRealValue(140),FitRealValue(30));
    }
    headerPlaceName.textColor = QDXGray;
    headerPlaceName.textAlignment = NSTextAlignmentLeft;
    headerPlaceName.text = @"活动地点：";
    headerPlaceName.font = [UIFont fontWithName:@"Arial" size:14];
    [headerContantView addSubview:headerPlaceName];
    
    UILabel *headerPlace = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    headerPlace.textColor = QDXGray;
    headerPlace.numberOfLines = 0;
    headerPlace.lineBreakMode = NSLineBreakByWordWrapping;//换行方式
    headerPlace.textAlignment = NSTextAlignmentLeft;
    
    NSString *strPlace = @"上海市徐汇区斜土路2601弄嘉汇广场T2栋";
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:14];
    
    headerPlace.font = font;
    
    CGFloat headerPlaceNameX = CGRectGetMaxX(headerPlaceName.frame);
    
    CGSize size = CGSizeMake(QdxWidth - headerPlaceNameX -FitRealValue(24),CGFLOAT_MAX);//LableWight标签宽度，固定的
    //计算实际frame大小，并将label的frame变成实际大小
    
    CGSize labelsize = [strPlace sizeWithFont:font constrainedToSize:size lineBreakMode:headerPlace.lineBreakMode];
    headerPlace.frame = CGRectMake(headerPlaceNameX, FitRealValue(30 + 40 + 20 + 30 + 20), labelsize.width, labelsize.height);
    headerPlace.text = strPlace;
    [headerContantView addSubview:headerPlace];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(FitRealValue(24), FitRealValue(170) + labelsize.height, QdxWidth - FitRealValue(24 + 24), 0.5)];
    lineView.backgroundColor = QDXLineColor;
    [headerContantView addSubview:lineView];
    
    headerContantView.frame = CGRectMake(0, FitRealValue(20), QdxWidth, FitRealValue(170) + labelsize.height);
    headerView.frame = CGRectMake(0, 0, QdxWidth, FitRealValue(190) + labelsize.height);
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return headerView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return FitRealValue(200);
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FitRealValue(312);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == self.ticket.count - 1) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }else{
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, FitRealValue(24), 0, FitRealValue(24))];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, FitRealValue(24), 0, FitRealValue(24))];
        }
    }
}

-(void)createComplete
{
    complete = [[UIButton alloc] initWithFrame:CGRectMake(0, QdxHeight- FitRealValue(110)*2 - 5, QdxWidth, FitRealValue(110))];
    [complete setTitle:@"订单已完成支付，请尽快使用" forState:UIControlStateNormal];
    complete.titleLabel.font = [UIFont systemFontOfSize:14];
    [complete setBackgroundColor:QDXBGColor];
    [complete setTitleColor:QDXGray forState:UIControlStateNormal];
    [self.view addSubview:complete];
}

- (void)createSadView
{
    _noThingView = [[QDXStateView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    _noThingView.tag = 2;
    _noThingView.delegate = self;
    _noThingView.stateImg.image = [UIImage imageNamed:@"order_nothing"];
    _noThingView.stateDetail.text = @"您暂时还没有订单哦~";
    [_noThingView.stateButton setTitle:@"立即下单" forState:UIControlStateNormal];
    [self.view addSubview:_noThingView];
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
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Orders/getInfoAjax"];
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
            
            [self setHeaderView];
            
            [self createTableView];
        }else{
            [self createSadView];
        }
        [self.tableview setTableHeaderView:headerView];
        
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
    __weak __typeof(self) weakSelf = self;
    
    cell.btnBlock = ^(){
        
        __strong __typeof(self) strongSelf = weakSelf;
        
        QDXTicketInfoModel *ticketInfo = strongSelf.ticket[indexPath.row];
        QDXOrdermodel *OrderInfo = strongSelf.orderInfo[0];
        if (OrderInfo.Orders_st == 2 && ![ticketInfo.tstatus_name isEqualToString:@"已使用"]) {
            NSString *message = @"是否使用当前活动券";
            if(_line == 1){
                message = @"您已在活动中";
            }
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"使用" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                [strongSelf bindSelf:ticketInfo.ticketinfo_name];
                [strongSelf.ticket removeObjectAtIndex:indexPath.row];
                [strongSelf.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                [strongSelf.tableview reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stateRefresh" object:nil];
                [strongSelf state];
            }];
            [alertController addAction:cancelAction];
            if(_line != 1){
                [alertController addAction:okAction];
            }
            [strongSelf presentViewController:alertController animated:YES completion:nil];

        }else if (OrderInfo.Orders_st == 1){
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除" message:@"是否删除当前活动券" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                [strongSelf deleteTicket:ticketInfo.ticket_id];
                [strongSelf.ticket removeObjectAtIndex:indexPath.row];
                [strongSelf.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                [strongSelf.tableview reloadData];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [strongSelf presentViewController:alertController animated:YES completion:nil];
            
        }else{
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加" message:@"是否添加当前活动券" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                [strongSelf addTicket:ticketInfo.ticket_id];
                [strongSelf.ticket removeObjectAtIndex:indexPath.row];
                [strongSelf.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                [strongSelf.tableview reloadData];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [strongSelf presentViewController:alertController animated:YES completion:nil];
            
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
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Orders/getInfoAjax"];
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

        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)pay
{

    [self performSelectorInBackground:@selector(getOrders) withObject:nil];
}

-(void)sussRes
{
    QDXPayTableViewController *payVC=[[QDXPayTableViewController alloc]init];
    payVC.Order = self.orderInfo[0];
    payVC.ticketInfo = self.ticket[0];
    [self.navigationController pushViewController:payVC animated:YES];
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
            QDXTicketSuccessViewController *successView=[[QDXTicketSuccessViewController alloc]init];
            QDXNavigationController *navController = [[QDXNavigationController alloc] initWithRootViewController:successView];
            [self presentViewController:navController animated:YES completion:^{
                
            }];
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
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Orders/addOrders"];
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
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Orders/addOrders"];
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
