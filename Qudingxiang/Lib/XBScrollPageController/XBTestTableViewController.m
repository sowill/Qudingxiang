//
//  XBTestTableViewController.m
//  XBScrollPageControllerDemo
//
//  Created by Scarecrow on 15/9/8.
//  Copyright (c) 2015年 xiu8. All rights reserved.
//

#import "XBTestTableViewController.h"
#import "XBConst.h"

#import "OrdersList.h"
#import "Orders.h"

#import "QDXPayTableViewController.h"
#import "QDXOrderTableViewCell.h"
#import "QDXOrderDetailTableViewController.h"
#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"

@interface XBTestTableViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    int curr;
    int page;
    int count;
}
@property (nonatomic, strong) NSMutableArray *orders;

@property (nonatomic,strong) NSMutableArray *willPayOrders;

@property (nonatomic,strong) NSMutableArray *didPayOrders;

@property (nonatomic,strong) NSMutableArray *didCompleted;

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic,strong) QDXStateView *loginView;

@property (nonatomic,strong) QDXStateView *noThingView;

@end

@implementation XBTestTableViewController

- (NSMutableArray *)orders
{
    if (_orders == nil) {
        _orders = [NSMutableArray array];
    }
    return _orders;
}

- (NSMutableArray *)willPayOrders
{
    if (_willPayOrders == nil) {
        _willPayOrders = [NSMutableArray array];
    }
    return _willPayOrders;
}

- (NSMutableArray *)didPayOrders
{
    if (_didPayOrders == nil) {
        _didPayOrders = [NSMutableArray array];
    }
    return _didPayOrders;
}

- (NSMutableArray *)didCompleted
{
    if (_didCompleted == nil) {
        _didCompleted = [NSMutableArray array];
    }
    return _didCompleted;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    curr = 1;
//
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    curr = 1;
    [self getOrdersListAjax];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payRefresh) name:@"pay" object:nil];
}

-(void)payRefresh{
    curr = 1;
    [self getOrdersListAjax];
}

- (void)createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight - 49-64 - FitRealValue(80)) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.backgroundColor = QDXBGColor;
    //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:self.tableview];
    
    [self setupRefreshView];
}

-(void)reloadData
{
    [self getOrdersListAjax];
}

/**
 *  集成刷新控件
 */
- (void)setupRefreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
//    [self.tableview.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    self.tableview.mj_footer.ignoredScrollViewContentInsetBottom = 30;
    
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    curr = 1;
    [self getOrdersListAjax];
    
    // 刷新表格
    [self.tableview reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableview.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    curr++;
    if(curr > page ){
        // 刷新表格
        [self.tableview reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.tableview.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self getOrdersListAjax];
    }
}

