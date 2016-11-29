//
//  XBTestTableViewController.m
//  XBScrollPageControllerDemo
//
//  Created by Scarecrow on 15/9/8.
//  Copyright (c) 2015年 xiu8. All rights reserved.
//

#import "XBTestTableViewController.h"
#import "XBConst.h"

#import "QDXOrderInfoModel.h"
#import "QDXOrdermodel.h"
#import "QDXTicketInfoModel.h"
#import "QDXostatus.h"
#import "QDXpaytype.h"
#import "QDXOrderTableViewCell.h"
#import "QDXOrderDetailTableViewController.h"
#import "OrderService.h"
#import "QDXIsConnect.h"

#import "QDXLoginViewController.h"
#import "QDXNavigationController.h"

@interface XBTestTableViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    int curr;
    int page;
    int count;
    UIButton *_button;
    UIImageView *sad_1;
    UILabel *sadButton_1;
    UIView *loginView;
}
@property (nonatomic, strong) NSMutableArray *orders;

@property (nonatomic,strong) NSMutableArray *willPayOrders;

@property (nonatomic,strong) NSMutableArray *didPayOrders;

@property (nonatomic,strong) NSMutableArray *didCompleted;

@property (nonatomic, strong) UITableView *tableview;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    curr = 1;
    [loginView removeFromSuperview];
    [sad_1 removeFromSuperview];
    [sadButton_1 removeFromSuperview];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
}

- (void) createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight - FitRealValue(80)-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.backgroundColor = QDXBGColor;
    //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:self.tableview];
    
    [self setupRefreshView];
}

- (void)loadData
{
    [self performSelectorInBackground:@selector(getOrdersListAjax) withObject:nil];
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
    [self.tableview.mj_header beginRefreshing];
    
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
    }else{
        [OrderService cellDataBlock:^(NSMutableDictionary *dict) {
            QDXIsConnect *isConnect = [QDXIsConnect mj_objectWithKeyValues:dict];
            int ret = [isConnect.Code intValue];
            if (ret==1)  {
                if (![dict[@"Msg"][@"count"] isEqualToString:@"0"]){
                    // 将字典数据转为模型数据
                    curr = [dict[@"Msg"][@"curr"] intValue];
                    if(curr ==1){
                        self.orders = [[NSMutableArray alloc] init];
                        
                        self.willPayOrders = [[NSMutableArray alloc] init];
                        
                        self.didPayOrders = [[NSMutableArray alloc] init];
                        
                        self.didCompleted = [[NSMutableArray alloc] init];
                    }
                    page = [dict[@"Msg"][@"page"] intValue];
                    //将字典转模型
                    NSArray *dataDict = dict[@"Msg"][@"data"];
                    
                    for(NSDictionary *dict in dataDict){
                        [self.orders addObject:[QDXOrdermodel OrderWithDict:dict]];
                        
                        NSLog(@"lallala  %@",dict);
                        
                        switch ([dict[@"Orders_st"] intValue]) {
                            case 1:
                                [self.willPayOrders addObject:[QDXOrdermodel OrderWithDict:dict]];
                                break;
                                
                            case 2:
                                [self.didPayOrders addObject:[QDXOrdermodel OrderWithDict:dict]];
                                break;
                                
                            case 3:
                                [self.didCompleted addObject:[QDXOrdermodel OrderWithDict:dict]];
                                break;
                                
                            default:
                                break;
                        }
                    }
                }else{
                    self.orders = [[NSMutableArray alloc] init];
                    self.willPayOrders = [[NSMutableArray alloc] init];
                    self.didCompleted = [[NSMutableArray alloc] init];
                    self.didPayOrders = [[NSMutableArray alloc] init];
                    [self createSadView];
                }
                [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
            }else{
                //            [self createLoginView];
            }
            // 刷新表格
            [self.tableview reloadData];
            [self.tableview.mj_footer endRefreshing];
        } FailBlock:^(NSMutableArray *array) {
            
        } andWithToken:save andWithCurr:[NSString stringWithFormat:@"%d",curr]];
    }
}

-(void)sussRes
{
    
}


- (void)setXBParam:(NSString *)XBParam
{
    _XBParam = XBParam;
    XBLog(@"XBTestTableViewController received param === %@",XBParam);
}

- (void)dealloc
{
    XBLog(@"XBTestTableViewController delloc");

}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(20))];
    headerView.backgroundColor = QDXBGColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FitRealValue(20);
}

- (void)createLoginView
{
    loginView = [[UIView alloc] initWithFrame:self.tableview.frame];
    loginView.backgroundColor = QDXBGColor;
    [self.tableview addSubview:loginView];
    
    UIImageView *sad = [[UIImageView alloc] init];
    CGFloat sadCenterX = QdxWidth * 0.5;
    CGFloat sadCenterY = QdxHeight * 0.22;
    sad.center = CGPointMake(sadCenterX, sadCenterY);
    sad.bounds = CGRectMake(0, 0, 40, 43);
    sad.image = [UIImage imageNamed:@"order_logo"];
    [loginView addSubview:sad];
    
    UIButton *sadButton = [[UIButton alloc] init];
    sadButton.center = CGPointMake(sadCenterX, sadCenterY + 30 + 25);
    sadButton.bounds = CGRectMake(0, 0, 135, 30);
    [sadButton setTitle:@"登录查看订单" forState:UIControlStateNormal];
    [sadButton addTarget:self action:@selector(sign_in) forControlEvents:UIControlEventTouchUpInside];
    [sadButton setTitleColor:QDXBlue forState:UIControlStateNormal];
    sadButton.layer.borderColor = QDXBlue.CGColor;
    sadButton.layer.borderWidth = 0.5;
    sadButton.layer.cornerRadius = 4;
    sadButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [loginView addSubview:sadButton];
}

-(void)sign_in
{
    QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
    QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)createSadView
{
    sad_1 = [[UIImageView alloc] init];
    CGFloat sad_1CenterX = QdxWidth * 0.5;
    CGFloat sad_1CenterY = QdxHeight * 0.22;
    sad_1.center = CGPointMake(sad_1CenterX, sad_1CenterY);
    sad_1.bounds = CGRectMake(0, 0,40,43);
    sad_1.image = [UIImage imageNamed:@"order_nothing"];
    [self.tableview addSubview:sad_1];
    
    sadButton_1 = [[UILabel alloc] init];
    sadButton_1.center = CGPointMake(sad_1CenterX, sad_1CenterY + 43/2 + 20);
    sadButton_1.bounds = CGRectMake(0, 0, 120, 100);
    sadButton_1.text = @"您当前没有订单";
    sadButton_1.font = [UIFont systemFontOfSize:12];
    sadButton_1.textAlignment = NSTextAlignmentCenter;
    sadButton_1.textColor = QDXGray;
    [self.tableview addSubview:sadButton_1];
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

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QDXOrderDetailTableViewController *ODetailVC = [[QDXOrderDetailTableViewController alloc] init];
    ODetailVC.hidesBottomBarWhenPushed = YES;
    
    switch ([_XBParam intValue]) {
        case 0:
            ODetailVC.Order = self.orders[indexPath.row];
            break;
            
        case 1:
            ODetailVC.Order = self.willPayOrders[indexPath.row];
            break;
            
        case 2:
            ODetailVC.Order = self.didPayOrders[indexPath.row];
            break;
            
        case 3:
            ODetailVC.Order = self.didCompleted[indexPath.row];
            break;
            
        default:
            ODetailVC.Order = self.orders[indexPath.row];
            break;
    }
    
    [self.navigationController pushViewController:ODetailVC animated:YES];
}

@end
