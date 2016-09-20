//
//  OrderController.m
//  Qudingxiang
//
//  Created by Mac on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "OrderController.h"
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
@interface OrderController ()<MJRefreshBaseViewDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
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
@property (nonatomic, weak) MJRefreshFooterView *footer;
@property (nonatomic, weak) MJRefreshHeaderView *header;
@property (nonatomic, strong) UITableView *tableview;
@end

@implementation OrderController

- (NSMutableArray *)orders
{
    if (_orders == nil) {
        _orders = [NSMutableArray array];
    }
    return _orders;
}

- (void)viewDidAppear:(BOOL)animated
{
    curr = 1;
    [loginView removeFromSuperview];
    [sad_1 removeFromSuperview];
    [sadButton_1 removeFromSuperview];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的订单";
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
    
    [self createTableView];

    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_button setImage:[UIImage imageNamed:@"index_my"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void) createTableView
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
    //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableview];
    [self setupRefreshView];
}

- (void)setClick
{
    if(save == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆后才可使用此功能" delegate:self cancelButtonTitle:@"暂不登录" otherButtonTitles:@"立即登录", nil];
        [alert show];
    }else{
        [self.sideMenuViewController presentLeftMenuViewController];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if(buttonIndex == 1){

        QDXLoginViewController* regi=[[QDXLoginViewController alloc]init];
        QDXNavigationController* navController = [[QDXNavigationController alloc] initWithRootViewController:regi];
        regi.hidesBottomBarWhenPushed = YES;
        [self presentViewController:navController animated:YES completion:^{
            
        }];
    }
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
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableview;
    header.delegate = self;
    // 自动进入刷新状态
    [header beginRefreshing];
    self.header = header;
    
    // 2.上拉刷新(上拉加载更多数据)
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableview;
    footer.delegate = self;
    self.footer = footer;
}

- (void)dealloc
{
    // 释放内存
    [self.header free];
    [self.footer free];
}

/**
 *  刷新控件进入开始刷新状态的时候调用
 */
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    [self showProgessMsg:@"正在加载"];
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 3ull *NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        //执行操作
        [self showProgessOK:@"加载成功"];
        [self.footer endRefreshing];
        [self.header endRefreshing];
    });
    if ([refreshView isKindOfClass:[MJRefreshHeaderView class]]) { // 下拉刷新
        curr = 1;
        [self getOrdersListAjax];
    } else { // 上拉刷新
        curr++;
        if(curr > page ){
            [self.footer endRefreshing];
        }else{
            [self getOrdersListAjax];
        }
    }
}

-(void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView
{
    //执行操作
    [MBProgressHUD hideHUD];
    [self.footer endRefreshing];
    [self.header endRefreshing];
    [self.tableview reloadData];
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
                }
                page = [dict[@"Msg"][@"page"] intValue];
                //将字典转模型
                NSArray *dataDict = dict[@"Msg"][@"data"];
                for(NSDictionary *dict in dataDict){
                    [self.orders  addObject:[QDXOrdermodel OrderWithDict:dict]];
                }
            }else{
                self.orders = [[NSMutableArray alloc] init];
                [self createSadView];
            }
            [self performSelectorOnMainThread:@selector(sussRes) withObject:nil waitUntilDone:YES];
        }else{
//            [self createLoginView];
        }
        // 刷新表格
        [self.tableview reloadData];
        [self.header endRefreshing];
        [self.footer endRefreshing];
    } FailBlock:^(NSMutableArray *array) {
        [self.header endRefreshing];
        [self.footer endRefreshing];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败,请检查网络！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }] ];
        [self presentViewController:alert animated:YES completion:nil];

    } andWithToken:save andWithCurr:[NSString stringWithFormat:@"%d",curr]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 10)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)sussRes
{
    [self hideProgess];
}

- (void)createLoginView
{
    loginView = [[UIView alloc] initWithFrame:self.tableview.frame];
    loginView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
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
    [sadButton setTitleColor:[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000] forState:UIControlStateNormal];
    sadButton.layer.borderColor = [[UIColor colorWithRed:0.000 green:0.600 blue:0.992 alpha:1.000]CGColor];
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
    sadButton_1.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    [self.tableview addSubview:sadButton_1];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    QDXOrderInfoModel *OrderInfo = self.orders[0];
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    QDXOrderTableViewCell *cell = [QDXOrderTableViewCell cellWithTableView:tableView];
    // 2.给cell传递模型数据
    cell.order = self.orders[indexPath.row];
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
    ODetailVC.Order = self.orders[indexPath.row];
    [self.navigationController pushViewController:ODetailVC animated:YES];
}

@end