-(void)getOrdersListAjax
{
    if(save == nil){
        [self createLoginView];
        return;
    }else{
        self.orders = [NSMutableArray arrayWithCapacity:0];
        self.willPayOrders = [NSMutableArray arrayWithCapacity:0];
        self.didPayOrders = [NSMutableArray arrayWithCapacity:0];
        self.didCompleted = [NSMutableArray arrayWithCapacity:0];
        NSString *url = [newHostUrl stringByAppendingString:getOrdersListUrl];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"customer_token"] = save;
        [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {

            OrdersList *ordersList = [[OrdersList alloc] initWithDic:responseObject];
            curr = [ordersList.curr intValue];
            page = [ordersList.allpage intValue];
            for (Orders *orders in ordersList.ordersArray) {
                [self.orders addObject:orders];
                switch ([orders.ordersst_id intValue]) {
                    case 1:
                        [self.willPayOrders addObject:orders];
                        break;
                        
                    case 2:
                        [self.didPayOrders addObject:orders];
                        break;
                        
                    case 3:
                        [self.didCompleted addObject:orders];
                        break;
                        
                    default:
                        break;
                }
            }
            
            if (self.didCompleted.count == 0 && [_XBParam intValue] == 3) {
                [self.tableview removeFromSuperview];
                [self createSadViewWithDetail: @"您暂时还没有已完成的订单哦~"];
            }else if (self.didPayOrders.count == 0 && [_XBParam intValue] == 2){
                [self.tableview removeFromSuperview];
                [self createSadViewWithDetail: @"您暂时还没有已支付的订单哦~"];
            }else if (self.willPayOrders.count == 0 && [_XBParam intValue] == 1){
                [self.tableview removeFromSuperview];
                [self createSadViewWithDetail: @"您暂时还没有待支付的订单哦~"];
            }else if (self.orders.count == 0 && [_XBParam intValue] == 0){
                [self.tableview removeFromSuperview];
                [self createSadViewWithDetail: @"您暂时还没有订单哦~"];
            }else{
                [_loginView removeFromSuperview];
                [_noThingView removeFromSuperview];
                [self createTableView];
            }
            
            [self.tableview.mj_footer endRefreshing];
            // 刷新表格
            [self.tableview reloadData];
            
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)setXBParam:(NSString *)XBParam{
    _XBParam = XBParam;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pay" object:nil];
}

- (void)createLoginView
{
    _loginView = [[QDXStateView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    _loginView.tag = 1;
    _loginView.delegate = self;
    _loginView.stateImg.image = [UIImage imageNamed:@"order_login"];
    _loginView.stateDetail.text = @"您还没有登录，请登录后查看订单";
    [_loginView.stateButton setTitle:@"立即登录" forState:UIControlStateNormal];
    [self.view addSubview:_loginView];
}

-(void)changeState
{
    if (_loginView.tag == 1) {
        [self sign_in];
    }else{
        self.tabBarController.selectedIndex = 0;
    }
}

-(void)sign_in
{
    QDXLoginViewController *login=[[QDXLoginViewController alloc]init];
    login.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:login animated:YES];
}

- (void)createSadViewWithDetail :(NSString *)detail
{
    _noThingView = [[QDXStateView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight - 49)];
    _noThingView.tag = 2;
    _noThingView.delegate = self;
    _noThingView.stateImg.image = [UIImage imageNamed:@"order_nothing"];
    if ([detail length] == 0) {
        _noThingView.stateDetail.text = @"您暂时还没有订单哦~";
    }else{
        _noThingView.stateDetail.text = detail;
    }
    [_noThingView.stateButton setTitle:@"立即下单" forState:UIControlStateNormal];
    [self.view addSubview:_noThingView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch ([_XBParam intValue]) {
        case 0:
            return self.orders.count;
            break;
            
        case 1:
            return self.willPayOrders.count;
            break;
            
        case 2:
            return self.didPayOrders.count;
            break;
            
        case 3:
            return self.didCompleted.count;
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    QDXOrderTableViewCell *cell = [QDXOrderTableViewCell cellWithTableView:tableView];
    
    __weak __typeof(self) weakSelf = self;
    
    cell.deleteBtnBlock= ^(){
        __strong __typeof(self) strongSelf = weakSelf;

        Orders *order = [[Orders alloc] init];
        if ([_XBParam intValue] == 0) {
            order = strongSelf.orders[indexPath.row];
        }else if([_XBParam intValue] == 1){
            order = strongSelf.willPayOrders[indexPath.row];
        }else{
            order = strongSelf.orders[indexPath.row];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除" message:@"是否删除当前订单" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
            [self deleteOrder:order.orders_id];
            
            if ([_XBParam intValue] == 0) {
                [strongSelf.orders removeObjectAtIndex:indexPath.row];
            }else if([_XBParam intValue] == 1){
                [strongSelf.willPayOrders removeObjectAtIndex:indexPath.row];
            }else{
                [strongSelf.orders removeObjectAtIndex:indexPath.row];
            }

            [strongSelf.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            [strongSelf.tableview reloadData];
            
            [self getOrdersListAjax];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [strongSelf presentViewController:alertController animated:YES completion:nil];
    };
    
    cell.payBtnBlock= ^(){
        __strong __typeof(self) strongSelf = weakSelf;
        
        QDXPayTableViewController *payVC=[[QDXPayTableViewController alloc]init];
        payVC.Order = strongSelf.orders[indexPath.row];
        payVC.hidesBottomBarWhenPushed = YES;
        [strongSelf.navigationController pushViewController:payVC animated:YES];
    };
    
    // 2.给cell传递模型数据
    switch ([_XBParam intValue]) {
        case 0:
            cell.order = self.orders[indexPath.row];
            break;
            
        case 1:
            cell.order = self.willPayOrders[indexPath.row];
            break;
            
        case 2:
            cell.order = self.didPayOrders[indexPath.row];
            break;
            
        case 3:
            cell.order = self.didCompleted[indexPath.row];
            break;
            
        default:
            cell.order = self.orders[indexPath.row];
            break;
    }
    return cell;
}

- (void)deleteOrder:(NSString *)withOID{
    
    NSString *url = [newHostUrl stringByAppendingString:removeOrdersUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer_token"] = save;
    params[@"orders_id"] = withOID;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {

    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_XBParam intValue] == 0) {
        Orders *orderModel  = self.orders[indexPath.row];
        
        if ([orderModel.ordersst_id intValue] == 2 || [orderModel.ordersst_id intValue] == 3) {
            return FitRealValue(324 + 20);
        }else{
            return FitRealValue(412 + 20);
        }
    }else if([_XBParam intValue] == 1) {
        return FitRealValue(412 + 20);
    }else{
        return FitRealValue(324 + 20);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QDXOrderDetailTableViewController *ODetailVC = [[QDXOrderDetailTableViewController alloc] init];
    ODetailVC.hidesBottomBarWhenPushed = YES;
    
    switch ([_XBParam intValue]) {
        case 0:
            ODetailVC.orders = self.orders[indexPath.row];
            break;
            
        case 1:
            ODetailVC.orders = self.willPayOrders[indexPath.row];
            break;
            
        case 2:
            ODetailVC.orders = self.didPayOrders[indexPath.row];
            break;
            
        case 3:
            ODetailVC.orders = self.didCompleted[indexPath.row];
            break;
            
        default:
            ODetailVC.orders = self.orders[indexPath.row];
            break;
    }
    
    [self.navigationController pushViewController:ODetailVC animated:YES];
}

@end
