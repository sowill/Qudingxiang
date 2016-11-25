//
//  QDXSlideCollectionViewCell.m
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXSlideCollectionViewCell.h"
#import "QDXSlideTableViewCell.h"

#import "QDXOrderInfoModel.h"
#import "QDXOrdermodel.h"
#import "QDXTicketInfoModel.h"
#import "QDXostatus.h"
#import "QDXpaytype.h"
#import "QDXOrderTableViewCell.h"
#import "QDXOrderDetailTableViewController.h"
#import "OrderService.h"
#import "QDXIsConnect.h"

@interface QDXSlideCollectionViewCell ()<UITableViewDelegate,UITableViewDataSource>
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

@property (nonatomic,strong)UITableView *tableView;

@end

static NSString *QDXSlideTableCellIdentifier = @"QDXSlideTableCellIdentifier";

@implementation QDXSlideCollectionViewCell

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

- (void)loadData
{
    [self performSelectorInBackground:@selector(getOrdersListAjax) withObject:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

// 初始化上下滑动tableView
- (UITableView *)tableView{
    if (!_tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight - FitRealValue(80)-64) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = QDXBGColor;
        //    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setupRefreshView];
        
        [self registHelperCell];
    }
    return _tableView;
}

/**
 *  集成刷新控件
 */
- (void)setupRefreshView
{
    // 1.下拉刷新
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
    
    // 2.上拉刷新(上拉加载更多数据)
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    self.tableView.mj_footer.ignoredScrollViewContentInsetBottom = 30;
    
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    curr = 1;
    [self getOrdersListAjax];
    
    // 刷新表格
    [self.tableView reloadData];
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.mj_header endRefreshing];
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    curr++;
    if(curr > page ){
        // 刷新表格
        [self.tableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self getOrdersListAjax];
    }
}

- (void)createLoginView
{
    loginView = [[UIView alloc] initWithFrame:self.tableView.frame];
    loginView.backgroundColor = QDXBGColor;
    [self.tableView addSubview:loginView];
    
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
                        [self.orders addObject:[QDXOrdermodel OrderWithDict:dict]];
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
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        } FailBlock:^(NSMutableArray *array) {
            
        } andWithToken:save andWithCurr:[NSString stringWithFormat:@"%d",curr]];
    }
}

- (void)createSadView
{
    sad_1 = [[UIImageView alloc] init];
    CGFloat sad_1CenterX = QdxWidth * 0.5;
    CGFloat sad_1CenterY = QdxHeight * 0.22;
    sad_1.center = CGPointMake(sad_1CenterX, sad_1CenterY);
    sad_1.bounds = CGRectMake(0, 0,40,43);
    sad_1.image = [UIImage imageNamed:@"order_nothing"];
    [self.tableView addSubview:sad_1];
    
    sadButton_1 = [[UILabel alloc] init];
    sadButton_1.center = CGPointMake(sad_1CenterX, sad_1CenterY + 43/2 + 20);
    sadButton_1.bounds = CGRectMake(0, 0, 120, 100);
    sadButton_1.text = @"您当前没有订单";
    sadButton_1.font = [UIFont systemFontOfSize:12];
    sadButton_1.textAlignment = NSTextAlignmentCenter;
    sadButton_1.textColor = QDXGray;
    [self.tableView addSubview:sadButton_1];
}

- (void)sussRes
{

}

// 注册cell
- (void)registHelperCell{
    [self.tableView registerClass:[QDXSlideTableViewCell class] forCellReuseIdentifier:QDXSlideTableCellIdentifier];
}

// 设置子视图
- (void)setup{
    // 添加子视图
    [self.contentView addSubview:self.tableView];
}

#pragma mark - tableView的代理方法 -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    
}

@end
